import 'dart:convert';

import 'package:dio/dio.dart';

class NetworkUsageTracker {
  NetworkUsageTracker._();

  static int _agoraRxTotal = 0;
  static int _agoraTxTotal = 0;
  static int _socketRxTotal = 0;
  static int _socketTxTotal = 0;
  static int _dioRxTotal = 0;
  static int _dioTxTotal = 0;

  static void setAgoraTotals({required int rxBytes, required int txBytes}) {
    _agoraRxTotal = rxBytes;
    _agoraTxTotal = txBytes;
  }

  static void addSocketRx(dynamic data) {
    _socketRxTotal += _estimateBytes(data);
  }

  static void addSocketTx(dynamic data) {
    _socketTxTotal += _estimateBytes(data);
  }

  static void addDioRx(int bytes) {
    if (bytes > 0) _dioRxTotal += bytes;
  }

  static void addDioTx(int bytes) {
    if (bytes > 0) _dioTxTotal += bytes;
  }

  static NetworkUsageSnapshot snapshot() {
    return NetworkUsageSnapshot(
      rxBytes: _agoraRxTotal + _socketRxTotal + _dioRxTotal,
      txBytes: _agoraTxTotal + _socketTxTotal + _dioTxTotal,
    );
  }

  static int _estimateBytes(dynamic data) {
    if (data == null) return 0;
    if (data is List<int>) return data.length;
    if (data is String) return utf8.encode(data).length;
    try {
      return utf8.encode(jsonEncode(data)).length;
    } catch (_) {
      return utf8.encode(data.toString()).length;
    }
  }
}

class NetworkUsageSnapshot {
  final int rxBytes;
  final int txBytes;

  const NetworkUsageSnapshot({
    required this.rxBytes,
    required this.txBytes,
  });
}

class NetworkUsageDioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    var requestBytes = 0;
    requestBytes += utf8.encode(options.path).length;
    requestBytes += utf8.encode(options.method).length;
    if (options.queryParameters.isNotEmpty) {
      requestBytes += utf8.encode(options.queryParameters.toString()).length;
    }
    if (options.data != null) {
      requestBytes += NetworkUsageTracker._estimateBytes(options.data);
    }
    NetworkUsageTracker.addDioTx(requestBytes);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final contentLength = response.headers.value(Headers.contentLengthHeader);
    final parsedLength = int.tryParse(contentLength ?? '');

    if (parsedLength != null && parsedLength >= 0) {
      NetworkUsageTracker.addDioRx(parsedLength);
    } else {
      NetworkUsageTracker.addDioRx(
        NetworkUsageTracker._estimateBytes(response.data),
      );
    }
    handler.next(response);
  }
}

