const { toDateString } = require('../utils/date');
const {
  zonedLocalToUtc,
  todayYmdInZone,
  addDaysYmd,
  toOnesignalSendAfter,
} = require('../utils/timezone');
const reminderRepository = require('../repositories/reminder_repository');
const profileRepository = require('../repositories/profile_repository');
const predictionRepository = require('../repositories/prediction_repository');
const periodRepository = require('../repositories/period_repository');
const pushDeviceRepository = require('../repositories/push_device_repository');
const scheduledNotificationRepository = require('../repositories/scheduled_notification_repository');
const onesignalService = require('./onesignal_service');

/** How far ahead to schedule cycle pushes (days). */
const HORIZON_DAYS = 30;
/** Local morning delivery hour (24h). */
const DELIVERY_HOUR = '09:00';

const CATALOG = {
  period_soon: {
    heading: 'Period may be close',
    content: 'Predictions suggest your period could start in 1–2 days. Want to check your calendar?',
    deepLink: 'eezycycle://calendar',
    channel: 'cycle_reminders',
    buttons: [
      { id: 'open_calendar', text: 'Open calendar' },
      { id: 'snooze', text: 'Remind later' },
    ],
  },
  period_expected: {
    heading: 'Period day may start today',
    content: 'Log flow when you’re ready — estimates only, not a diagnosis.',
    deepLink: 'eezycycle://calendar',
    channel: 'cycle_reminders',
    buttons: [{ id: 'open_calendar', text: 'Open calendar' }],
  },
  log_period_nudge: {
    heading: 'Still quiet on logging?',
    content: 'A quick period log keeps your predictions sharp.',
    deepLink: 'eezycycle://calendar',
    channel: 'cycle_reminders',
  },
  fertile_start: {
    heading: 'Fertile window',
    content: 'Higher-chance days may be starting (estimate only — not contraception).',
    deepLink: 'eezycycle://home',
    channel: 'cycle_reminders',
  },
  ovulation_day: {
    heading: 'Around ovulation',
    content: 'Timing estimate for today — not a medical guarantee.',
    deepLink: 'eezycycle://home',
    channel: 'cycle_reminders',
  },
  daily_tip: {
    heading: 'Today’s tip',
    content: 'A short wellness tip based on where you are in your cycle.',
    deepLink: 'eezycycle://articles',
    channel: 'daily_tips',
  },
  pregnancy_week: {
    heading: 'Weekly pregnancy check-in',
    content: 'Gentle tips for this week of your pregnancy journey.',
    deepLink: 'eezycycle://home',
    channel: 'cycle_reminders',
  },
};

/**
 * Fire-and-forget safe rebuild — never throws to callers.
 * @param {number} userId
 * @param {{ reason?: string }} [opts]
 */
function rebuildSafe(userId, opts = {}) {
  rebuild(userId, opts).catch((err) => {
    console.error(
      `[notification_planner] rebuild failed user=${userId} reason=${opts.reason || '-'}:`,
      err?.message || err,
    );
  });
}

/**
 * Cancel prior OneSignal schedules + create next ones from predictions + prefs.
 * @param {number} userId
 * @param {{ reason?: string }} [opts]
 */
