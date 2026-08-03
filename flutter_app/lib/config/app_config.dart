/// API configuration constants.
///
/// The backend URL is selected automatically based on the FLAVOR dart-define:
///
///   emulator  (default) — Android emulator talking to host machine
///   simulator           — iOS simulator talking to localhost
///   device              — Physical device; reads DEVICE_IP dart-define
///
/// ## How to run
///
/// Android emulator (default — no flags needed):
///   flutter run
///
/// iOS simulator:
///   flutter run --dart-define=FLAVOR=simulator
///
/// Physical Android/iOS device (replace IP with your machine's local IP):
///   flutter run --dart-define=FLAVOR=device --dart-define=DEVICE_IP=192.168.1.5
///
/// Release build for physical device:
///   flutter build apk --dart-define=FLAVOR=device --dart-define=DEVICE_IP=192.168.1.5
class AppConfig {
  AppConfig._(); // prevent instantiation

  // ------------------------------------------------------------------
  // Build-time dart-defines (injected via --dart-define at run/build time)
  // ------------------------------------------------------------------

  /// Target environment. One of: emulator | simulator | device
  /// Defaults to 'emulator' if not provided.
  static const String _flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'emulator',
  );

  /// Host machine IP — only used when FLAVOR=device.
  /// Example: --dart-define=DEVICE_IP=192.168.1.5
  static const String _deviceIp = String.fromEnvironment(
    'DEVICE_IP',
    defaultValue: '192.168.1.5', // fallback placeholder — update yours here
  );

  static const int _port = 8080;

  // ------------------------------------------------------------------
  // Base URL — resolved from FLAVOR at compile time
  // ------------------------------------------------------------------

  /// The resolved backend base URL for the current build flavor.
  static String get baseUrl {
    switch (_flavor) {
      case 'simulator':
        // iOS simulator routes localhost directly to the host machine
        return 'http://localhost:$_port';
      case 'device':
        // Physical device must use the host machine's LAN IP
        return 'http://$_deviceIp:$_port';
      case 'emulator':
      default:
        // Android emulator uses 10.0.2.2 to reach the host machine's localhost
        return 'http://10.0.2.2:$_port';
    }
  }

  /// The active flavor name — useful for debug displays.
  static String get flavor => _flavor;

  // ------------------------------------------------------------------
  // Other constants
  // ------------------------------------------------------------------

  /// Maximum wait time for API requests.
  static const Duration requestTimeout = Duration(seconds: 15);

  /// App display name.
  static const String appName = 'InsurePredict';

  /// App subtitle shown on the home screen.
  static const String appTagline = 'AI-powered Health Insurance Estimation';

  /// ML model name shown in results.
  static const String modelName = 'Linear Regression';

  /// Dataset name shown in about screen.
  static const String datasetName = 'Kaggle Medical Insurance Dataset';

  /// Number of training samples.
  static const int datasetSize = 1338;
}
