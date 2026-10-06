import 'package:flutter/material.dart';
import 'package:period_ovulation_tracker/core/constants/app_images.dart';

import 'onboarding_option.dart';
import 'onboarding_step.dart';

final pregnancyOnboardingSteps = <OnboardingStep>[
  // 1
  OnboardingStep(
    id: 'feeling',
    type: OnboardingStepType.question,
    title: 'How are you feeling?',
    description:
        'Everyone comes into this journey with different emotions, and understanding where you are right now helps us personalize your daily tips and support.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'excited',
        title: 'Excited to be on this journey',
        description:
            'I feel genuinely happy, positive, and ready to take the next steps toward starting or growing my family.',
      ),
      OnboardingOption(
        id: 'unsure',
        title: 'A bit unsure or unprepared',
        description:
            'I want to conceive, but I still have a lot of questions and would appreciate simple, clear guidance along the way.',
      ),
      OnboardingOption(
        id: 'worried',
        title: 'Worried or stressed',
        description:
            'I find myself worrying about whether things will go smoothly, how long it will take, or if my body is ready.',
      ),
      OnboardingOption(
        id: 'mixed',
        title: 'Happy, nervous and excited — all at the same time',
        description:
            'My feelings change day to day, balancing genuine excitement with normal nervousness about such a big life change.',
      ),
    ],
  ),

  // 2
  OnboardingStep(
    id: 'pregnancy_timeline',
    type: OnboardingStepType.question,
    title: 'How soon do you want to get pregnant?',
    description:
        'Knowing your intended timing helps us adjust predictions, reminders, and how actively we focus on your upcoming fertile windows.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'asap',
        title: 'As soon as possible',
        description:
            'I am ready right now and want to make the most of every single fertile window starting this current cycle.',
      ),
      OnboardingOption(
        id: 'not_in_rush',
        title: 'I’m not in a rush',
        description:
            'I am taking a relaxed approach for the next few months or year while learning more about how my body works.',
      ),
    ],
  ),

  // 3
  OnboardingStep(
    id: 'trying_duration',
    type: OnboardingStepType.question,
    title: 'How long have you been trying to get pregnant?',
    description:
        'Sharing your timeline gives us helpful context so we can offer the most relevant advice and clinical information for your stage.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'just_started',
        title: 'I’ve just started trying',
        description:
            'We are in our very first cycle of trying to conceive and are just beginning to track fertile days.',
      ),
      OnboardingOption(
        id: 'zero_to_three',
        title: '0 to 3 months',
        description:
            'We have been actively timing intercourse for one to three cycles and are getting familiar with the process.',
      ),
      OnboardingOption(
        id: 'three_to_six',
        title: '3 to 6 months',
        description:
            'We have been trying consistently for about three to six months and are looking for ways to optimize our chances.',
      ),
      OnboardingOption(
        id: 'six_to_twelve',
        title: '6 months to a year',
        description:
            'We have been trying for over half a year and want clearer insights into ovulation patterns and cycle health.',
      ),
      OnboardingOption(
        id: 'over_year',
        title: 'Over a year',
        description:
            'We have been trying for more than twelve months and would like deeper guidance and support on potential next steps.',
      ),
    ],
  ),

  // 4
  OnboardingStep(
    id: 'conception_social_proof',
    type: OnboardingStepType.socialProof,

    richTitle: OnboardingRichText(
      highlightedPart: '8 out of 10 women',
      middlePart: ' say ',
      secondHighlightedPart:
          'EezyCycle helped them on their journey to conceive',
    ),

    richDescription: OnboardingRichText(
      firstPart: 'By ',
      highlightedPart: 'tracking cycle patterns',
      middlePart:
          ' and identifying the most fertile days, our members feel much more confident and supported while trying to get pregnant.',
      secondHighlightedPart: '',
    ),
    image: AppImages.conceptionSocialProof,

    canSkip: false,
    showProgress: false,
    countsTowardProgress: false,
  ),
  // 5
  OnboardingStep(
    id: 'fertile_days',
    type: OnboardingStepType.question,
    title: 'Do you try to conceive on your most fertile days?',
    description:
        'There are only a few days in each cycle when pregnancy is possible, so knowing if you already track them helps us tailor your calendar.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'yes',
        title: 'Yes',
        description:
            'I regularly track my cycle or use ovulation tests so we can time intercourse specifically during my fertile window.',
      ),
      OnboardingOption(
        id: 'no',
        title: 'No',
        description:
            'We have sex whenever we feel like it without worrying about specific dates or tracking calendar predictions.',
      ),
      OnboardingOption(
        id: 'dont_know',
        title: 'I don’t know when I’m at my most fertile',
        description:
            'I am not quite sure how to calculate my fertile days yet and would love clear help figuring that out.',
      ),
    ],
  ),

  // 6
  OnboardingStep(
    id: 'regular_periods',
    type: OnboardingStepType.question,
    title: 'Are your periods regular?',
    description:
        'A regular cycle makes ovulation easier to predict, while irregular cycles mean we use more flexible tracking methods to find your window.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'yes',
        title: 'Yes',
        description:
            'My period consistently arrives around the expected date every month, usually within a predictable 21 to 35 day range.',
      ),
      OnboardingOption(
        id: 'no',
        title: 'No',
        description:
            'My cycle lengths vary quite a bit, making it tough to guess exactly when my next period or ovulation will happen.',
      ),
      OnboardingOption(
        id: 'dont_know',
        title: 'I don’t know',
        description:
            'I haven’t paid close attention to the exact dates in the past, so I am not sure if my cycle is regular or not.',
      ),
    ],
  ),

  // 7
  OnboardingStep(
    id: 'expert_pregnancy_questions',
    type: OnboardingStepType.education,

    richTitle: OnboardingRichText(
      highlightedPart: 'Experts',
      middlePart: ' answer popular pregnancy questions',
    ),

    richDescription: OnboardingRichText(
      firstPart: 'Ask anonymous questions and get expert comments from ',
      highlightedPart: 'EezyCycle’s team of doctors',
      middlePart:
          ' with trusted guidance to help you better understand pregnancy, fertility, and conception.',
    ),

    image: AppImages.expertPregnancyQuestions,

    canSkip: false,
    showProgress: false,
    countsTowardProgress: false,
  ),

  // 8
  OnboardingStep(
    id: 'content_warning',
    type: OnboardingStepType.contentWarning,
    icon: Icons.warning_amber_rounded,
    richTitle: OnboardingRichText(highlightedPart: 'Content Warning'),
    richDescription: OnboardingRichText(
      firstPart: 'The next question touches on ',
      highlightedPart: 'past pregnancy experiences and pregnancy loss',
      middlePart:
          '. Please feel free to answer only if you are comfortable doing so.',
    ),

    canSkip: false,
    showProgress: false,
    countsTowardProgress: false,
  ),

  // 9
  OnboardingStep(
    id: 'first_time_conceiving',
    type: OnboardingStepType.question,
    title: 'Is this your first time trying to conceive?',
    description:
        'Your reproductive history helps us provide the most supportive, relevant content without making assumptions about your journey.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'yes',
        title: 'Yes',
        description:
            'This is my very first time trying to get pregnant, and everything about this journey is completely new to me.',
      ),
      OnboardingOption(
        id: 'children',
        title: 'No, I already have children',
        description:
            'I have been through pregnancy and childbirth before, and I am now looking to add another child to our family.',
      ),
      OnboardingOption(
        id: 'pregnancy_loss',
        title: 'No, I’ve experienced pregnancy loss or ended a pregnancy',
        description:
            'I have been pregnant in the past, and I would appreciate compassionate support that honors my personal journey.',
      ),
      OnboardingOption(
        id: 'prefer_not',
        title: 'Prefer not to answer',
        description:
            'I would rather keep my past experiences private for now and focus directly on my tracking going forward.',
      ),
    ],
  ),

  // 11
  OnboardingStep(
    id: 'cycle_intro',
    type: OnboardingStepType.sectionIntro,

    richTitle: OnboardingRichText(
      firstPart: 'Next we’ll look at your ',
      highlightedPart: 'cycle and fertility',
    ),

    description:
        'By sharing a few simple details about your period, our smart algorithm can begin mapping out your personal cycle rhythm.',

    image: AppImages.cycleFertility,

    canSkip: false,
    showProgress: false,
    countsTowardProgress: false,
  ),

  OnboardingStep(
    id: 'fertility_tracking_insight',
    type: OnboardingStepType.education,

    richTitle: OnboardingRichText(
      firstPart: 'Get insights into your fertility by ',
      highlightedPart: 'logging your period',
    ),

    richDescription: OnboardingRichText(
      firstPart: '',
      highlightedPart: '80% of EezyCycle users',
      middlePart:
          ' use EezyCycle to track their fertility window and ovulation.',
    ),
    image: AppImages.trackFertility,
    canSkip: false,
    showProgress: false,
    countsTowardProgress: false,
  ),

  // 12
  OnboardingStep(
    id: 'last_period',
    type: OnboardingStepType.calendar,

    richTitle: OnboardingRichText(
      firstPart: 'Tap on the day when your ',
      highlightedPart: 'last period started',
    ),

    richDescription: OnboardingRichText(
      firstPart: 'We started with a ',
      highlightedPart: '5 day period',
      middlePart: '\nAdjust for smarter predictions',
    ),

    canSkip: false,
    showProgress: true,
    countsTowardProgress: true,
  ),

  // 13
  OnboardingStep(
    id: 'birth_control',
    type: OnboardingStepType.question,
    title: 'Have you used birth control in the last 6 months?',
    description:
        'Some hormonal birth control methods can take a few months to fully clear from your body, which might temporarily shift your ovulation dates.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'none',
        title: 'No',
        description:
            'I have not used any form of hormonal or barrier birth control over the past six months.',
      ),
      OnboardingOption(
        id: 'currently_using',
        title: 'I’m still using birth control',
        description:
            'I am currently on birth control and am preparing in advance for when I choose to stop.',
      ),
      OnboardingOption(
        id: 'pill',
        title: 'Yes, I was on the pill',
        description:
            'I took daily oral contraceptive pills recently and stopped within the last six months.',
      ),
      OnboardingOption(
        id: 'iud',
        title: 'Yes, I had an IUD',
        description:
            'I had a hormonal or copper intrauterine device that was removed within the last six months.',
      ),
      OnboardingOption(
        id: 'condoms',
        title: 'Yes, condoms or another non-hormonal method',
        description:
            'We relied on barrier methods like condoms or natural tracking rather than medical hormones.',
      ),
      OnboardingOption(
        id: 'other',
        title: 'Yes, something else',
        description:
            'I used another method such as an arm implant, hormonal injections, a vaginal ring, or skin patches.',
      ),
      OnboardingOption(
        id: 'prefer_not',
        title: 'Prefer not to answer',
        description:
            'I prefer not to share my contraception history, which is completely fine.',
      ),
    ],
  ),

  // 14
  OnboardingStep(
    id: 'health_conditions',
    type: OnboardingStepType.question,
    title: 'Do you have any of these reproductive health conditions?',
    description:
        'Conditions like PCOS or endometriosis are very common and can affect cycle regularity. Telling us helps us fine-tune your tracking.',
    selectionType: OnboardingSelectionType.multiple,
    options: [
      OnboardingOption(
        id: 'endometriosis',
        title: 'Endometriosis',
        description:
            'I have been medically diagnosed with tissue growing outside the uterus, which can cause pelvic discomfort.',
      ),
      OnboardingOption(
        id: 'pcos',
        title: 'Polycystic ovary syndrome (PCOS)',
        description:
            'I have a diagnosed hormonal balance condition that often leads to longer, irregular, or skipped menstrual cycles.',
      ),
      OnboardingOption(
        id: 'fibroids',
        title: 'Fibroids',
        description:
            'A doctor has diagnosed me with non-cancerous growths inside or around the walls of my uterus.',
      ),
      OnboardingOption(
        id: 'not_sure',
        title: 'I’m not sure',
        description:
            'I often notice uncomfortable cycle symptoms or irregularity, but I have never received a formal diagnosis.',
        isExclusive: true,
      ),
      OnboardingOption(
        id: 'other',
        title: 'Something else',
        description:
            'I have another reproductive health condition that is not listed here.',
        isExclusive: true,
      ),
      OnboardingOption(
        id: 'none',
        title: 'No, I don’t have a health condition',
        description:
            'To the best of my knowledge, I do not have any reproductive or hormonal conditions.',
        isExclusive: true,
      ),
    ],
  ),

  OnboardingStep(
    id: 'health_condition_support',
    type: OnboardingStepType.education,

    richTitle: OnboardingRichText(
      firstPart: 'You’ll get ',
      highlightedPart: 'support',
      middlePart: ' from content by EezyCycle doctors and connect with ',
      secondHighlightedPart: 'EezyCycle community members',
    ),

    richDescription: OnboardingRichText(
      firstPart: 'who are going through ',
      highlightedPart: 'the same condition',
      middlePart: '',
      secondHighlightedPart: '',
    ),
    image: AppImages.eezycycleDoctor,
    canSkip: false,
    showProgress: false,
    countsTowardProgress: false,
  ),
  // 16
  OnboardingStep(
    id: 'fertility_result',
    type: OnboardingStepType.insight,

    richTitle: OnboardingRichText(
      firstPart: 'Your best days to get pregnant start around ',
      highlightedPart: '22 August',
    ),

    richDescription: OnboardingRichText(
      firstPart:
          'Based on your cycle information, having intercourse during this upcoming window gives you the ',
      highlightedPart: 'highest mathematical chance',
      middlePart: ' of conceiving.',
    ),
    image: AppImages.fertilityResult,
    countsTowardProgress: false,
    canSkip: false,
  ),

  // 17
  OnboardingStep(
    id: 'cycle_phase',
    type: OnboardingStepType.insight,

    richTitle: OnboardingRichText(
      firstPart: 'You’re currently in the ',
      highlightedPart: 'follicular phase',
      middlePart: ' of your cycle',
    ),

    richDescription: OnboardingRichText(
      firstPart: 'During this time, your ',
      highlightedPart: 'estrogen levels',
      middlePart:
          ' gradually rise as your ovaries prepare to release a mature, healthy egg for fertilization.',
    ),

    image: AppImages.follicularPhase,
    countsTowardProgress: false,
    canSkip: false,
  ),
  // 18
  // 18
  OnboardingStep(
    id: 'fertility_reminders',
    type: OnboardingStepType.reminder,

    richTitle: OnboardingRichText(
      firstPart: 'Want reminders for ',
      highlightedPart: 'fertile days',
      middlePart: ' and pregnancy tests?',
    ),

    richDescription: OnboardingRichText(
      firstPart: 'Get gentle, timely ',
      highlightedPart: 'notifications',
      middlePart:
          ' to help you stay on track with your fertile window and pregnancy tests.',
    ),

    image: AppImages.cycleFertility,
    countsTowardProgress: false,
    canSkip: false,
  ),

  // 19
  OnboardingStep(
    id: 'discharge',
    type: OnboardingStepType.question,
    title:
        'Did you know that your discharge can tell you the best days to get pregnant?',
    description:
        'Your body naturally produces different types of cervical fluid throughout your cycle to help nourish and guide sperm to the egg.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'yes',
        title: 'Yes',
        description:
            'I know that clear, slippery, egg-white discharge is a natural signal that ovulation is happening right now.',
      ),
      OnboardingOption(
        id: 'no',
        title: 'No',
        description:
            'I did not realize that natural changes in discharge can show exactly when I am entering my fertile window.',
      ),
    ],
  ),

  // 20
  OnboardingStep(
    id: 'body_signals',
    type: OnboardingStepType.education,

    richTitle: OnboardingRichText(
      firstPart: 'Know the best time to get pregnant using your ',
      highlightedPart: 'body’s natural signals',
      middlePart: '',
    ),

    richDescription: OnboardingRichText(
      firstPart: 'Changes in ',
      highlightedPart: 'body temperature and cervical fluid',
      middlePart:
          ' can help you identify when ovulation is approaching and pinpoint your most fertile days.',
    ),

    image: AppImages.bodySignals,
    countsTowardProgress: false,
    canSkip: false,
  ),

  // 21
  OnboardingStep(
    id: 'pregnancy_support',
    type: OnboardingStepType.education,

    richTitle: OnboardingRichText(
      firstPart: 'Stay ',
      highlightedPart: 'supported throughout pregnancy',
      middlePart: ' too',
    ),

    richDescription: OnboardingRichText(
      firstPart: 'After your ',
      highlightedPart: 'positive pregnancy test',
      middlePart:
          ', EezyCare smoothly switches to pregnancy mode to follow weekly baby growth, trimester milestones, and your symptoms.',
    ),

    image: AppImages.pregnancySupport,
    countsTowardProgress: false,
    canSkip: false,
  ),

  // 22
  OnboardingStep(
    id: 'healthcare_recommendation',
    type: OnboardingStepType.question,
    title: 'Was Eezy recommended to you by a healthcare professional?',
    description:
        'This quick check helps us see how often doctors, midwives, and fertility clinics recommend our tracking tools to their patients.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'yes',
        title: 'Yes',
        description:
            'A doctor, gynecologist, midwife, or nurse suggested that I use EezyCycle to track my fertility.',
      ),
      OnboardingOption(
        id: 'no',
        title: 'No',
        description:
            'I found EezyCycle on my own through the app store, online research, or recommendations from friends and family.',
      ),
    ],
  ),

  // 23
  OnboardingStep(
    id: 'testimonial',
    type: OnboardingStepType.testimonial,

    richTitle: OnboardingRichText(
      firstPart: 'I’ve seen how Eezy helps women ',
      highlightedPart: 'prepare for pregnancy',
      middlePart: '',
    ),

    richDescription: OnboardingRichText(
      firstPart:
          '“As an OB-GYN, I always recommend understanding your cycle early. Eezy makes daily fertility tracking practical, stress-free, and medically grounded.” ',
      highlightedPart: '— Dr. Sarah Jenkins',
      middlePart: '',
    ),

    image: AppImages.eezycycleDoctor,
    countsTowardProgress: false,
    canSkip: false,
  ),

  // 24
  OnboardingStep(
    id: 'lifestyle_intro',
    type: OnboardingStepType.sectionIntro,

    richTitle: OnboardingRichText(
      firstPart: 'Finally, we’ll do a quick ',
      highlightedPart: 'health & lifestyle check-in',
      middlePart: '',
    ),

    richDescription: OnboardingRichText(
      firstPart: 'Small everyday habits like ',
      highlightedPart: 'nutrition, movement, and vitamins',
      middlePart:
          ' can support your overall reproductive health and help you prepare for pregnancy.',
    ),

    image: AppImages.eezycycleDoctor,
    countsTowardProgress: false,
    canSkip: false,
  ),

  // 25
  OnboardingStep(
    id: 'height',
    type: OnboardingStepType.measurement,
    title: 'How tall are you?',
    description:
        'We combine your height with your weight to understand your general body profile and offer safe, personalized health recommendations.',
  ),
  //
  // // 26
  // OnboardingStep(
  //   id: 'weight',
  //   type: OnboardingStepType.measurement,
  //   title: 'How much do you weigh?',
  //   description:
  //       'A healthy body weight supports consistent ovulation. Sharing this helps us provide practical lifestyle tips tailored to you.',
  // ),

  // 27
  OnboardingStep(
    id: 'prenatal_vitamins',
    type: OnboardingStepType.question,
    title: 'Do you take any prenatal vitamins or supplements?',
    description:
        'Starting essential vitamins a few months before getting pregnant gives your body the nutrients it needs right from day one.',
    selectionType: OnboardingSelectionType.multiple,
    options: [
      OnboardingOption(
        id: 'folic_acid',
        title: 'Yes, folic acid',
        description:
            'I take daily folic acid to support early fetal development and help prevent neural tube defects.',
      ),
      OnboardingOption(
        id: 'multivitamin',
        title: 'Yes, a prenatal multivitamin',
        description:
            'I take a daily prenatal vitamin that includes essential nutrients like iron, vitamin D, and DHA.',
      ),
      OnboardingOption(
        id: 'none',
        title: 'No',
        description:
            'I am not taking any prenatal vitamins right now, but I would like to know what is recommended.',
        isExclusive: true,
      ),
    ],
  ),

  // 28
  OnboardingStep(
    id: 'pre_pregnancy_checkup',
    type: OnboardingStepType.question,
    title: 'Have you had a pre-pregnancy checkup?',
    description:
        'A quick preconception visit with your doctor is a great way to review overall health, medications, and routine blood tests before conceiving.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'yes',
        title: 'Yes',
        description:
            'I have already met with my doctor to review my health, bloodwork, and medications before trying to conceive.',
      ),
      OnboardingOption(
        id: 'not_yet',
        title: 'Not yet',
        description:
            'I haven’t scheduled a preconception appointment yet, but I am open to discussing it with a doctor soon.',
      ),
      OnboardingOption(
        id: 'waiting',
        title: 'I’m waiting for an appointment',
        description:
            'I have already booked my preconception appointment and am just waiting for the scheduled visit date.',
      ),
      OnboardingOption(
        id: 'not_necessary',
        title: 'I didn’t think it was necessary',
        description:
            'I feel healthy and didn’t realize doctors recommend having a quick checkup before trying to get pregnant.',
      ),
    ],
  ),

  // 29
  OnboardingStep(
    id: 'partner_preparation',
    type: OnboardingStepType.question,
    title: 'Has your partner made any changes to prepare for conception?',
    description:
        'Healthy sperm makes up half the equation, and simple lifestyle adjustments by your partner can make a positive difference in sperm health.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'yes',
        title: 'Yes, they have',
        description:
            'My partner has started eating better, taking vitamins, exercising, or cutting down on alcohol and smoking.',
      ),
      OnboardingOption(
        id: 'didnt_know',
        title: 'I didn’t know they needed to',
        description:
            'I thought conception preparation was mainly about the woman and didn’t know male habits also play a big role.',
      ),
      OnboardingOption(
        id: 'dont_participate',
        title: 'They don’t take part in conception',
        description:
            'We are using donor sperm or an alternative path where partner lifestyle changes do not apply.',
      ),
      OnboardingOption(
        id: 'no_partner',
        title: 'I don’t have a partner at the moment',
        description:
            'I am on this journey on my own with the support of a fertility clinic or donor program.',
      ),
      OnboardingOption(
        id: 'no',
        title: 'No',
        description:
            'My partner hasn’t made any specific lifestyle or habit changes for conception so far.',
      ),
    ],
  ),

  // 30
  OnboardingStep(
    id: 'healthy_diet',
    type: OnboardingStepType.question,
    title: 'Do you feel you have a healthy diet?',
    description:
        'Eating a balanced variety of nutritious foods helps balance hormones, support egg quality, and prepare your body for pregnancy.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'yes',
        title: 'Yes',
        description:
            'I regularly enjoy balanced meals filled with whole foods, fresh vegetables, lean proteins, and plenty of water.',
      ),
      OnboardingOption(
        id: 'not_really',
        title: 'Not really',
        description:
            'I tend to eat on the go, often have processed meals or sugary snacks, and know my nutrition could be improved.',
      ),
      OnboardingOption(
        id: 'not_sure',
        title: 'I’m not sure',
        description:
            'I eat a normal routine but would love clear, practical tips on which fertility-friendly foods make the most difference.',
      ),
    ],
  ),

  // 31
  OnboardingStep(
    id: 'conception_sex',
    type: OnboardingStepType.question,
    title: 'Is there anything you’d like to know about conception sex?',
    description:
        'Select any topics you are curious about to receive straightforward, doctor-verified answers directly in your daily feed.',
    selectionType: OnboardingSelectionType.multiple,
    options: [
      OnboardingOption(
        id: 'best_position',
        title: 'Is there a best sex position for getting pregnant?',
        description:
            'No single position has been proven better than others. As long as sperm is deposited near the cervix, your chances remain just as high.',
      ),
      OnboardingOption(
        id: 'orgasm',
        title: 'Do orgasms boost my odds of conception?',
        description:
            'While orgasms make sex enjoyable and reduce stress, there is no medical evidence showing that a female orgasm is required for conception.',
      ),
      OnboardingOption(
        id: 'sex_frequency',
        title: 'How often should we have sex when trying to conceive?',
        description:
            'Having intercourse every 1 to 2 days during your fertile window gives you the best chance without draining your energy or lowering sperm count.',
      ),
      OnboardingOption(
        id: 'sex_after_ovulation',
        title: 'Does having sex after ovulation help?',
        description:
            'An egg only survives for about 12 to 24 hours after release, so having sex in the days leading up to ovulation matters much more than after.',
      ),
      OnboardingOption(
        id: 'lubricants',
        title: 'Can lubricants affect my chances of getting pregnant?',
        description:
            'Yes, some regular lubricants can slow down sperm movement. Using fertility-friendly lubricants ensures sperm can swim freely toward the egg.',
      ),
      OnboardingOption(
        id: 'sex_pain',
        title: 'Is painful sex normal when trying to conceive?',
        description:
            'No, sex should never be painful. Discomfort can be a sign of an underlying issue like endometriosis or an infection and is always worth checking with a doctor.',
      ),
    ],
  ),
];

