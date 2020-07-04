import 'package:dio/dio.dart';

class ServerStatus {
  String getMessage(Response<dynamic> response) {
    int statusCode = response.statusCode;
    switch (statusCode) {
      case 500:
        return 'Terjadi kesalahan server.';
        break;
      case 401:
        return 'Anda tidak mempunyai izin';
        break;
      case 404:
        return 'Tidak menemukan server.';
        break;
      case 400:
        return response.data['meta']['message'];
        break;
      case 301:
      case 302:
      case 303:
      case 304:
      case 307:
        return 'Halaman dipindahkan.';
        break;
      case 200:
      case 201:
      case 202:
      case 204:
        return response.data['meta']['message'];
        break;
      default:
        return 'Tidak terkoneksi ke internet, mohon cek koneksi anda.';
    }
  }
}
