// IMPORTANT: This file defines API service structure and endpoints only.
// DO NOT make direct API calls in this file - use controllers to handle API interactions.
// This file serves as a service layer definition for the application.
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

import '../utils/pref_util.dart';

class ApiEndPoints {
  // Auth (guest + upgrade / login)
  static const String authGuest = 'auth/guest';
  static const String authRefresh = 'auth/refresh';
  static const String authLogout = 'auth/logout';
  static const String authUpgrade = 'auth/upgrade';
  static const String authLogin = 'auth/login';
  static const String authForgotPassword = 'auth/forgot-password';
  static const String authVerifyResetOtp = 'auth/verify-reset-otp';
  static const String authResetPassword = 'auth/reset-password';

  // Me / privacy
  static const String me = 'me';
  static const String meProfile = 'me/profile';
  static const String meAvatar = 'me/avatar';
  static const String meConsents = 'me/consents';
  static const String mePush = 'me/push';
  static const String meReminders = 'me/reminders';

  // Onboarding
  static const String onboarding = 'onboarding';
  static const String onboardingAnswers = 'onboarding/answers';
  static const String onboardingGoals = 'onboarding/goals';
  static const String onboardingComplete = 'onboarding/complete';

  // Cycle / periods
  static const String cyclePeriodDays = 'cycle/period-days';
  static const String cycleToday = 'cycle/today';
  static const String cycleCalendar = 'cycle/calendar';
  static const String cycleRebuild = 'cycle/predictions/rebuild';
  static const String cycleObservations = 'cycle/observations';
  static const String cycleInsights = 'cycle/insights';

  // Daily logs (symptoms / mood / sex / tests / mucus)
  static const String logs = 'logs';

  // Partner link (woman generates code; male partner enters it)
  static const String partnerCode = 'partner/code';
  static const String partnerLink = 'partner/link';
  static const String partnerStatus = 'partner/status';
  static const String partnerToday = 'partner/today';
  static const String partnerCalendar = 'partner/calendar';

  // Secret chat (anonymous community)
  static const String secretProfile = 'secret/profile';
  static const String posts = 'posts';
  static String postById(String id) => 'posts/$id';
  static String postLikes(String id) => 'posts/$id/likes';
  static String postComments(String id) => 'posts/$id/comments';
  static String commentLikes(String id) => 'comments/$id/likes';

  // Article bookmarks (guest + registered; article ids from app catalog)
  static const String articleBookmarks = 'articles/bookmarks';
  static String articleBookmark(String id) => 'articles/$id/bookmark';
}

class ApiClient {
  /// Local backend defaults:
  /// - iOS Simulator / macOS / desktop → 127.0.0.1
  /// - Android emulator → 10.0.2.2
  /// - Physical device → your Mac LAN IP (e.g. http://10.0.1.46:3000/api/)
  static String get _defaultBaseUrl {
    if (Platform.isAndroid) {
      return 'https://eezycycle.eezybooking.com/api/';
      // return 'http://10.0.2.2:3000/api/';
    }
    return 'http://127.0.0.1:3000/api/';
  }

  // static const String _defaultBaseUrl = "https://api.eezybooking.com/api/";
  static const Duration _requestTimeout = Duration(seconds: 50);
  static const Duration _responseDelay = Duration(seconds: 2);

  final String baseUrl;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl;

  /// Pulls user-facing message from our `{ success, error: { message } }` shape.
  static String extractErrorMessage(dynamic errorResponse) {
    if (errorResponse is! Map) return 'An unknown error occurred';

    final error = errorResponse['error'];
    log("Error is $error");
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    if (errorResponse['message'] is String) {
      return errorResponse['message'] as String;
    }
    if (errorResponse['msg'] is String) {
      return errorResponse['msg'] as String;
    }

    final errors =
        errorResponse['errors'] ??
        errorResponse['error'] ??
        errorResponse['details'];
    if (errors is List) {
      final parts = errors
          .where((e) => e != null)
          .map(
            (e) => e is String
                ? e
                : (e is Map && (e['message'] ?? e['msg']) is String)
                ? (e['message'] ?? e['msg'])
                : e.toString(),
          )
          .toList();
      if (parts.isNotEmpty) return parts.join(', ');
    } else if (errors is Map) {
      final parts = errors.entries
          .map(
            (e) => e.value is String
                ? '${e.key}: ${e.value}'
                : '${e.key}: ${e.value.toString()}',
          )
          .toList();
      if (parts.isNotEmpty) return parts.join(', ');
    }

    return 'An unknown error occurred';
  }

