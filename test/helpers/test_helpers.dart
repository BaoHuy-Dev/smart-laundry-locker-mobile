import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

export 'package:http_mock_adapter/http_mock_adapter.dart';

const kTestBaseUrl = 'http://test.local';

/// Creates a fresh [Dio] + [DioAdapter] pair for each test.
/// Inject the returned [dio] into [LockerOpsService(dio: dio)].
({Dio dio, DioAdapter adapter}) createMockDio() {
  final dio = Dio(BaseOptions(baseUrl: kTestBaseUrl));
  // UrlRequestMatcher: match only method+path, ignore body/headers — less brittle
  final adapter = DioAdapter(dio: dio, matcher: const UrlRequestMatcher());
  return (dio: dio, adapter: adapter);
}

/// Standard mock for FlutterSecureStorage — call once in setUpAll.
void mockSecureStorage([Map<String, String> initial = const {}]) {
  FlutterSecureStorage.setMockInitialValues(initial);
}

/// Wraps a successful ApiResponse body as the backend envelope.
Map<String, dynamic> apiOk(dynamic data, {String message = 'OK'}) => {
  'success': true,
  'code': 'SUCCESS',
  'message': message,
  'data': data,
  'errors': null,
};

/// Wraps an error response envelope.
Map<String, dynamic> apiError(String message, {int code = 400}) => {
  'success': false,
  'code': 'ERROR',
  'message': message,
  'data': null,
  'errors': [message],
};
