class AppImages {
  static const String _mainImage = "assets/images/";
  static const String baseUrlForImage = "https://api.eezybooking.com/";
  static const String _mainAnimations = "assets/animations/";
  static String svgImage(String fileName) => '$_mainImage$fileName.svg';
  static String pngImage(String fileName) => '$_mainImage$fileName.png';
  static String jpgImage(String fileName) => '$_mainImage$fileName.jpg';
  static String webpImage(String fileName) => '$_mainImage$fileName.webp';
  static String jsonAnimation(String fileName) => '$_mainImage$fileName.json';

  static final String logo = pngImage('logo');
  static final String google = pngImage('google');
  static final String womanAvatar = pngImage('woman-avatar');

  static final String birthControl = pngImage('birthControl');

  static final String decodeDischarge = pngImage('decodeDischarge');

  static final String enhanceSexLife = pngImage('enhanceSexLife');

  static final String getPregnant = pngImage('get-pregnant');

  static final String manageWeight = pngImage('manageWieght');

  static final String trackPeriod = pngImage('track-period');

  static final String trackPregnancy = pngImage('track-pregnancy');

  static final String wellness = pngImage('wellness');
  static final String conceptionSocialProof = pngImage('conceptionSocialProof');
  static final String cycleFertility = pngImage('cycleFertility');
  static final String trackFertility = pngImage('trackPeriods');
  static final String fertilityResult = pngImage('fertilityResult');
  static final String follicularPhase = pngImage('follicularPhase');
  static final String bodySignals = pngImage('bodySignals');
  static final String pregnancySupport = pngImage('pregnancySupport');
  static final String eezycycleDoctor = pngImage('eezycycleDoctor');
  static final String expertPregnancyQuestions = pngImage(
    'expertPregnancyQuestions',
  );

  ///Json Animation

  static final String confeti = jsonAnimation('confeti');
}
