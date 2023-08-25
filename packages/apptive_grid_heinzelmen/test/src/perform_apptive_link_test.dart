import 'dart:convert';

import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:apptive_grid_heinzelmen/src/perform_apptive_link.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../infra/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(Request('GET', Uri()));
  });

  final link = ApptiveLink(uri: Uri.parse('/apptive/link'), method: 'get');
  late ApptiveGridClient client;
  late StreamedResponse response;

  StreamedResponse createResponse(dynamic response) {
    return StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(response))),
      200,
    );
  }

  setUp(() {
    final httpClient = MockHttpClient();
    final authenticator = MockApptiveGridAuthenticator();
    when(() => authenticator.checkAuthentication()).thenAnswer((_) async {});
    client = ApptiveGridClient(
      httpClient: httpClient,
      authenticator: authenticator,
    );
    when(
      () => httpClient.send(
        any(
          that: predicate<BaseRequest>(
            (request) =>
                request.url.scheme == 'https' &&
                request.url.host.endsWith('apptivegrid.de') &&
                request.url.path == link.uri.path &&
                request.method == link.method,
          ),
        ),
      ),
    ).thenAnswer((realInvocation) async {
      return response;
    });
  });

  group('Grid', () {
    final gridJson = {
      'fieldNames': [
        'TextC',
        'NumberC',
        'DateTimeC',
        'DateC',
        'New field',
        'New field 2',
        'CheckmarkC',
        'Enums',
      ],
      'entities': [
        {
          'fields': [
            'Hello',
            1,
            '2020-12-08T01:00:00.000Z',
            '2020-12-13',
            null,
            null,
            true,
            'Enum1',
          ],
          '_id': '3ojhtqm2bgtwzpdbktuv6syv5',
          '_links': {
            "self": {
              "href":
                  "/api/users/userId/spaces/spaceId/grids/61bb271d457c98231c8fbb04/entities/619b63e84a391314968da9a0",
              "method": "get",
            },
          },
        },
        {
          'fields': [
            'Hola Web',
            1,
            '2020-12-14T09:12:00.000Z',
            '2020-12-15',
            null,
            null,
            true,
            'Enum2',
          ],
          '_id': '6bs7tqexlcy88cry3qzzvjbyz',
          '_links': {
            "self": {
              "href":
                  "/api/users/userId/spaces/spaceId/grids/61bb271d457c98231c8fbb04/entities/619b63e84a391314968da9a0",
              "method": "get",
            },
          },
        },
        {
          'fields': [null, null, null, null, null, null, false, null],
          '_id': '6bs7tqf61rppn1nixxb6cr7se',
          '_links': {
            "self": {
              "href":
                  "/api/users/userId/spaces/spaceId/grids/61bb271d457c98231c8fbb04/entities/619b63e84a391314968da9a0",
              "method": "get",
            },
          },
        },
        {
          'fields': [
            'AAA',
            null,
            '2020-12-14T11:42:00.000Z',
            '2020-12-17',
            null,
            null,
            true,
            'Enum2',
          ],
          '_id': 'bxzfxf43vaeefhje6xcmnofa8',
          '_links': {
            "self": {
              "href":
                  "/api/users/userId/spaces/spaceId/grids/61bb271d457c98231c8fbb04/entities/619b63e84a391314968da9a0",
              "method": "get",
            },
          },
        },
        {
          'fields': [
            'TTTTTTT',
            12312344,
            '2020-12-14T06:00:00.000Z',
            '2020-12-16',
            null,
            null,
            true,
            null,
          ],
          '_id': 'bxzfxf72k3j4d5fcmk6w0pa4s',
          '_links': {
            "self": {
              "href":
                  "/api/users/userId/spaces/spaceId/grids/61bb271d457c98231c8fbb04/entities/619b63e84a391314968da9a0",
              "method": "get",
            },
          },
        },
      ],
      'schema': {
        'type': 'object',
        'properties': {
          'fields': {
            'type': 'array',
            'items': [
              {'type': 'string'},
              {'type': 'integer'},
              {'type': 'string', 'format': 'date-time'},
              {'type': 'string', 'format': 'date'},
              {'type': 'string'},
              {'type': 'string'},
              {'type': 'boolean'},
              {
                'type': 'string',
                'enum': [
                  'Enum1',
                  'Enum2',
                ],
              },
            ],
          },
          '_id': {'type': 'string'},
        },
      },
      'fields': [
        {
          "type": {
            "name": "string",
            "componentTypes": ["textfield"],
          },
          "key": null,
          "name": "String",
          "schema": {"type": "string"},
          "id": "6282104004bd30efc49b7f17",
          "_links": <String, dynamic>{},
        },
        {
          "type": {
            "name": "integer",
            "componentTypes": ["textfield"],
          },
          "key": null,
          "name": "Number",
          "schema": {"type": "integer"},
          "id": "6282106a04bd30163b9b7f3b",
          "_links": <String, dynamic>{},
        },
        {
          "type": {
            "name": "date-time",
            "componentTypes": ["datePicker"],
          },
          "key": null,
          "name": "DateTime",
          "schema": {"type": "string", "format": "date-time"},
          "id": "6282104e04bd30efc49b7f22",
          "_links": <String, dynamic>{},
        },
        {
          "type": {
            "name": "date",
            "componentTypes": ["datePicker", "textfield"],
          },
          "key": null,
          "name": "Date",
          "schema": {"type": "string", "format": "date"},
          "id": "6282105c04bd30efc49b7f2e",
          "_links": <String, dynamic>{},
        },
        {
          "type": {
            "name": "string",
            "componentTypes": ["textfield"],
          },
          "key": null,
          "name": "String",
          "schema": {"type": "string"},
          "id": "6282104004bd30efc49b7f17",
          "_links": <String, dynamic>{},
        },
        {
          "type": {
            "name": "string",
            "componentTypes": ["textfield"],
          },
          "key": null,
          "name": "String",
          "schema": {"type": "string"},
          "id": "6282104004bd30efc49b7f17",
          "_links": <String, dynamic>{},
        },
        {
          "type": {
            "name": "boolean",
            "componentTypes": ["checkbox"],
          },
          "key": null,
          "name": "Checkmark",
          "schema": {"type": "boolean"},
          "id": "6282107c04bd30163b9b7f4d",
          "_links": <String, dynamic>{},
        },
        {
          "type": {
            "name": "enum",
            "options": ["A", "B"],
            "componentTypes": ["selectBox"],
          },
          "key": null,
          "name": "SingleSelect",
          "schema": {
            "type": "string",
            "enum": ["Enum1", "Enum2"],
          },
          "id": "6282108604bd30163b9b7f56",
          "_links": <String, dynamic>{},
        },
      ],
      'hiddenFields': [
        {
          "type": {
            "name": "string",
            "componentTypes": ["textfield"],
          },
          "key": null,
          "name": "Hidden Field",
          "schema": {"type": "string"},
          "id": "hiddenId",
          "_links": <String, dynamic>{},
        },
      ],
      '_embedded': {
        "forms": [
          {
            "name": "Formular 1",
            "id": "formId",
            "_links": {
              "self": {
                "href":
                    "/api/users/userId/spaces/spaceId/grids/gridId/forms/formId",
                "method": "get",
              },
            },
          }
        ],
      },
      'name': 'New grid',
      'id': 'gridId',
      'key': 'gridKey',
      '_links': {
        "addLink": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/AddLink",
          "method": "post",
        },
        "forms": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/forms",
          "method": "get",
        },
        "updateFieldType": {
          "href":
              "/api/users/userId/spaces/spaceId/grids/gridId/ColumnTypeChange",
          "method": "post",
        },
        "removeField": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/ColumnRemove",
          "method": "post",
        },
        "addEntity": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/entities",
          "method": "post",
        },
        "views": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/views",
          "method": "get",
        },
        "addView": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/views",
          "method": "post",
        },
        "self": {
          "href":
              "/api/users/userId/spaces/spaceId/grids/61bb271d457c98231c8fbb04",
          "method": "get",
        },
        "updateFieldKey": {
          "href":
              "/api/users/userId/spaces/spaceId/grids/gridId/ColumnKeyChange",
          "method": "post",
        },
        "query": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/query",
          "method": "get",
        },
        "entities": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/entities",
          "method": "get",
        },
        "updates": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/updates",
          "method": "get",
        },
        "schema": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/schema",
          "method": "get",
        },
        "updateFieldName": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/ColumnRename",
          "method": "post",
        },
        "addForm": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/forms",
          "method": "post",
        },
        "addField": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/ColumnAdd",
          "method": "post",
        },
        "rename": {
          "href": "/api/users/userId/spaces/spaceId/grids/gridId/Rename",
          "method": "post",
        },
        "remove": {
          "href":
              "/api/users/userId/spaces/spaceId/grids/61bb271d457c98231c8fbb04",
          "method": "delete",
        },
      },
    };

    test('Single Grid', () async {
      response = createResponse(gridJson);

      final grid =
          await client.performApptiveLinkForApptiveGridObject<Grid>(link: link);
      expect(grid, predicate((result) => result is Grid));
    });

    test('Simple List', () async {
      response = createResponse([gridJson]);

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<Grid>>(link: link);
      expect(result, predicate((result) => result is List<Grid>));
    });

    test('Nested List', () async {
      response = createResponse({
        'items': [gridJson],
      });

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<Grid>>(link: link);
      expect(result, predicate((result) => result is List<Grid>));
    });
  });

  group('Space', () {
    final spaceJson = {
      'id': 'id',
      'name': 'name',
      'type': 'space',
      'key': 'key',
      'belongsTo': 'belongsTo',
      '_links': {
        'self': {
          'href': '/api/users/user/spaces/id',
          'method': 'get',
        },
      },
      '_embedded': {
        'grids': [
          {
            'id': 'gridId',
            'name': 'Grid',
            '_links': {
              'self': {
                'href': '/api/users/user/spaces/id/grid/gridId',
                'method': 'get',
              },
            },
          },
        ],
      },
    };

    test('Single Space', () async {
      response = createResponse(spaceJson);

      final space = await client.performApptiveLinkForApptiveGridObject<Space>(
        link: link,
      );
      expect(space, predicate((result) => result is Space));
    });

    test('Simple List', () async {
      response = createResponse([spaceJson]);

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<Space>>(link: link);
      expect(result, predicate((result) => result is List<Space>));
    });

    test('Nested List', () async {
      response = createResponse({
        'items': [spaceJson],
      });

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<Space>>(link: link);
      expect(result, predicate((result) => result is List<Space>));
    });
  });

  group('FormData', () {
    const title = 'title';
    const name = 'name';
    const description = 'description';
    const submitButtonTitle = 'submitButton';
    const additionalAnswerButtonTitle = 'additionalAnswerButton';
    const reloadAfterSubmit = true;
    const successTitle = 'successTitle';
    const successMessage = 'successMessage';
    final formDataJson = {
      'fields': [
        {
          "type": {
            "name": "date-time",
            "componentTypes": ["datePicker"],
          },
          "schema": {"type": "string", "format": "date-time"},
          "id": "4zc4l4c5coyi7qh6q1ozrg54u",
          "name": "Date Time",
          "key": null,
          "_links": <String, dynamic>{},
        },
        {
          "type": {
            "name": "boolean",
            "componentTypes": ["checkbox"],
          },
          "schema": {"type": "boolean"},
          "id": "4zc4l456pca5ursrt9rxefpsc",
          "name": "Checkmark",
          "key": null,
          "_links": <String, dynamic>{},
        },
        {
          "type": {
            "name": "date",
            "componentTypes": ["datePicker", "textfield"],
          },
          "schema": {"type": "string", "format": "date"},
          "id": "4zc4l49to77dhfagr844flaey",
          "name": "Date",
          "key": null,
          "_links": <String, dynamic>{},
        },
        {
          "type": {
            "name": "string",
            "componentTypes": ["textfield"],
          },
          "schema": {"type": "string"},
          "id": "4zc4l45nmww7ujq7y4axlbtjg",
          "name": "Text",
          "key": null,
          "_links": <String, dynamic>{},
        },
        {
          "type": {
            "name": "integer",
            "componentTypes": ["textfield"],
          },
          "schema": {"type": "integer"},
          "id": "4zc4l48ffin5v8pa2emyx9s15",
          "name": "Number",
          "key": null,
          "_links": <String, dynamic>{},
        },
      ],
      'components': [
        {
          'property': 'TextC',
          'value': null,
          'required': false,
          'options': {
            'multi': false,
            'placeholder': '',
            'description': 'Text Description',
            'label': null,
          },
          'fieldId': '4zc4l45nmww7ujq7y4axlbtjg',
          'type': 'textfield',
        },
        {
          'property': 'NumberC',
          'value': null,
          'required': false,
          'options': {
            'multi': false,
            'placeholder': '',
            'description': 'Number description',
            'label': 'Number Label',
          },
          'fieldId': '4zc4l48ffin5v8pa2emyx9s15',
          'type': 'textfield',
        },
        {
          'property': 'DateTimeC',
          'value': null,
          'required': false,
          'options': {
            'label': 'DateTime Label',
            'description': 'DateTime Description',
          },
          'fieldId': '4zc4l4c5coyi7qh6q1ozrg54u',
          'type': 'datePicker',
        },
        {
          'property': 'DateC',
          'value': null,
          'required': false,
          'options': {'label': 'Date Label', 'description': 'Date Description'},
          'fieldId': '4zc4l49to77dhfagr844flaey',
          'type': 'datePicker',
        },
        {
          'property': 'CheckmarkC',
          'value': null,
          'required': false,
          'options': {
            'label': 'Checkbox Label',
            'description': 'Checkbox Description',
          },
          'fieldId': '4zc4l456pca5ursrt9rxefpsc',
          'type': 'checkbox',
        }
      ],
      'name': name,
      'title': title,
      'description': description,
      'id': 'formId',
      'properties': {
        'buttonTitle': submitButtonTitle,
        'reloadAfterSubmit': reloadAfterSubmit,
        'successTitle': successTitle,
        'successMessage': successMessage,
        'afterSubmitAction': {
          'action': 'additionalAnswer',
          'trigger': 'button',
          'buttonTitle': additionalAnswerButtonTitle,
        },
      },
      '_links': {
        "submit": {
          "href":
              "/api/users/614c5440b50f51e3ea8a2a50/spaces/62600bf5d7f0d75408996f69/grids/62600bf9d7f0d75408996f6c/forms/6262aadbcd22c4725899a114",
          "method": "post",
        },
        "remove": {
          "href":
              "/api/users/614c5440b50f51e3ea8a2a50/spaces/62600bf5d7f0d75408996f69/grids/62600bf9d7f0d75408996f6c/forms/6262aadbcd22c4725899a114",
          "method": "delete",
        },
        "self": {
          "href":
              "/api/users/614c5440b50f51e3ea8a2a50/spaces/62600bf5d7f0d75408996f69/grids/62600bf9d7f0d75408996f6c/forms/6262aadbcd22c4725899a114",
          "method": "get",
        },
        "update": {
          "href":
              "/api/users/614c5440b50f51e3ea8a2a50/spaces/62600bf5d7f0d75408996f69/grids/62600bf9d7f0d75408996f6c/forms/6262aadbcd22c4725899a114",
          "method": "put",
        },
      },
    };

    test('Single FormData', () async {
      response = createResponse(formDataJson);

      final formData = await client
          .performApptiveLinkForApptiveGridObject<FormData>(link: link);
      expect(formData, predicate((result) => result is FormData));
    });

    test('Simple List', () async {
      response = createResponse([formDataJson]);

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<FormData>>(link: link);
      expect(result, predicate((result) => result is List<FormData>));
    });

    test('Nested List', () async {
      response = createResponse({
        'items': [formDataJson],
      });

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<FormData>>(link: link);
      expect(result, predicate((result) => result is List<FormData>));
    });
  });

  group('SView', () {
    final sViewJson = {
      "type": "spreadsheet",
      "id": "63d28a8a78d9ca55c2af8b45",
      "name": "Grid Ansicht",
      "_links": {
        "self": {
          "href":
              "/api/users/609bd67b9fcca3ea397e70c6/spaces/63d28a8578d9ca55c2af8b3c/grids/63d28a8978d9ca2750af8b43/sviews/63d28a8a78d9ca55c2af8b45",
          "method": "get",
        },
      },
    };

    test('Single SView', () async {
      response = createResponse(sViewJson);

      final sView = await client.performApptiveLinkForApptiveGridObject<SView>(
        link: link,
      );
      expect(sView, predicate((result) => result is SView));
    });

    test('Simple List', () async {
      response = createResponse([sViewJson]);

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<SView>>(link: link);
      expect(result, predicate((result) => result is List<SView>));
    });

    test('Nested List', () async {
      response = createResponse({
        'items': [sViewJson],
      });

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<SView>>(link: link);
      expect(result, predicate((result) => result is List<SView>));
    });
  });

  group('Share', () {
    final shareJson = {
      "users": ["userId"],
      "emails": ["info@apptivegrid.de"],
      "role": "admin",
      "_links": {
        "self": {"href": "/share", "method": "get"},
      },
    };

    test('Single Share', () async {
      response = createResponse(shareJson);

      final share = await client.performApptiveLinkForApptiveGridObject<Share>(
        link: link,
      );
      expect(share, predicate((result) => result is Share));
    });

    test('Simple List', () async {
      response = createResponse([shareJson]);

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<Share>>(link: link);
      expect(result, predicate((result) => result is List<Share>));
    });

    test('Nested List', () async {
      response = createResponse({
        'items': [shareJson],
      });

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<Share>>(link: link);
      expect(result, predicate((result) => result is List<Share>));
    });
  });

  group('Invitation', () {
    final invitationJson = {
      "link": "/api/users/userId/spaces/spaceId/links/linkId",
      "role": "admin",
      "id": "invitationId",
      "email": "info@apptivegrid.de",
      "_links": {
        "self": {"href": "/invitation", "method": "get"},
      },
    };

    test('Single Invitation', () async {
      response = createResponse(invitationJson);

      final invitation =
          await client.performApptiveLinkForApptiveGridObject<Invitation>(
        link: link,
      );
      expect(invitation, predicate((result) => result is Invitation));
    });

    test('Simple List', () async {
      response = createResponse([invitationJson]);

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<Invitation>>(link: link);
      expect(result, predicate((result) => result is List<Invitation>));
    });

    test('Nested List', () async {
      response = createResponse({
        'items': [invitationJson],
      });

      final result = await client
          .performApptiveLinkForApptiveGridObject<List<Invitation>>(link: link);
      expect(result, predicate((result) => result is List<Invitation>));
    });
  });
}
