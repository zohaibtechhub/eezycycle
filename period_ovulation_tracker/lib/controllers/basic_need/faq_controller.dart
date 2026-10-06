import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqItemModel {
  final String id;
  final String question;
  final String answer;
  final String category;
  final RxBool isExpanded;

  FaqItemModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    bool isExpanded = false,
  }) : isExpanded = isExpanded.obs;
}

class HelpFaqController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  final List<String> categories = const [
    'All',
    'Getting Started',
    'Cycle & Health',
    'Partner Sync',
    'Secret Chat',
    'Privacy & Data',
    'Account',
  ];

  final List<FaqItemModel> allFaqs = [
    // ── Getting Started ─────────────────────────────────────────
    FaqItemModel(
      id: 'gs1',
      question: 'Do I need an account to use EezyCycle?',
      answer:
          'No. You can start as a guest and log periods, track symptoms, and use most features right away. Creating an account (email or Google) keeps your data tied to you so you can sign in again on the same or another device without losing your history.',
      category: 'Getting Started',
    ),
    FaqItemModel(
      id: 'gs2',
      question: 'What should I do first after installing the app?',
      answer:
          'Accept privacy & terms, choose how you’ll use EezyCycle (for yourself or with a partner code), pick your goals (e.g. Track cycle), then log your last period dates. Predictions improve after you save at least one full period.',
      category: 'Getting Started',
    ),
    FaqItemModel(
      id: 'gs3',
      question: 'What’s the difference between Track cycle, Get pregnant, and Pregnancy modes?',
      answer:
          'Track cycle focuses on period and ovulation predictions for everyday awareness. Get pregnant emphasizes fertile-window timing. Pregnancy mode shifts the home experience to pregnancy week estimates and due-date support. You can switch modes later from the drawer under Your EezyCycle Experience.',
      category: 'Getting Started',
    ),
    FaqItemModel(
      id: 'gs4',
      question: 'Why does the home screen show “Log your period”?',
      answer:
          'That message appears when we don’t yet have enough period history to build predictions. Open the calendar, tap your period days, then press Log (top right). After you save, ovulation and fertile-window estimates unlock.',
      category: 'Getting Started',
    ),
    FaqItemModel(
      id: 'gs5',
      question: 'Can I use EezyCycle offline?',
      answer:
          'You need a connection to sync logs, predictions, partner status, and secret chat. Brief offline moments may show cached home content, but saving periods and account actions require the API to be reachable.',
      category: 'Getting Started',
    ),

    // ── Cycle & Health ──────────────────────────────────────────
    FaqItemModel(
      id: 'ch1',
      question: 'How accurate are the cycle and ovulation predictions?',
      answer:
          'Predictions improve the more cycles you log. We use standard cycle-length and luteal-phase estimates adjusted by your history. Treat fertile and ovulation days as estimates only — not contraception and not a medical diagnosis.',
      category: 'Cycle & Health',
    ),
    FaqItemModel(
      id: 'ch2',
      question: 'How do I log or edit period days?',
      answer:
          'Open the calendar from the home header. Tap days to mark or unmark period flow (changes stay local until you save). Tap Log in the top right to send one update to the server. If you go back with unsaved taps, you’ll be asked to Discard or Log.',
      category: 'Cycle & Health',
    ),
    FaqItemModel(
      id: 'ch3',
      question: 'Can I log periods on future dates?',
      answer:
          'No. Period days can only be logged for today or past dates. Future dates on the home strip show predictions (fertile window, ovulation, next period) so you can plan ahead — they aren’t editable as logged bleeds.',
      category: 'Cycle & Health',
    ),
    FaqItemModel(
      id: 'ch4',
      question: 'How do I log irregular cycles or spotting?',
      answer:
          'Use the calendar to tap any past or current day that had spotting or flow, then Log. Symptoms (cramps, mood, discharge, and more) can be logged from Home quick actions. Larger cycle swings automatically widen prediction confidence over time.',
      category: 'Cycle & Health',
    ),
    FaqItemModel(
      id: 'ch5',
      question: 'What is the fertile window?',
      answer:
          'The fertile window is the stretch of days when conception is more likely, ending around ovulation. EezyCycle marks these from your cycle length and luteal phase. Timing estimates are not birth control — use contraception if you are avoiding pregnancy.',
      category: 'Cycle & Health',
    ),
    FaqItemModel(
      id: 'ch6',
      question: 'What does “luteal phase” mean in my profile?',
      answer:
          'The luteal phase is the time from ovulation to the start of your next period (often about 14 days). Your profile stores an average used for predictions. If your clinician recommends a different value, update it in your cycle settings when available.',
      category: 'Cycle & Health',
    ),
    FaqItemModel(
      id: 'ch7',
      question: 'What are “Your patterns” on Home?',
      answer:
          'Your patterns are personal timing insights built from your symptom and cycle logs (for example, when cramps or mood shifts tend to appear). They’re educational summaries — not a diagnosis. Patterns appear after you’ve logged enough history.',
      category: 'Cycle & Health',
    ),
    FaqItemModel(
      id: 'ch8',
      question: 'Where can I see cycle length and ovulation stats?',
      answer:
          'Open the drawer → Graphs & reports → Cycle and ovulation. You’ll see average cycle/period length, phase breakdown, and recent history trends based on your logged data.',
      category: 'Cycle & Health',
    ),
    FaqItemModel(
      id: 'ch9',
      question: 'Does EezyCycle replace medical advice?',
      answer:
          'No. The app is for personal tracking and education. Always talk to a qualified healthcare professional about contraception, fertility treatment, pregnancy concerns, severe pain, unusually heavy bleeding, or missed periods.',
      category: 'Cycle & Health',
    ),
    FaqItemModel(
      id: 'ch10',
      question: 'How does pregnancy mode change the app?',
      answer:
          'When pregnancy mode is active, Home focuses on pregnancy week and due-date style estimates instead of fertile-window countdowns. Cycle logging and partner sharing behave according to your pregnancy settings. Switch modes from the drawer when your goals change.',
      category: 'Cycle & Health',
    ),
    FaqItemModel(
      id: 'ch11',
      question: 'Why did my predictions change after I logged a period?',
      answer:
          'Each saved period updates your averages and rebuilds upcoming fertile and ovulation estimates. That’s expected — more real data makes the next cycle’s forecast closer to your body.',
      category: 'Cycle & Health',
    ),
    FaqItemModel(
      id: 'ch12',
      question: 'Can I track LH / ovulation tests?',
      answer:
          'Yes. From Home, use Tests / LH (or the logging sheet) to record ovulation-test results for a selected date. Positive or peak tests help you reflect on timing alongside predicted ovulation — they don’t replace clinical care.',
      category: 'Cycle & Health',
    ),

    // ── Partner Sync ────────────────────────────────────────────
    FaqItemModel(
      id: 'ps1',
      question: 'How does Partner Mode work?',
      answer:
          'You generate a 6-character invite code. Your partner chooses “I have a partner code” during onboarding and enters it. They get a read-only home with cycle phases and relationship tips. They cannot edit or delete your health logs.',
      category: 'Partner Sync',
    ),
    FaqItemModel(
      id: 'ps2',
      question: 'How do I generate a partner connection code?',
      answer:
          'Open the Partner tab (or Partner connection from the drawer), create or view your invite code, and share the 6-character code securely with your partner. Codes expire or close when linked — generate a new one if you need to reconnect.',
      category: 'Partner Sync',
    ),
    FaqItemModel(
      id: 'ps3',
      question: 'What can my partner see?',
      answer:
          'Partners see high-level cycle phases (period, fertile window, ovulation estimates), pregnancy status when relevant, and supportive tips. They do not see detailed symptom notes, sex logs, test results, or your secret chat content.',
      category: 'Partner Sync',
    ),
    FaqItemModel(
      id: 'ps4',
      question: 'Can my partner change my period dates or profile photo?',
      answer:
          'No. Partners are read-only. Your photo appears for them so they recognize your shared space, but only you can update cycle logs and profile photo from your account.',
      category: 'Partner Sync',
    ),
    FaqItemModel(
      id: 'ps5',
      question: 'How do I disconnect a partner?',
      answer:
          'From Partner connection / status on your account, end the link. Your partner loses access to shared cycle views. Your personal logs stay on your account. You can invite someone again later with a new code.',
      category: 'Partner Sync',
    ),
    FaqItemModel(
      id: 'ps6',
      question: 'I’m a partner — why can’t I open the full calendar editor?',
      answer:
          'Partners get a shared, read-only view of the cycle. Logging periods, symptoms, and tests stays with the person who owns the cycle data. Use tips and phase info to support them day to day.',
      category: 'Partner Sync',
    ),

    // ── Secret Chat ─────────────────────────────────────────────
    FaqItemModel(
      id: 'sc1',
      question: 'What is Secret Chat?',
      answer:
          'Secret Chat is an anonymous community space inside EezyCycle. You pick a username and optional tags, then can post and comment without showing your real email. It’s meant for supportive cycle and wellness conversation.',
      category: 'Secret Chat',
    ),
    FaqItemModel(
      id: 'sc2',
      question: 'Is Secret Chat really anonymous?',
      answer:
          'Posts and comments show your secret username and profile photo, not your email. Don’t share identifying details in posts if you want to stay private. Moderators may still act on reports of harmful content.',
      category: 'Secret Chat',
    ),
    FaqItemModel(
      id: 'sc3',
      question: 'How do I set or change my secret username?',
      answer:
          'Open Secret Chat → your profile / edit profile. Choose a username (about 3–40 characters) and optional tags like PCOS or Trying to conceive. Your account profile photo is used for the community avatar.',
      category: 'Secret Chat',
    ),
    FaqItemModel(
      id: 'sc4',
      question: 'Can I delete a post I made?',
      answer:
          'Yes. On your post, use Delete and confirm. You’ll see a short loading state while the post is removed. Deleted posts disappear for everyone in the community feed.',
      category: 'Secret Chat',
    ),
    FaqItemModel(
      id: 'sc5',
      question: 'Does my partner see Secret Chat?',
      answer:
          'No. Secret Chat is separate from Partner Mode. Partners never see your posts, comments, or secret username through the partner link.',
      category: 'Secret Chat',
    ),

    // ── Privacy & Data ──────────────────────────────────────────
    FaqItemModel(
      id: 'pd1',
      question: 'Is my reproductive health data secure?',
      answer:
          'We transmit data over HTTPS and store account and health records on secured servers. We do not sell your reproductive health data to advertisers. Read the in-app Privacy Policy for full details on retention and your rights.',
      category: 'Privacy & Data',
    ),
    FaqItemModel(
      id: 'pd2',
      question: 'Can my partner see all my intimate logged symptoms?',
      answer:
          'No. Partner Mode only shares high-level cycle phases and supportive tips. Intimate notes, sex logs, and specific test details stay private to you.',
      category: 'Privacy & Data',
    ),
    FaqItemModel(
      id: 'pd3',
      question: 'Who can see my profile photo?',
      answer:
          'Your photo appears in the app header, drawer, profile, and Secret Chat. A linked partner sees your photo as read-only context. It is not shown publicly outside the app.',
      category: 'Privacy & Data',
    ),
    FaqItemModel(
      id: 'pd4',
      question: 'How do I review privacy settings?',
      answer:
          'Open the drawer → User Privacy (or Privacy Policy / Terms from legal screens). You can revisit consent documents anytime. Contact support through official channels if you need account deletion help.',
      category: 'Privacy & Data',
    ),
    FaqItemModel(
      id: 'pd5',
      question: 'Does ending a guest session delete my data?',
      answer:
          'Ending a guest session on this device starts a fresh guest experience locally. Registered account data stays safely on the server so you can sign in again. Upgrade to an account if you want a lasting backup of your logs.',
      category: 'Privacy & Data',
    ),

    // ── Account ─────────────────────────────────────────────────
    FaqItemModel(
      id: 'ac1',
      question: 'How do I create an account or sign in?',
      answer:
          'From the drawer, use the email / password or Google options. Guests upgrade in place so your cycle logs stay with you. Already registered? Use Sign in — your saved periods and settings load after authentication.',
      category: 'Account',
    ),
    FaqItemModel(
      id: 'ac2',
      question: 'I forgot my password — what do I do?',
      answer:
          'On the sign-in screen, choose Forgot password. Enter your email, verify the OTP we send, then set a new password. Check spam if the email is slow, and make sure you use the same address as your account.',
      category: 'Account',
    ),
    FaqItemModel(
      id: 'ac3',
      question: 'Can I change my profile photo?',
      answer:
          'Yes — open My Profile from the drawer and tap your photo (guests and registered users). Partners cannot change the woman’s photo. The new image syncs to Secret Chat and partner views.',
      category: 'Account',
    ),
    FaqItemModel(
      id: 'ac4',
      question: 'Why don’t I see my periods right after signing in?',
      answer:
          'After login we refresh Home and calendar for your account. Stay on Home a moment while data loads. If something still looks empty, pull to refresh or reopen Cycle and ovulation from the drawer.',
      category: 'Account',
    ),
    FaqItemModel(
      id: 'ac5',
      question: 'What’s the difference between Log out and ending a guest session?',
      answer:
          'Registered users Log out and can sign back in later. Guests “end session” clears the local guest session and starts fresh on this device. Registered data on the server is not deleted by logging out.',
      category: 'Account',
    ),
    FaqItemModel(
      id: 'ac6',
      question: 'Can I use Google to sign in?',
      answer:
          'Yes. Choose Google on the auth screens. If that Google email is new, your guest upgrades in place. If it already belongs to an account, you sign into that existing account and your cycle history for that user loads.',
      category: 'Account',
    ),
    FaqItemModel(
      id: 'ac7',
      question: 'Where do I find Help, FAQ, and legal documents?',
      answer:
          'Open the drawer and look for Help & FAQ, Privacy Policy, and Terms. Those screens explain how EezyCycle works and how we handle your information.',
      category: 'Account',
    ),
    FaqItemModel(
      id: 'ac8',
      question: 'How do I bookmark articles?',
      answer:
          'On article screens that support bookmarks, tap the bookmark control. Saved pieces appear under Bookmarks in the drawer so you can reopen educational content later (requires a signed-in session — guest or registered).',
      category: 'Account',
    ),
  ];

  List<FaqItemModel> get filteredFaqs {
    return allFaqs.where((faq) {
      final matchesCategory =
          selectedCategory.value == 'All' ||
          faq.category == selectedCategory.value;
      final query = searchQuery.value.toLowerCase().trim();
      final matchesQuery =
          query.isEmpty ||
          faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void toggleExpand(String id) {
    for (final faq in allFaqs) {
      if (faq.id == id) {
        faq.isExpanded.value = !faq.isExpanded.value;
      } else if (faq.isExpanded.value) {
        // Accordion: one open at a time for easier reading.
        faq.isExpanded.value = false;
      }
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