  /// Returns `data` map when `success == true`.
  static Map<String, dynamic>? unwrapData(dynamic response) {
    if (response is! Map) return null;
    if (response['success'] != true) return null;
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  /// Turns `/uploads/...` paths into absolute URLs for [Image.network].
  String resolveMediaUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final origin = baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    if (url.startsWith('/')) return '$origin$url';
    return '$origin/$url';
  }

  Future<Map<String, String>> _getHeaders({bool jsonContentType = true}) async {
    final headers = <String, String>{};
    if (jsonContentType) {
      headers['Content-Type'] = 'application/json';
    }
    final token = PrefUtil.getString(PrefUtil.token);
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> _processResponse(
    http.Response response,
    String requestUrl,
  ) async {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        final decoded = jsonDecode(response.body);
        throw Exception(extractErrorMessage(decoded));
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(extractErrorMessage(errorResponse));
      }
    } on FormatException {
      throw Exception("Invalid response format");
    }
  }

  bool _isAuthEndpoint(String url) {
    return url.contains('/auth/guest') ||
        url.contains('/auth/refresh') ||
        url.contains('/auth/login') ||
        url.contains('/auth/upgrade') ||
        url.contains('/auth/logout') ||
        url.contains('/auth/forgot-password') ||
        url.contains('/auth/verify-reset-otp') ||
        url.contains('/auth/reset-password');
  }

  Future<void> _persistTokens(Map<String, dynamic> data) async {
    final access = data['access_token']?.toString() ?? '';
    final refresh = data['refresh_token']?.toString() ?? '';
    if (access.isNotEmpty) {
      await PrefUtil.setString(PrefUtil.token, access);
    }
    if (refresh.isNotEmpty) {
      await PrefUtil.setString(PrefUtil.refreshToken, refresh);
    }
    final user = data['user'];
    if (user is Map) {
      final id = user['id'];
      final parsed = id is int ? id : int.tryParse('$id');
      if (parsed != null) await PrefUtil.setInt(PrefUtil.userId, parsed);
      final status = user['account_status']?.toString();
      if (status != null && status.isNotEmpty) {
        await PrefUtil.setString(PrefUtil.accountStatus, status);
      }
    }
  }

  /// On 401: refresh or re-create guest session (permanent tokens).
  Future<bool> _recoverSession() async {
    final refresh = PrefUtil.getString(PrefUtil.refreshToken);
    if (refresh.isNotEmpty) {
      try {
        final res = await http.post(
          Uri.parse('$baseUrl${ApiEndPoints.authRefresh}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh_token': refresh}),
        );
        if (res.statusCode >= 200 && res.statusCode < 300) {
          final data = unwrapData(jsonDecode(res.body));
          if (data != null) {
            await _persistTokens(data);
            log('Session recovered via refresh');
            return true;
          }
        }
      } catch (e) {
        log('Refresh recover failed: $e');
      }
    }

    final deviceId = PrefUtil.getString(PrefUtil.deviceId);
    if (deviceId.isEmpty) return false;

    try {
      final res = await http.post(
        Uri.parse('$baseUrl${ApiEndPoints.authGuest}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'platform': Platform.isIOS
              ? 'ios'
              : Platform.isAndroid
              ? 'android'
              : 'other',
          'app_version': '1.0.0',
        }),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = unwrapData(jsonDecode(res.body));
        if (data != null) {
          await _persistTokens(data);
          log('Session recovered via guest re-issue');
          return true;
        }
      }
    } catch (e) {
      log('Guest recover failed: $e');
    }
    return false;
  }

  Future<dynamic> _send(
    Future<http.Response> Function() makeRequest,
    String url, {
    bool allowRecover = true,
  }) async {
    try {
      var response = await makeRequest().timeout(_requestTimeout);

      if (response.statusCode == 401 && allowRecover && !_isAuthEndpoint(url)) {
        final recovered = await _recoverSession();
        if (recovered) {
          response = await makeRequest().timeout(_requestTimeout);
        }
      }

      // Artificial delay before returning so loading UI stays visible briefly.
      // await Future.delayed(_responseDelay);
      return await _processResponse(response, url);
    } on TimeoutException {
      throw Exception("Request timed out — is the API running at $baseUrl?");
    } on SocketException {
      throw Exception("No internet connection");
    } on HttpException {
      throw Exception("Server error");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception("$e");
    }
  }

  // GET request without authentication
  Future<dynamic> get(String endpoint, {bool doesLoginRequired = false}) async {
    final token = PrefUtil.getString(PrefUtil.token);
    if (doesLoginRequired && token.isEmpty) {
      return;
    }
    final url = '$baseUrl$endpoint';
    return _send(
      () async => http.get(Uri.parse(url), headers: await _getHeaders()),
      url,
    );
  }

  // POST request without authentication
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = '$baseUrl$endpoint';
    return _send(
      () async => http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ),
      url,
      allowRecover: !_isAuthEndpoint(url),
    );
  }

  // PUT request with authentication
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = '$baseUrl$endpoint';
    log("PUT Request: $url, Data: $data");
    return _send(
      () async => http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ),
      url,
    );
  }

  // DELETE request with authentication
  Future<dynamic> delete(String endpoint, [Map<String, dynamic>? data]) async {
    final url = '$baseUrl$endpoint';
    log("DELETE Request: $url and data is $data");
    return _send(
      () async => http.delete(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: data != null ? jsonEncode(data) : null,
      ),
      url,
    );
  }

  // PATCH request with authentication
  Future<dynamic> patch(String endpoint, [Map<String, dynamic>? data]) async {
    final url = '$baseUrl$endpoint';
    log("PATCH Request: $url, Data: $data");
    return _send(
      () async => http.patch(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: data != null ? jsonEncode(data) : null,
      ),
      url,
    );
  }

  String? getMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return null; // Unsupported file type
    }
  }

  Future<dynamic> postFormData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = '$baseUrl$endpoint';

    Future<http.Response> sendOnce() async {
      // Must not set Content-Type — MultipartRequest needs its own boundary.
      final headers = await _getHeaders(jsonContentType: false);
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);

      for (var key in data.keys) {
        var value = data[key];
        log("Value is $value");
        if (value is File) {
          value = [value];
        }
        if (value is List<File>) {
          for (var file in value) {
            log("File path is ${file.path}");
            final mimeType = getMimeType(file.path);
            if (mimeType == null) {
              log(
                'Error: File ${file.path} has unsupported extension. Only .jpg, .jpeg, and .png are allowed.',
              );
              throw Exception(
                'Unsupported file type. Only JPEG and PNG files are allowed.',
              );
            }
            final fileStream = http.ByteStream(file.openRead());
            final length = await file.length();
            request.files.add(
              http.MultipartFile(
                key,
                fileStream,
                length,
                filename: basename(file.path),
                contentType: MediaType.parse(mimeType),
              ),
            );
          }
        } else if (value != null) {
          request.fields[key] = value.toString();
        }
      }

      log("Data is $data");
      final streamed = await request.send();
      final responseBody = await http.Response.fromStream(streamed);
      log("Response Status: ${responseBody.statusCode}");
      log("Response Body: ${responseBody.body}");
      return responseBody;
    }

    try {
      var response = await sendOnce().timeout(_requestTimeout);
      if (response.statusCode == 401 && !_isAuthEndpoint(url)) {
        final recovered = await _recoverSession();
        if (recovered) {
          response = await sendOnce().timeout(_requestTimeout);
        }
      }
      return await _processResponse(response, url);
    } on TimeoutException {
      throw Exception("Request timed out — is the API running at $baseUrl?");
    } on SocketException {
      throw Exception("No internet connection");
    } on HttpException {
      throw Exception("Server error");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception("$e");
    }
  }

  Future<dynamic> putFormData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = '$baseUrl$endpoint';
    final headers = await _getHeaders();

    var request = http.MultipartRequest('PUT', Uri.parse(url));
    request.headers.addAll(headers);

    // Add the fields to the request
    for (var key in data.keys) {
      var value = data[key];
      log("Value is $value");
      if (value is List<File>) {
        for (var file in value) {
          log("File path is ${file.path}");
          final mimeType = getMimeType(file.path);
          if (mimeType == null) {
            log(
              'Error: File ${file.path} has unsupported extension. Only .jpg, .jpeg, and .png are allowed.',
            );
            throw Exception(
              'Unsupported file type. Only JPEG and PNG files are allowed.',
            );
          }
          var fileStream = http.ByteStream(file.openRead());
          var length = await file.length();
          var multipartFile = http.MultipartFile(
            key,
            fileStream,
            length,
            filename: basename(file.path),
            contentType: MediaType.parse(mimeType),
          );
          request.files.add(multipartFile);
        }
      } else {
        request.fields[key] = value.toString();
      }
    }

    log("Data is $data");
    // Send the request
    var response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    log("Response Status: ${responseBody.statusCode}");
    log("Response Body: ${responseBody.body}");

    // await Future.delayed(_responseDelay);
    return _processResponse(responseBody, url);
  }

  // File upload method
  // Future<String> upload(String filePath, {String fieldName = "file"}) async {
  //   final response = await postFormData(
  //     ApiEndPoints.upload,
  //     {
  //       fieldName: [File(filePath)],
  //     }, // postFormData already supports List<File>
  //   );
  //
  //   // Response: { "message": "...", "url": "..." }
  //   if (response is Map && response.containsKey("url")) {
  //     return response["url"];
  //   } else {
  //     throw Exception("Upload failed: $response");
  //   }
  // }
}
