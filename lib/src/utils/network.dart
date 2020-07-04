import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:wss_mobile/src/Utils/server_status.dart';

class Network {
  final Dio _dio = Dio();

  Future<Response> get(String url, {headers, queryParameters, int cacheDays = 1, bool forceRefresh = false}) async {
    Response response;
    try {
      response = await _dio.get(url,
          options: buildCacheOptions(Duration(days: cacheDays),
              forceRefresh: forceRefresh,
              options: Options(
                headers: headers,
              )),
          queryParameters: queryParameters);
    } on DioError catch (e) {
      if (DioErrorType.CONNECT_TIMEOUT == e.type || DioErrorType.RECEIVE_TIMEOUT == e.type) {
        throw Exception('Connection timed out.');
      } else if (DioErrorType.RESPONSE == e.type) {
        throw Exception(ServerStatus().getMessage(e.response));
      } else if (DioErrorType.DEFAULT == e.type) {
        if (e.message.contains('SocketException')) {
          throw Exception('Tidak terkoneksi internet.');
        }
      } else {
        throw Exception('Tidak dapat terkoneksi ke server. Mohon coba lagi.');
      }
    }
    return response;
  }

  Future<Response> post(String url, {headers, onSendProgress, body, int cacheDays = 1, bool forceRefresh = false, ResponseType responseType}) async {
    Response response;
    try {
      response = await _dio.post(
        url,
        data: body,
        options: buildCacheOptions(Duration(days: cacheDays),
            forceRefresh: forceRefresh,
            options: Options(
              headers: headers,
              responseType: responseType,
            )),
        onSendProgress: onSendProgress,
      );
    } on DioError catch (e) {
      if (DioErrorType.CONNECT_TIMEOUT == e.type || DioErrorType.RECEIVE_TIMEOUT == e.type) {
        throw Exception('Connection timed out.');
      } else if (DioErrorType.RESPONSE == e.type) {
        throw Exception(ServerStatus().getMessage(e.response));
      } else if (DioErrorType.DEFAULT == e.type) {
        if (e.message.contains('SocketException')) {
          throw Exception('Tidak terkoneksi internet.');
        }
      } else {
        throw Exception('Tidak dapat terkoneksi ke server. Mohon coba lagi.');
      }
    }
    return response;
  }

  Future<bool> isServerUp() async {
    try {
      String url = 'http://google.com';
      var host = this.getHostname(url);
      final result = await InternetAddress.lookup(host).timeout(Duration(seconds: 4));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  String getHostname(String url) {
    var hostname;
    //find & remove protocol (http, ftp, etc.) and get hostname
    if (url.indexOf('//') > -1) {
      hostname = url.split('/')[2];
    } else {
      hostname = url.split('/')[0];
    }

    //find & remove port number
    hostname = hostname.split(':')[0];
    //find & remove "?"
    hostname = hostname.split('?')[0];

    return hostname;
  }
}
