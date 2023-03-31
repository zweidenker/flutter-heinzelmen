// coverage:ignore-file

import 'package:apptive_grid_heinzelmen/src/invitation_dialog/invitation_localization.dart';

/// German Translations for [InvitationLocalization]
class InvitationLocalizationDE extends InvitationLocalization {
  /// Const constructor to call super
  const InvitationLocalizationDE() : super();

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSend => 'Senden';

  @override
  String get hintEmail => 'E-Mail';

  @override
  String get nonValidEmail => 'Gültige E-Mail Adresse notwendig';

  @override
  String get message => 'Laden Sie Ihr Team zu diesem Space ein';

  @override
  String get roleAdmin => 'Managen';

  @override
  String get roleReader => 'Nur ansehen';

  @override
  String get roleWriter => 'Einträge bearbeiten';

  @override
  String get roleDescriptionAdmin =>
      'diesen Space bearbeiten und konfigurieren';

  @override
  String get roleDescriptionReader =>
      'Inhalte bearbeiten aber nichts konfigurieren';

  @override
  String get roleDescriptionWriter =>
      'den Space nicht bearbeiten und konfigurieren';

  @override
  String title(String spaceName) => 'Teilen Sie $spaceName mit anderen';

  @override
  String inviteSend(String email) => 'Einladung an $email wurde gesendet';
}