async function rebuild(userId, opts = {}) {
  if (!onesignalService.isConfigured()) {
    return { skipped: true, reason: 'onesignal_not_configured' };
  }

  const [profile, reminders, predictions, periodRows] = await Promise.all([
    profileRepository.findByUserId(userId),
    reminderRepository.findByUserId(userId),
    predictionRepository.listByUserId(userId).catch(() => []),
    periodRepository.listByUserId(userId).catch(() => []),
  ]);

  const tz =
    reminders?.timezone ||
    profile?.timezone ||
    'UTC';
  const today = todayYmdInZone(tz);
  const horizonEnd = addDaysYmd(today, HORIZON_DAYS);

  const prefs = {
    periodReminder: Boolean(reminders?.period_reminder_enabled),
    fertileDays: Boolean(reminders?.fertile_days_enabled),
    dailyTips: reminders?.daily_tips_enabled == null
      ? true
      : Boolean(reminders.daily_tips_enabled),
    pregnancyTest: Boolean(reminders?.pregnancy_test_enabled),
  };

  const pregnancyOn = Boolean(profile?.pregnancy_mode_active);
  const planned = [];

  if (pregnancyOn) {
    // Soft weekly tip — next Sunday morning within horizon
    const nextSunday = nextWeekdayYmd(today, 0);
    if (nextSunday <= horizonEnd) {
      planned.push({ type: 'pregnancy_week', fireYmd: nextSunday });
    }
  } else {
    const nextPeriodStart = findNextPeriodStart(predictions, today, horizonEnd);
    if (prefs.periodReminder && nextPeriodStart) {
      const soon = addDaysYmd(nextPeriodStart, -2);
      if (soon >= today && soon <= horizonEnd) {
        planned.push({ type: 'period_soon', fireYmd: soon });
      }
      if (nextPeriodStart >= today && nextPeriodStart <= horizonEnd) {
        planned.push({ type: 'period_expected', fireYmd: nextPeriodStart });
      }
      const nudge = addDaysYmd(nextPeriodStart, 1);
      if (nudge <= horizonEnd && !hasLoggedPeriodOnOrAfter(periodRows, nextPeriodStart)) {
        planned.push({ type: 'log_period_nudge', fireYmd: nudge });
      }
    }

    if (prefs.fertileDays) {
      const fertileStart = findFirstFertile(predictions, today, horizonEnd);
      if (fertileStart) {
        planned.push({ type: 'fertile_start', fireYmd: fertileStart });
      }
      const ovulation = findOvulation(predictions, today, horizonEnd);
      if (ovulation) {
        planned.push({ type: 'ovulation_day', fireYmd: ovulation });
      }
    }

    if (prefs.dailyTips) {
      // Next local morning tip (tomorrow if today's 9am already passed)
      let tipDay = today;
      const tipAt = zonedLocalToUtc(tipDay, DELIVERY_HOUR, tz);
      if (tipAt.getTime() <= Date.now() + 60_000) {
        tipDay = addDaysYmd(today, 1);
      }
      if (tipDay <= horizonEnd) {
        planned.push({ type: 'daily_tip', fireYmd: tipDay });
      }
    }
  }

  // Cancel previously scheduled types that we own
  const existing = await scheduledNotificationRepository.listScheduledByUserId(userId);
  const plannedTypes = new Set(planned.map((p) => p.type));

  for (const row of existing) {
    if (row.onesignal_notification_id) {
      try {
        await onesignalService.cancelNotification(row.onesignal_notification_id);
      } catch (err) {
        console.warn(
          `[notification_planner] cancel ${row.notification_type} failed:`,
          err?.message || err,
        );
      }
    }
    if (!plannedTypes.has(row.notification_type)) {
      await scheduledNotificationRepository.markCancelled(userId, row.notification_type);
    }
  }

  // Link stored subscriptions → External ID, then sync tags (best-effort).
  // Fixes "Given alias (external_id: N) doesn't match an existing user" when
  // rebuild runs before / without a successful OneSignal.login on device.
  const tags = {
    period_reminder: prefs.periodReminder ? '1' : '0',
    fertile_reminders: prefs.fertileDays ? '1' : '0',
    daily_tips: prefs.dailyTips ? '1' : '0',
    pregnancy_test: prefs.pregnancyTest ? '1' : '0',
    experience_mode: profile?.experience_mode || '',
    is_partner: profile?.usage_path === 'partner' ? '1' : '0',
    pregnancy_mode: pregnancyOn ? '1' : '0',
  };

  try {
    const devices = await pushDeviceRepository.listEnabledByUserId(userId);
    for (const device of devices) {
      const subId = device.onesignal_subscription_id;
      if (!subId) continue;
      try {
        await onesignalService.linkSubscriptionToExternalId(subId, userId);
      } catch (err) {
        console.warn(
          `[notification_planner] link subscription failed sub=${subId}:`,
          err?.message || err,
        );
      }
    }
    await onesignalService.ensureExternalUser(userId, tags);
    await onesignalService.updateUserTags(userId, tags);
  } catch (err) {
    console.warn('[notification_planner] tag update failed:', err?.message || err);
  }

  const results = [];
  for (const item of planned) {
    const catalog = CATALOG[item.type];
    if (!catalog) continue;

    const fireAt = zonedLocalToUtc(item.fireYmd, DELIVERY_HOUR, tz);
    // Skip anything already in the past
    if (fireAt.getTime() <= Date.now()) continue;

    const sendAfter = toOnesignalSendAfter(fireAt);
    const payload = {
      notification_type: item.type,
      deep_link: catalog.deepLink,
      fire_ymd: item.fireYmd,
      timezone: tz,
    };

    try {
      const created = await onesignalService.createNotification({
        externalUserId: userId,
        heading: catalog.heading,
        content: catalog.content,
        data: payload,
        sendAfter,
        androidChannelId: catalog.channel,
        buttons: catalog.buttons,
      });

      await scheduledNotificationRepository.upsertScheduled(userId, {
        notificationType: item.type,
        onesignalNotificationId: created.id,
        fireAtUtc: fireAt.toISOString().slice(0, 19).replace('T', ' '),
        status: created.id ? 'scheduled' : 'failed',
        payloadJson: payload,
      });

      results.push({ type: item.type, id: created.id, fire_at: sendAfter });
    } catch (err) {
      console.error(
        `[notification_planner] create ${item.type} failed:`,
        err?.message || err,
      );
      await scheduledNotificationRepository.upsertScheduled(userId, {
        notificationType: item.type,
        onesignalNotificationId: null,
        fireAtUtc: fireAt.toISOString().slice(0, 19).replace('T', ' '),
        status: 'failed',
        payloadJson: { ...payload, error: String(err?.message || err) },
      });
      results.push({ type: item.type, error: String(err?.message || err) });
    }
  }

  return {
    reason: opts.reason || null,
    timezone: tz,
    planned: results,
  };
}

