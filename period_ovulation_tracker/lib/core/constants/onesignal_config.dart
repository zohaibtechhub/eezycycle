/// OneSignal App ID from the dashboard (Settings → Keys & IDs).
///
/// Override at build time without editing this file:
/// `flutter run --dart-define=ONESIGNAL_APP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
const String kOneSignalAppId = String.fromEnvironment(
  'ONESIGNAL_APP_ID',
  defaultValue: '1b52f9bd-e3cb-43dd-ac33-8412e444edef',
);
