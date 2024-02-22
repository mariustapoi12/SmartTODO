import 'dart:convert';

import 'package:dio/dio.dart';
import './logger.dart';

class HttpLogger extends Interceptor {
  HttpLogger();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    logPrint('~~~ REQUEST ~~~');

    printKV(options.method, options.uri);
    logPrint('HEADERS:');
    options.headers.forEach((key, v) => printKV(key, v));
    logPrint('BODY:');
    printAll(options.data ?? "");

    super.onRequest(options, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    logPrint('~~~ ERROR ~~~');

    logPrint('URI: ${err.requestOptions.uri}');
    if (err.response != null) {
      logPrint('STATUS CODE: ${err.response?.statusCode?.toString()}');
    }
    logPrint('$err');
    if (err.response != null) {
      logPrint('BODY:');
      printAll(err.response?.toString());
    }

    super.onError(err, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    logPrint('~~~ RESPONSE ~~~');

    printKV('URI', response.requestOptions.uri);
    final statusCode = response.statusCode;
    if (null != statusCode) printKV('STATUS CODE', statusCode);
    logPrint('HEADERS:');
    response.headers.forEach((key, v) => printKV(key, v));
    logPrint('BODY:');
    printAll(response.data ?? "");

    super.onResponse(response, handler);
  }

  void printKV(String key, Object v) {
    log.d('$key: $v');
  }

  void printAll(msg) {
    logPrint(json.encode(msg));
  }

  void logPrint(String s) {
    log.d(s);
  }
}
