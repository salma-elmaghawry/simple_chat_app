import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Builds the shared [Dio] instance. Request logging is added in debug builds
/// only, so release builds never print request or response bodies.
class DioClient {
  DioClient({String baseUrl = ''})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ) {
    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(requestBody: true));
    }
  }

  final Dio dio;
}
