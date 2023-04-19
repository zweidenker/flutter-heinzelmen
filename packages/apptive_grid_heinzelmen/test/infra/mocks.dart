import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:apptive_grid_core/src/network/authentication/apptive_grid_authenticator.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zweidenker_heinzelmen/zweidenker_heinzelmen.dart';

class MockLinkLauncher extends Mock implements LinkLauncher {}

class MockApptiveGridClient extends Mock implements ApptiveGridClient {}

class MockHttpClient extends Mock implements Client {}

class MockApptiveGridAuthenticator extends Mock
    implements ApptiveGridAuthenticator {}
