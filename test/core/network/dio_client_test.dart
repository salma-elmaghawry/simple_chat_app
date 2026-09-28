import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:simple_chat_app/core/network/dio_client.dart';

void main() {
  group('DioClient', () {
    test('applies the base URL', () {
      final dio = DioClient(baseUrl: 'https://example.com').dio;

      expect(dio.options.baseUrl, 'https://example.com');
    });

    test('adds PrettyDioLogger in debug builds', () {
      final dio = DioClient().dio;

      // Tests run in debug mode, so kDebugMode is true here.
      expect(dio.interceptors.whereType<PrettyDioLogger>(), hasLength(1));
    });
  });
}