final partnerOnboardingSteps = <OnboardingStep>[
  // 1
  OnboardingStep(
    id: 'partner_goals',
    type: OnboardingStepType.question,
    title: 'What can EezyCycle help you do?',
    description:
        'We’re asking to make sure we understand your goals. Choose as many as you’d like.',
    selectionType: OnboardingSelectionType.multiple,
    options: [
      OnboardingOption(
        id: 'plan_partner_cycle',
        title: 'Plan around my partner’s cycle',
        description:
            'Understand where your partner is in her cycle so you can plan and support her better.',
      ),
      OnboardingOption(
        id: 'learn_cycle_science',
        title: 'Learn the science behind her cycle and symptoms',
        description:
            'Understand how hormonal changes throughout the cycle can affect her body and symptoms.',
      ),
      OnboardingOption(
        id: 'understand_support',
        title: 'Understand my partner so I can better support her',
        description:
            'Learn practical ways to be more thoughtful and supportive throughout different parts of her cycle.',
      ),
      OnboardingOption(
        id: 'communication',
        title: 'Improve our communication',
        description:
            'Learn how to have better conversations about her needs, emotions, health, and well-being.',
      ),
      OnboardingOption(
        id: 'anticipate_feelings',
        title: 'Anticipate how my partner may be feeling',
        description:
            'Learn how cycle-related changes may influence mood, energy, and physical symptoms.',
      ),
      OnboardingOption(
        id: 'sex_life',
        title: 'Improve our sex lives',
        description:
            'Learn more about desire, communication, intimacy, and ways to strengthen your connection.',
      ),
    ],
  ),

  // 2
  OnboardingStep(
    id: 'partner_symptoms',
    type: OnboardingStepType.question,
    title: 'Does your partner experience any of the following?',
    description: 'Choose as many as you’d like.',
    selectionType: OnboardingSelectionType.multiple,
    options: [
      OnboardingOption(
        id: 'cramps_backache',
        title: 'Cramps or backache',
        description:
            'Your partner sometimes experiences cramps or lower-back discomfort around her period.',
      ),
      OnboardingOption(
        id: 'headache',
        title: 'Headache',
        description:
            'Your partner sometimes experiences headaches around different stages of her cycle.',
      ),
      OnboardingOption(
        id: 'mood_swings',
        title: 'Mood swings',
        description:
            'Your partner notices changes in her mood during parts of her cycle.',
      ),
      OnboardingOption(
        id: 'tender_breasts',
        title: 'Tender breasts',
        description:
            'Your partner experiences breast tenderness or sensitivity during her cycle.',
      ),
      OnboardingOption(
        id: 'cravings',
        title: 'Cravings',
        description:
            'Your partner experiences noticeable food cravings during parts of her cycle.',
      ),
      OnboardingOption(
        id: 'fatigue',
        title: 'Fatigue',
        description:
            'Your partner sometimes feels unusually tired or low on energy.',
      ),
      OnboardingOption(
        id: 'none',
        title: 'None of these',
        description:
            'My partner does not usually experience any of these symptoms.',
        isExclusive: true,
      ),
    ],
  ),

  // 3
  OnboardingStep(
    id: 'partner_symptoms_education',
    type: OnboardingStepType.education,
    richTitle: OnboardingRichText(
      firstPart: 'It’s great you know your ',
      highlightedPart: 'partner',
      middlePart: ' like you do!',
    ),
    richDescription: OnboardingRichText(
      firstPart: 'We’ll show you how ',
      highlightedPart: 'her cycle may impact how she feels',
      middlePart: ' and give you practical tips to help you support her.',
    ),
    image: AppImages.bodySignals,
    canSkip: false,
    showProgress: false,
    countsTowardProgress: false,
  ),

  // 4
  OnboardingStep(
    id: 'partner_reminders',
    type: OnboardingStepType.reminder,
    richTitle: OnboardingRichText(
      firstPart: 'Know what your partner needs ',
      highlightedPart: 'without her having to ask',
    ),
    richDescription: OnboardingRichText(
      firstPart: 'Allow notifications to stay in the loop on your ',
      highlightedPart: 'partner’s cycle',
      middlePart:
          ' so you can know when to plan something together, give her a break, or simply give her some space.',
    ),
    image: AppImages.cycleFertility,
    countsTowardProgress: false,
    canSkip: false,
  ),

  // 5
  OnboardingStep(
    id: 'fertility_knowledge',
    type: OnboardingStepType.question,
    title:
        'Did you know there are days when your partner is more or less likely to get pregnant?',
    description:
        'Understanding the fertile window can help you better understand your partner’s cycle and plan together.',
    selectionType: OnboardingSelectionType.single,
    options: [
      OnboardingOption(
        id: 'yes',
        title: 'Yes',
        description:
            'I already know that pregnancy is more likely during certain days of the menstrual cycle.',
      ),
      OnboardingOption(
        id: 'no',
        title: 'No',
        description:
            'I didn’t know that the chances of pregnancy change throughout the cycle.',
      ),
    ],
  ),

  // 6
  OnboardingStep(
    id: 'sex_life_goals',
    type: OnboardingStepType.question,
    title:
        'Would you and your partner like to change anything about your sex lives?',
    description:
        'We’re asking so we can personalize the education and relationship tips you receive.',
    selectionType: OnboardingSelectionType.multiple,
    options: [
      OnboardingOption(
        id: 'new_positions',
        title: 'Try new positions',
        description:
            'Explore new ways to keep intimacy fun and comfortable for both of you.',
      ),
      OnboardingOption(
        id: 'sex_communication',
        title: 'Improve our communication about sex',
        description:
            'Become more comfortable talking openly about preferences, boundaries, and desires.',
      ),
      OnboardingOption(
        id: 'increase_pleasure',
        title: 'Increase our pleasure together',
        description:
            'Learn more about mutual pleasure and creating a more satisfying intimate connection.',
      ),
      OnboardingOption(
        id: 'understand_desires',
        title: 'Better understand each other’s desires',
        description: 'Learn how to talk about what you both want and enjoy.',
      ),
      OnboardingOption(
        id: 'nothing',
        title: 'We’re happy with our sex life',
        description: 'We’re not looking to change anything right now.',
        isExclusive: true,
      ),
    ],
  ),

  // 7
  OnboardingStep(
    id: 'sex_life_education',
    type: OnboardingStepType.education,
    richTitle: OnboardingRichText(
      firstPart: 'Strengthen your ',
      highlightedPart: 'connection',
      middlePart: ' and sex life',
    ),
    richDescription: OnboardingRichText(
      firstPart:
          'Get tips for having open and honest conversations about intimacy, desires, and new things to try together.',
      highlightedPart: '',
    ),
    image: AppImages.bodySignals,
    canSkip: false,
    showProgress: false,
    countsTowardProgress: false,
  ),

  // 8
  OnboardingStep(
    id: 'partner_cycle_understanding',
    type: OnboardingStepType.sectionIntro,
    richTitle: OnboardingRichText(
      firstPart: 'Understand ',
      highlightedPart: 'her cycle',
      middlePart: ' a little better',
    ),
    richDescription: OnboardingRichText(
      firstPart:
          'Your partner’s cycle can influence her body, energy, mood, and symptoms. We’ll help you understand these changes without making assumptions about how she feels.',
      highlightedPart: '',
    ),
    image: AppImages.cycleFertility,
    canSkip: false,
    showProgress: false,
    countsTowardProgress: false,
  ),

  // 9
  OnboardingStep(
    id: 'partner_cycle_education',
    type: OnboardingStepType.education,
    richTitle: OnboardingRichText(
      firstPart: 'Learn what happens during ',
      highlightedPart: 'each cycle phase',
    ),
    richDescription: OnboardingRichText(
      firstPart:
          'Understand the basic hormonal and physical changes that can happen throughout the menstrual cycle and how you can be supportive.',
      highlightedPart: '',
    ),
    image: AppImages.follicularPhase,
    canSkip: false,
    showProgress: false,
    countsTowardProgress: false,
  ),

  // 10
  OnboardingStep(
    id: 'support_style',
    type: OnboardingStepType.question,
    title: 'How would you like to support your partner?',
    description:
        'Choose the kinds of support you’d like EezyCycle to help you with.',
    selectionType: OnboardingSelectionType.multiple,
    options: [
      OnboardingOption(
        id: 'emotional_support',
        title: 'Be more emotionally supportive',
        description:
            'Understand how to listen and respond when your partner needs emotional support.',
      ),
      OnboardingOption(
        id: 'practical_help',
        title: 'Know when to offer practical help',
        description:
            'Learn simple ways to make things easier when your partner is tired or uncomfortable.',
      ),
      OnboardingOption(
        id: 'give_space',
        title: 'Know when to give her space',
        description:
            'Understand that sometimes support means giving your partner time and personal space.',
      ),
      OnboardingOption(
        id: 'spend_time',
        title: 'Plan quality time together',
        description:
            'Find better ways to spend time together based on what works for both of you.',
      ),
      OnboardingOption(
        id: 'communication',
        title: 'Communicate better',
        description:
            'Build healthier conversations around feelings, needs, and expectations.',
      ),
    ],
  ),

  // 11
  OnboardingStep(
    id: 'partner_success',
    type: OnboardingStepType.testimonial,
    richTitle: OnboardingRichText(
      firstPart: 'A better understanding can create a ',
      highlightedPart: 'stronger relationship',
    ),
    richDescription: OnboardingRichText(
      firstPart:
          'When partners understand each other better, small moments of support can make a big difference in everyday life.',
      highlightedPart: '',
    ),
    image: AppImages.eezycycleDoctor,
    countsTowardProgress: false,
    canSkip: false,
  ),

  // 12
  OnboardingStep(
    id: 'partner_setup_complete',
    type: OnboardingStepType.insight,
    richTitle: OnboardingRichText(
      firstPart: 'We’re setting up ',
      highlightedPart: 'EezyCycle for both of you',
    ),
    richDescription: OnboardingRichText(
      firstPart:
          'Gathering personalized tips for you both\n\n'
          'Helping you understand her cycle\n\n'
          'Improving your communication\n\n'
          'Strengthening your bond',
      highlightedPart: '',
    ),
    image: AppImages.fertilityResult,
    countsTowardProgress: false,
    canSkip: false,
  ),
];

