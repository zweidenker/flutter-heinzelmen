import 'dart:convert';

import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:apptive_grid_heinzelmen/src/invitation_dialog/invitation_l10n_de.dart';
import 'package:apptive_grid_heinzelmen/src/invitation_dialog/invitation_l10n_en.dart';
import 'package:apptive_grid_heinzelmen/src/invitation_dialog/invitation_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

export 'package:apptive_grid_heinzelmen/src/invitation_dialog/invitation_localization.dart';

/// Shows a Dialog to invite/add someone to a [Space]
/// [space] is the [Space] that should be shared. [Space.links] needs to contain the Link for [type]
/// Also [type] needs to be either [ApptiveLinkType.invite] or [ApptiveLinkType.addSpace]
/// Note: Even when using [ApptiveLinkType.addSpace] the Ui will display Strings pointing to the user being invited to a space
/// This can be prevented by using a custom [localization]
///
/// It is also possible to define which [roles] can be added. This can't be empty. Also if it only contains one [Role] the selection box is not shown
/// This will return a Future<bool> which will return if one or more invites where send
Future<bool> showSpaceInvitationDialog({
  required BuildContext context,
  required Space space,
  List<Role> allowedRoles = Role.values,
  ApptiveLinkType type = ApptiveLinkType.invite,
  InvitationLocalization? localization,
}) async {
  assert(type == ApptiveLinkType.invite || type == ApptiveLinkType.addShare);
  assert(space.links.containsKey(type));
  assert(allowedRoles.isNotEmpty);

  final l10n = localization ??
      (Localizations.localeOf(context).languageCode == 'de'
          ? const InvitationLocalizationDE()
          : const InvitationLocalizationEn());

  TextEditingController emailController = TextEditingController();
  ValueNotifier<Role> roleNotifier = ValueNotifier(allowedRoles.first);
  ValueNotifier<bool> loading = ValueNotifier(false);
  ValueNotifier<dynamic> errorNotifier = ValueNotifier(null);
  bool dialogResult = false;
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return ValueListenableBuilder<bool>(
        valueListenable: loading,
        builder: (_, loading, child) => IgnorePointer(
          ignoring: loading,
          child: child,
        ),
        child: Form(
          child: AlertDialog(
            title: Text.rich(
              TextSpan(
                children: getHighlightSpans(
                  getText: l10n.title,
                  highlight: space.name,
                  highlightStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            content: _InvitationDialogContent(
              emailController: emailController,
              role: roleNotifier,
              error: errorNotifier,
              allowedRoles: allowedRoles,
              localization: l10n,
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(dialogContext).pop,
                child: Text(l10n.actionCancel),
              ),
              _InvitationSendButton(
                loading: loading,
                role: roleNotifier,
                error: errorNotifier,
                onInviteSend: (value) => dialogResult = value,
                localization: l10n,
                email: emailController,
                link: space.links[type]!,
              ),
            ],
          ),
        ),
      );
    },
  ).then((_) => dialogResult);
}

/// Returns a List of [TextSpans] that format [highlight] with [highlightStyle]
/// This will call [getText] with [highlight] to get a String where [highlight] can be substituted in
/// It will return a List of [TextSpan] where the first occurrence of [highlight] has [highlightStyle] as the applied style
/// If [highlight] appears in [getText] but is not the substituted value this will not be counted as the first occurrence
/// Only the first [highlight] will be styled with [highlightStyle]
@visibleForTesting
List<TextSpan> getHighlightSpans({
  required String Function(String) getText,
  required String highlight,
  required TextStyle highlightStyle,
}) {
  final emptyTitle = getText('');
  final realTitle = getText(highlight);

  if (realTitle.length == emptyTitle.length) {
    return [TextSpan(text: realTitle)];
  } else {
    int startIndex = emptyTitle.length;
    for (int i = 0; i < emptyTitle.length; i++) {
      if (realTitle[i] != emptyTitle[i]) {
        startIndex = i;
        break;
      }
    }
    return [
      if (startIndex != 0) TextSpan(text: realTitle.substring(0, startIndex)),
      TextSpan(text: highlight, style: highlightStyle),
      if (startIndex + highlight.length < realTitle.length)
        TextSpan(text: realTitle.substring(startIndex + highlight.length)),
    ];
  }
}

