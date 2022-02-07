import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exceptions.dart';

class ApiHelper {
  static var authToken = "";

  final String _apiUrl = "https://orgc01e1d97.crm4.dynamics.com/api/data/v9.0/";

  Future<dynamic> getByPath(String path, Map<String, String>? headers) async {
    return _rawGet(_apiUrl + path, headers);
  }

  Future<dynamic> getByUrl(String url, Map<String, String>? headers) async {
    return _rawGet(url, headers);
  }

  Future<dynamic> _rawGet(String url, Map<String, String>? headers) async {
    debugPrint('Api Get, url $url');
    dynamic responseJson;
    try {
      var requestUri = Uri.parse(url);
      final response = await http.get(requestUri, headers: headers);
      responseJson = await _returnResponse(response);
    } on SocketException {
      debugPrint('No network');
      throw FetchDataException('No Internet connection');
    }
    debugPrint('Api get received, response: $responseJson');
    return responseJson;
  }

  Future<dynamic> _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return compute(json.decode, response.body.toString());
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