final trackCycleOnboardingSteps = <OnboardingStep>[
  // 1. Education / Intro Screen
  OnboardingStep(
    id: 'track_cycle_intro',
    type: OnboardingStepType.education,
    title: "Everyone's health journey is unique",
    description:
        "We're here to support you on yours. Next, we'll ask a couple quick questions about your goals.",
    image: AppImages.cycleFertility, // Or appropriate illustration asset
    showProgress: true,
    canSkip: false,
    countsTowardProgress: true,
  ),

  // 2. Question: How are you feeling today? (Single Selection)
  OnboardingStep(
    id: 'track_cycle_feeling',
    type: OnboardingStepType.question,
    title: 'How are you feeling today?',
    description:
        'Understanding your current state helps us tailor your daily insights.',
    selectionType: OnboardingSelectionType.single,
    showProgress: true,
    canSkip: true,
    countsTowardProgress: true,
    options: [
      OnboardingOption(
        id: 'energized',
        title: 'Energized and strong',
        description: 'Feeling ready to take on the day with steady momentum.',
      ),
      OnboardingOption(
        id: 'calm',
        title: 'Calm and relaxed',
        description: 'Enjoying a peaceful mindset and balanced energy.',
      ),
      OnboardingOption(
        id: 'worried',
        title: 'Worried or stressed',
        description:
            'Navigating some tension or physical discomfort right now.',
      ),
      OnboardingOption(
        id: 'mixed',
        title: 'A mix of everything',
        description:
            'Emotions and physical energy shifting throughout the day.',
      ),
    ],
  ),

  // 3. Question: What are your goals at the moment? (Multi Selection)
  OnboardingStep(
    id: 'track_cycle_goals',
    type: OnboardingStepType.question,
    title: 'What are your goals at the moment?',
    description: 'Choose as many as you like.',
    selectionType: OnboardingSelectionType.multiple,
    showProgress: true,
    canSkip: true,
    countsTowardProgress: true,
    options: [
      OnboardingOption(
        id: 'goal_sleep',
        title: 'Sleep better and boost energy',
        description:
            'Optimize recovery and circadian rhythm across cycle phases.',
      ),
      OnboardingOption(
        id: 'goal_mood',
        title: 'Understand my mood and symptoms better',
        description:
            'Track patterns behind hormonal shifts and emotional changes.',
      ),
      OnboardingOption(
        id: 'goal_sex',
        title: 'Enhance my sex life',
        description:
            'Track drive, intimacy, and phase-based connection windows.',
      ),
      OnboardingOption(
        id: 'goal_weight',
        title: 'Maintain a healthy weight',
        description: 'Align nutrition and workouts with metabolic changes.',
      ),
      OnboardingOption(
        id: 'goal_period',
        title: 'Know when my period is coming',
        description: 'Plan ahead with accurate upcoming cycle alerts.',
      ),
      OnboardingOption(
        id: 'goal_other',
        title: 'Something else',
        description:
            'Personalized tracking tailored to your specific wellness focus.',
        isExclusive: true,
      ),
    ],
  ),

  // 4. Content / Value Proposition Screen
  OnboardingStep(
    id: 'track_cycle_value_prop',
    type: OnboardingStepType.testimonial,
    title: 'Get personalized cycle support when you need it',
    description:
        '• Plan ahead with accurate period predictions and symptom insights.\n\n'
        '• Access 1,000+ medically verified insights on mood, sleep, sex, weight, and more.\n\n'
        '• Get in-the-moment, proactive insights with your virtual Health Assistant.',
    image: AppImages.bodySignals,
    showProgress: true,
    canSkip: false,
    countsTowardProgress: true,
  ),

  // 5. Notification permission value screen
  OnboardingStep(
    id: 'track_cycle_reminders',
    type: OnboardingStepType.reminder,
    richTitle: OnboardingRichText(
      firstPart: 'Want gentle ',
      highlightedPart: 'period reminders',
      middlePart: '?',
    ),
    richDescription: OnboardingRichText(
      firstPart: 'Allow ',
      highlightedPart: 'notifications',
      middlePart:
          ' so we can nudge you before your period and fertile days (estimates only).',
    ),
    image: AppImages.cycleFertility,
    countsTowardProgress: false,
    canSkip: false,
  ),
];

