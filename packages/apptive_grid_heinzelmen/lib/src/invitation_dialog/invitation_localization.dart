/// Translations for [InvitationDialog]
abstract class InvitationLocalization {
  /// Const Constructor
  const InvitationLocalization();

  /// A Title for the dialog that will be called with [spaceName] which is the Name of the Space that shoul;d be shared
  /// [spaceName] will be colored in the theme's primary color
  String title(String spaceName);

  /// A description message in the dialog
  String get message;

  /// Hint for the Email Input
  String get hintEmail;

  /// Message when the Entered Email is not a valid email address
  String get nonValidEmail;

  /// Label for Admin Role
  String get roleAdmin;

  /// Label for Reader Role
  String get roleReader;

  /// Label for Writer Role
  String get roleWriter;

  /// Description for Admin Role
  String get roleDescriptionAdmin;

  /// Description for Reader Role
  String get roleDescriptionReader;

  /// Description for Writer Role
  String get roleDescriptionWriter;

  /// Label for cancel Button
  String get actionCancel;

  /// Label for send button
  String get actionSend;

  /// A message that will be displayed in a SnackBar after an invite was send
  /// [email] is the email that was invited. It will be formatted bold
  String inviteSend(String email);
}
