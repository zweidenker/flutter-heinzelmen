// coverage:ignore-file

import 'package:apptive_grid_heinzelmen/src/invitation_dialog/invitation_localization.dart';

class InvitationLocalizationEn extends InvitationLocalization {
  const InvitationLocalizationEn() : super();

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSend => 'Send';

  @override
  String get hintEmail => 'Email';

  @override
  String get nonValidEmail => 'Valid email address necessary';

  @override
  String get message => 'Invite your team to this space';

  @override
  String get roleAdmin => 'Manage';

  @override
  String get roleReader => 'Read only';

  @override
  String get roleWriter => 'Edit entries';

  @override
  String get roleDescriptionAdmin => 'Fully edit and configure that space';

  @override
  String get roleDescriptionReader => 'Not edit or configure that space';

  @override
  String get roleDescriptionWriter => 'Edit Entries but not edit that space';

  @override
  String title(String spaceName) => 'Share $spaceName with others';

  @override
  String inviteSend(String email) => 'We send an invite to $email.';
}