final getPregnantOnboardingSteps = <OnboardingStep>[
  // 1. Congratulations Intro
  OnboardingStep(
    id: 'gp_intro',
    type: OnboardingStepType.education,
    richTitle: OnboardingRichText(
      firstPart: 'Congratulations on ',
      highlightedPart: 'taking the next step',
    ),
    description:
        "Everyone's journey to pregnancy is unique. We're here to support you on yours.",
    image: AppImages.cycleFertility,
    showProgress: true,
    canSkip: false,
    countsTowardProgress: true,
  ),

  // 2. Social Proof
  OnboardingStep(
    id: 'gp_social_proof',
    type: OnboardingStepType.socialProof,
    richTitle: OnboardingRichText(
      firstPart: 'Join over ',
      highlightedPart: '10 million people',
      middlePart:
          ' who used EezyCycle to support them on their journey to pregnancy',
    ),
    image: AppImages.conceptionSocialProof,
    showProgress: false,
    canSkip: false,
    countsTowardProgress: false,
  ),

  // 3. Privacy Education
  OnboardingStep(
    id: 'gp_privacy',
    type: OnboardingStepType.education,
    icon: Icons.lock_outline_rounded,
    richTitle: OnboardingRichText(
      firstPart: 'Your body, ',
      highlightedPart: 'your data',
    ),
    richDescription: OnboardingRichText(
      firstPart:
          '• We never sell your data.\n\n'
          '• You can delete your data at any time.\n\n'
          '• Your data is always encrypted.',
    ),
    showProgress: false,
    canSkip: false,
    countsTowardProgress: false,
  ),

  // 4. Timeline Question
  OnboardingStep(
    id: 'gp_timeline',
    type: OnboardingStepType.question,
    title: 'How soon do you want to get pregnant?',
    selectionType: OnboardingSelectionType.single,
    showProgress: true,
    canSkip: true,
    countsTowardProgress: true,
    options: [
      OnboardingOption(
        id: 'asap',
        title: 'As soon as possible',
        description: 'Ready to conceive right away.',
      ),
      OnboardingOption(
        id: 'not_in_rush',
        title: 'I\'m not in a rush - I\'m here to learn more about conception',
        description:
            'Taking a relaxed approach and exploring how conception works.',
      ),
    ],
  ),

  // 5. Trying Duration Question
  OnboardingStep(
    id: 'gp_trying_duration',
    type: OnboardingStepType.question,
    title: 'How long have you been trying to get pregnant?',
    selectionType: OnboardingSelectionType.single,
    showProgress: true,
    canSkip: true,
    countsTowardProgress: true,
    options: [
      OnboardingOption(
        id: 'just_started',
        title: 'I\'ve just started trying',
        description: 'In our very first cycle.',
      ),
      OnboardingOption(
        id: 'zero_to_three',
        title: '0 to 3 months',
        description: 'Trying for 1 to 3 cycles.',
      ),
      OnboardingOption(
        id: 'four_to_six',
        title: '4 to 6 months',
        description: 'Trying for half a year.',
      ),
      OnboardingOption(
        id: 'seven_to_twelve',
        title: '7 months to a year',
        description: 'Approaching the twelve-month mark.',
      ),
      OnboardingOption(
        id: 'over_year',
        title: 'Over a year',
        description: 'Looking for deeper clinical guidance.',
      ),
    ],
  ),

  // 6. Unlock Insights Education
  OnboardingStep(
    id: 'gp_insights_edu',
    type: OnboardingStepType.education,
    richTitle: OnboardingRichText(
      firstPart: 'Unlock 1,000+ insights to support your ',
      highlightedPart: 'fertility journey',
    ),
    description:
        'Learn from expert-led courses and articles to explore ways to increase your chances and help you prepare for pregnancy.',
    image: AppImages.expertPregnancyQuestions,
    showProgress: false,
    canSkip: false,
    countsTowardProgress: false,
  ),

  // 7. Vitamins & Supplements (Multiple with Exclusive None)
  OnboardingStep(
    id: 'gp_vitamins',
    type: OnboardingStepType.question,
    title: 'Do you take any conception-specific vitamins or supplements?',
    selectionType: OnboardingSelectionType.multiple,
    showProgress: true,
    canSkip: true,
    countsTowardProgress: true,
    options: [
      OnboardingOption(
        id: 'prenatal',
        title: 'Yes, a prenatal multivitamin',
        description: 'Taking essential daily nutrients.',
      ),
      OnboardingOption(
        id: 'folic_acid',
        title: 'I take folic acid',
        description: 'Supporting early fetal development.',
      ),
      OnboardingOption(
        id: 'none',
        title: 'I don\'t take any vitamins or supplements',
        description: 'Not currently taking any supplements.',
        isExclusive: true,
      ),
    ],
  ),

  // 8. Pre-pregnancy checkup Question
  OnboardingStep(
    id: 'gp_checkup',
    type: OnboardingStepType.question,
    title: 'Have you had a prepregnancy checkup?',
    description:
        'This is when a health care professional makes sure you\'re healthy and ready for pregnancy.',
    selectionType: OnboardingSelectionType.single,
    showProgress: true,
    canSkip: true,
    countsTowardProgress: true,
    options: [
      OnboardingOption(
        id: 'yes',
        title: 'Yes',
        description: 'Already completed a visit.',
      ),
      OnboardingOption(
        id: 'not_yet',
        title: 'Not yet',
        description: 'Havent scheduled one yet.',
      ),
      OnboardingOption(
        id: 'waiting',
        title: 'I\'m waiting for an appointment',
        description: 'Booked and scheduled.',
      ),
      OnboardingOption(
        id: 'not_necessary',
        title: 'I didn\'t think it was necessary',
        description: 'Felt healthy overall.',
      ),
    ],
  ),

  // 9. Partner Preparation Question
  OnboardingStep(
    id: 'gp_partner',
    type: OnboardingStepType.question,
    title:
        'Has your partner made any changes to prepare for trying to get pregnant?',
    selectionType: OnboardingSelectionType.single,
    showProgress: true,
    canSkip: true,
    countsTowardProgress: true,
    options: [
      OnboardingOption(
        id: 'yes',
        title: 'Yes, they have',
        description: 'Lifestyle adjustments underway.',
      ),
      OnboardingOption(
        id: 'didnt_know',
        title: 'I didn\'t know they needed to',
        description: 'Unaware of male health factors.',
      ),
      OnboardingOption(
        id: 'dont_take_part',
        title: 'They don\'t take part in conception',
        description: 'Donor or alternative path.',
      ),
      OnboardingOption(
        id: 'no_partner',
        title: 'I don\'t have a partner at the moment',
        description: 'Conceiving independently.',
      ),
      OnboardingOption(
        id: 'no',
        title: 'No',
        description: 'No changes made so far.',
      ),
    ],
  ),

  // 10. Healthy Diet Question
  OnboardingStep(
    id: 'gp_diet',
    type: OnboardingStepType.question,
    title: 'Do you feel you have a healthy diet?',
    description:
        'What you eat is an important factor in being healthy and ready for pregnancy.',
    selectionType: OnboardingSelectionType.single,
    showProgress: true,
    canSkip: true,
    countsTowardProgress: true,
    options: [
      OnboardingOption(
        id: 'yes',
        title:
            'Yes - I\'ve already made positive changes in my diet to get ready for conception',
        description: 'Eating whole, balanced foods.',
      ),
      OnboardingOption(
        id: 'not_really',
        title: 'Not really - I could be eating better',
        description: 'Diet needs some improvement.',
      ),
      OnboardingOption(
        id: 'not_sure',
        title:
            'I\'m not sure - I\'d like to learn what I could change about my diet',
        description: 'Open to nutritional guidance.',
      ),
    ],
  ),

  // 11. Conception Sex Questions (Multiple with Exclusive None)
  OnboardingStep(
    id: 'gp_sex_questions',
    type: OnboardingStepType.question,
    title: 'Would you like to learn more about sex for pregnancy?',
    description:
        'Our sex experts have created articles, videos, and guides to answer your most intimate questions.',
    selectionType: OnboardingSelectionType.multiple,
    showProgress: true,
    canSkip: true,
    countsTowardProgress: true,
    options: [
      OnboardingOption(
        id: 'best_position',
        title: 'Is there a best sex position for getting pregnant?',
        description: 'Clearing up common posture myths.',
      ),
      OnboardingOption(
        id: 'orgasm_odds',
        title: 'Do orgasms boost your odds of conception?',
        description: 'Understanding the biological mechanics.',
      ),
      OnboardingOption(
        id: 'pee_shower',
        title: 'Is it OK to pee or shower after sex?',
        description: 'Hygiene tips during trying phase.',
      ),
      OnboardingOption(
        id: 'lubes_sperm',
        title: 'Do some lubes have a negative effect on sperm?',
        description: 'Choosing fertility-friendly lubricants.',
      ),
      OnboardingOption(
        id: 'not_having_sex',
        title: 'I\'m not having sex for conception',
        description: 'Alternative conception methods.',
        isExclusive: true,
      ),
      OnboardingOption(
        id: 'no_questions',
        title: 'No, I don\'t have any questions',
        description: 'Skip sex education modules.',
        isExclusive: true,
      ),
    ],
  ),

  // 12. Expert Support Education
  OnboardingStep(
    id: 'gp_expert_support',
    type: OnboardingStepType.education,
    richTitle: OnboardingRichText(
      firstPart: 'Expert support and fertility insights ',
      highlightedPart: 'you can rely on',
    ),
    description:
        'EezyCycle\'s medical experts are dedicated to supporting you on your journey to pregnancy, with articles, tips, and insights powered by your cycle data.',
    image: AppImages.eezycycleDoctor,
    showProgress: false,
    canSkip: false,
    countsTowardProgress: false,
  ),
];