function findNextPeriodStart(predictions, today, horizonEnd) {
  const rows = (predictions || [])
    .filter((p) => {
      const date = toDateString(p.pred_date);
      if (!date || date < today || date > horizonEnd) return false;
      const type = String(p.prediction_type || p.day_type || '').toLowerCase();
      if (type !== 'period' && type !== 'predicted_period') return false;
      const day = p.period_day == null ? 1 : Number(p.period_day);
      return day === 1;
    })
    .map((p) => toDateString(p.pred_date))
    .filter(Boolean)
    .sort();
  return rows[0] || null;
}

function findFirstFertile(predictions, today, horizonEnd) {
  const dates = (predictions || [])
    .filter((p) => {
      const date = toDateString(p.pred_date);
      if (!date || date < today || date > horizonEnd) return false;
      const type = String(p.prediction_type || p.day_type || '').toLowerCase();
      return type.includes('fertil');
    })
    .map((p) => toDateString(p.pred_date))
    .filter(Boolean)
    .sort();
  return dates[0] || null;
}

function findOvulation(predictions, today, horizonEnd) {
  const dates = (predictions || [])
    .filter((p) => {
      const date = toDateString(p.pred_date);
      if (!date || date < today || date > horizonEnd) return false;
      const type = String(p.prediction_type || p.day_type || '').toLowerCase();
      return type.includes('ovulat');
    })
    .map((p) => toDateString(p.pred_date))
    .filter(Boolean)
    .sort();
  return dates[0] || null;
}

function hasLoggedPeriodOnOrAfter(periodRows, ymd) {
  return (periodRows || []).some((r) => {
    if (r.is_predicted) return false;
    const d = toDateString(r.log_date);
    return d && d >= ymd;
  });
}

/** Next occurrence of weekday (0=Sun … 6=Sat), including today. */
function nextWeekdayYmd(fromYmd, weekday) {
  const [y, m, d] = fromYmd.split('-').map(Number);
  const dt = new Date(Date.UTC(y, m - 1, d));
  const current = dt.getUTCDay();
  const delta = (weekday - current + 7) % 7;
  return addDaysYmd(fromYmd, delta);
}

module.exports = {
  rebuild,
  rebuildSafe,
  HORIZON_DAYS,
};
