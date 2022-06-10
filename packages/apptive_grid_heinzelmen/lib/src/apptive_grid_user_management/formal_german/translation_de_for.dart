// ignore_for_file: type=lint
// coverage:ignore-file

import 'package:apptive_grid_user_management/src/translation/l10n/translation_de.dart'
    as de;

/// Formal German Translations for ApptiveGridUserManagementTranslations
/// to use this instead of the default Strings that address the user with 'DU' add this to the ApptiveGridUserManagement Widget like this
///
/// ```
/// ApptiveGridUserManagement(
///     customTranslations: {
///         const Locale.fromSubtags(languageCode: 'de'):
///             FormalGermanApptiveGridUserManagementTranslation(),
///         },
///    ...
/// ```
class FormalGermanApptiveGridUserManagementTranslation
    extends de.ApptiveGridUserManagementLocalizedTranslation {
  const FormalGermanApptiveGridUserManagementTranslation() : super();

  @override
  String get registerWaitingForConfirmation =>
      'Alles klar!\nWir haben Ihnen eine Mail geschickt, um den Account zu bestätigen.';

  @override
  String get confirmAccountCreation => 'Bestätigen Sie Ihren Account';

  @override
  String get errorLogin =>
      'Beim Login ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get errorRegister =>
      'Bei der Registrierung ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get errorConfirm =>
      'Beim bestätigen des Accounts ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get forgotPasswordMessage =>
      'Wir können Ihnen einen Link schicken, mit dem Sie Ihr Passwort zurücksetzen können.';

  @override
  String get resetPasswordSuccess =>
      'Ihr Passwort wurde erfolgreich zurückgesetzt.';

  @override
  String get errorUnknown =>
      'Leider ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get errorReset =>
      'Passwort konnte nicht zurückgesetzt werden. Bitte versuchen Sie es erneut.';

  @override
  String registerConfirmAddToGroup({
    required String email,
    required String app,
  }) =>
      'Es existiert bereits ein Account mit der Adresse $email.\nWir haben Ihnen einen Link geschickt, mit dem Sie bestätigen können, dass Sie den Account für "$app" freischalten möchten.\nIhr Passwort wurde nicht geändert.';

  @override
  String joinGroup(String app) =>
      'Ihr Account ist noch nicht für $app freigeschaltet.\nWollen Sie Ihren Account jetzt freischalten?';
}
