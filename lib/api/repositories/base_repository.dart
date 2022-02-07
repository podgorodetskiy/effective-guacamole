import 'dart:io';

import 'package:flutter/foundation.dart';

class BaseRepository {
  BaseRepository({required this.authToken});

  String authToken;

  @protected
  Map<String, String> makeHeader({int maxPageSize = 5000}) {
    return {
      HttpHeaders.authorizationHeader: "Bearer $authToken",
      HttpHeaders.acceptHeader: "application/json",
      "OData-MaxVersion": "4.0",
      "OData-Version": "4.0",
      "Prefer": "odata.maxpagesize=$maxPageSize"
    };
  }
}