class _InvitationDialogContent extends StatelessWidget {
  const _InvitationDialogContent({
    required this.emailController,
    required this.role,
    required this.error,
    required this.allowedRoles,
    required this.localization,
  });

  final TextEditingController emailController;
  final ValueNotifier<Role> role;
  final ValueNotifier<dynamic> error;
  final List<Role> allowedRoles;
  final InvitationLocalization localization;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<dynamic>(
      valueListenable: error,
      builder: (context, error, _) {
        return ValueListenableBuilder<Role>(
          valueListenable: role,
          builder: (context, role, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(localization.message),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(value ?? '')) {
                        return localization.nonValidEmail;
                      } else {
                        return null;
                      }
                    },
                    inputFormatters: [FilteringTextInputFormatter.deny(' ')],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      hintText: localization.hintEmail,
                    ),
                  ),
                ),
                if (allowedRoles.length > 1)
                  DropdownButton<Role>(
                    value: role,
                    isExpanded: true,
                    itemHeight: null,
                    underline: const SizedBox(),
                    selectedItemBuilder: (_) => allowedRoles
                        .map(
                          (role) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(_roleTitle(role)),
                          ),
                        )
                        .toList(),
                    items: allowedRoles
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: ListTile(
                              title: Text(_roleTitle(role)),
                              subtitle: Text(_roleSubTitle(role)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (newRole) {
                      if (newRole != null) {
                        this.role.value = newRole;
                      }
                    },
                  ),
                if (error != null)
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  String _roleTitle(Role role) {
    switch (role) {
      case Role.admin:
        return localization.roleAdmin;
      case Role.reader:
        return localization.roleReader;
      case Role.writer:
        return localization.roleWriter;
    }
  }

  String _roleSubTitle(Role role) {
    switch (role) {
      case Role.admin:
        return localization.roleDescriptionAdmin;
      case Role.reader:
        return localization.roleDescriptionReader;
      case Role.writer:
        return localization.roleDescriptionWriter;
    }
  }
}

class _InvitationSendButton extends StatefulWidget {
  const _InvitationSendButton({
    required this.loading,
    required this.role,
    required this.error,
    required this.onInviteSend,
    required this.localization,
    required this.email,
    required this.link,
  });

  final ValueNotifier<bool> loading;
  final ValueNotifier<Role> role;
  final ValueNotifier<dynamic> error;
  final void Function(bool) onInviteSend;
  final InvitationLocalization localization;
  final TextEditingController email;
  final ApptiveLink link;

  @override
  State<_InvitationSendButton> createState() => _InvitationSendButtonState();
}

class _InvitationSendButtonState extends State<_InvitationSendButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.loading,
      builder: (context, loading, _) {
        return TextButton(
          onPressed: _send,
          child: loading
              ? const SizedBox(
                  width: 32,
                  height: 16,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Text(widget.localization.actionSend),
        );
      },
    );
  }

  Future<void> _send() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (Form.of(context).validate()) {
      final client = ApptiveGrid.getClient(context, listen: false);
      widget.loading.value = true;
      widget.error.value = null;
      try {
        final email = widget.email.text;
        await client.performApptiveLink<bool>(
          link: widget.link,
          body: {
            'email': email,
            'role': widget.role.value.backendName,
          },
          parseResponse: (response) async {
            widget.email.clear();
            Form.of(context).reset();
            widget.onInviteSend(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text.rich(
                  TextSpan(
                    children: getHighlightSpans(
                      getText: widget.localization.inviteSend,
                      highlight: widget.email.text,
                      highlightStyle:
                          const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
            return response.statusCode < 300;
          },
        );
      } catch (error) {
        if (error is Response) {
          try {
            final body = jsonDecode(error.body);
            if (body is Map && body['description'] != null) {
              widget.error.value = body['description'];
            } else {
              widget.error.value = body;
            }
          } catch (_) {
            widget.error.value = error;
          }
        } else {
          widget.error.value = error;
        }
      } finally {
        widget.loading.value = false;
      }
    }
  }
}