final perimenopauseOnboardingSteps = <OnboardingStep>[
  // 1. Welcome Intro Screen
  OnboardingStep(
    id: 'peri_welcome',
    type: OnboardingStepType.education,
    richTitle: OnboardingRichText(
      firstPart: 'Welcome!\nWant to track your\n',
      highlightedPart: 'perimenopause journey?',
    ),
    description:
        "This part of EezyCycle works best if you're over 40 and have common symptoms of perimenopause.",
    image: AppImages.wellness,
    showProgress: true,
    canSkip: false,
    countsTowardProgress: true,
  ),

  // 2. Definition Education
  OnboardingStep(
    id: 'peri_definition',
    type: OnboardingStepType.education,
    richTitle: OnboardingRichText(
      firstPart: 'Perimenopause is your ',
      highlightedPart: 'transition through menopause',
    ),
    description:
        'It covers the years leading up to menopause — which is your last ever period — and the 12 months after.\n\n'
        'You\'ve reached menopause once you\'ve gone 12 months without a period.',
    image: AppImages.follicularPhase,
    showProgress: false,
    canSkip: false,
    countsTowardProgress: false,
  ),

  // 3. Live Your Best Life Education
  OnboardingStep(
    id: 'peri_live_best_life',
    type: OnboardingStepType.education,
    richTitle: OnboardingRichText(highlightedPart: 'Live your best life'),
    description:
        '• Learn about and log perimenopause symptoms.\n\n'
        '• Track changes to your period.\n\n'
        '• Understand how perimenopause can affect your mood, energy, and cycle.\n\n'
        '• Get medical insights you can trust from EezyCycle\'s health experts.',
    image: AppImages.bodySignals,
    showProgress: false,
    canSkip: false,
    countsTowardProgress: false,
  ),

  // 4. Data Continuity Education
  OnboardingStep(
    id: 'peri_data_continuity',
    type: OnboardingStepType.education,
    icon: Icons.sync_rounded,
    richTitle: OnboardingRichText(
      firstPart: 'Bring your ',
      highlightedPart: 'cycle data',
      middlePart: ' with you',
    ),
    description:
        'You won\'t lose any past period or symptom logs. Change your goal anytime in Settings.',
    showProgress: false,
    canSkip: false,
    countsTowardProgress: false,
  ),

  // 5. Got You Covered Education
  OnboardingStep(
    id: 'peri_covered',
    type: OnboardingStepType.education,
    richTitle: OnboardingRichText(
      firstPart: 'We\'ve got you covered\n',
      highlightedPart: 'Navigate your journey with confidence',
    ),
    description:
        'Get science-backed tips on sleep, nutrition, and weight — all tailored for your well-being.',
    image: AppImages.cycleFertility,
    showProgress: false,
    canSkip: false,
    countsTowardProgress: false,
  ),

  // 6. Symptom Checker Insight & Disclaimer
  OnboardingStep(
    id: 'peri_symptom_checker',
    type: OnboardingStepType.testimonial,
    richTitle: OnboardingRichText(
      firstPart: 'Get insights with\n',
      highlightedPart: 'Symptom Checker',
    ),
    description:
        'See if your symptoms match the common signs of perimenopause and what to do next.\n\n'
        'Note: Not available in the United Kingdom. Members in the European Union or European Economic Area can use the Symptom Checklist.',
    image: AppImages.expertPregnancyQuestions,
    showProgress: false,
    canSkip: false,
    countsTowardProgress: false,
  ),
];
