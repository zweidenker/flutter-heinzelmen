import 'dart:convert';

import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:http/http.dart' as http;

/// Extension Method on [ApptiveGridClient] for simplifying parsing of ApptiveGrid Related Objects
extension PerformApptiveLinkX on ApptiveGridClient {
  /// A simplification to call [performApptiveLink] to simplify parsing for ApptiveGridObjects
  /// This provides a custom parsing method to extract single Objects and Lists from Responses that are direct ApptiveGridObjects
  /// Supported types are the keys in [_parsingMap]
  Future<T?> performApptiveLinkForApptiveGridObject<T>({
    required ApptiveLink link,
    bool isRetry = false,
    dynamic body,
    Map<String, String> headers = const {},
    ApptiveGridHalVersion? halVersion,
    Map<String, String>? queryParameters,
  }) async {
    assert(_parsingMap.containsKey(T));

    return performApptiveLink<T>(
      link: link,
      isRetry: isRetry,
      body: body,
      headers: headers,
      halVersion: halVersion,
      queryParameters: queryParameters,
      parseResponse: _customParser<T>,
    );
  }
}

Future<T> _customParser<T>(http.Response response) async {
  late List jsonList;
  final parsedBody = jsonDecode(response.body);
  final parser = _parsingMap[T]!;
  if (parsedBody is List) {
    jsonList = parsedBody;
  } else if (parsedBody is Map && parsedBody.containsKey('items')) {
    jsonList = parsedBody['items'];
  } else {
    return parser(parsedBody);
  }
  return parser(jsonList);
}

List<T> _listParser<T>(list) => list.map<T>(_parsingMap[T]).toList();

final _parsingMap = <Type, dynamic Function(dynamic)>{
  Space: (json) => Space.fromJson(json),
  List<Space>: _listParser<Space>,
  Grid: (json) => Grid.fromJson(json),
  List<Grid>: _listParser<Grid>,
  FormData: (json) => FormData.fromJson(json),
  List<FormData>: _listParser<FormData>,
  SView: (json) => SView.fromJson(json),
  List<SView>: _listParser<SView>,
  Share: (json) => Share.fromJson(json),
  List<Share>: _listParser<Share>,
  Invitation: (json) => Invitation.fromJson(json),
  List<Invitation>: _listParser<Invitation>,
};
