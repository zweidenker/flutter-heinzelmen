abstract class InvitationLocalization {
  const InvitationLocalization();

  String title(String spaceName);

  String get message;

  String get hintEmail;

  String get nonValidEmail;

  String get roleAdmin;

  String get roleReader;

  String get roleWriter;

  String get roleDescriptionAdmin;

  String get roleDescriptionReader;

  String get roleDescriptionWriter;

  String get actionCancel;

  String get actionSend;

  String inviteSend(String email);
}
