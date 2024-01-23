import 'dart:math';

import 'package:flutter/material.dart';

/// A Profile Picture for a User with [userId]
class ProfilePicture extends StatelessWidget {
  /// Creates a Profile Picture Widget
  const ProfilePicture({
    super.key,
    required this.userId,
    required this.name,
  });

  /// Id of the user to display the profile picture for
  final String userId;

  /// Name of the user. Used to build the initials while loading the picture and if the user has no picture
  final String name;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return ClipRRect(
          borderRadius: BorderRadius.circular(size),
          child: Builder(
            builder: (builderContext) {
              // TODO: Remove catch once this issue is fixed on stable https://github.com/flutter/flutter/issues/107416
              try {
                return Image.network(
                  'https://apptiveavatarupload-apptiveavataruploadbucket-17hw58ak4gvs6.s3.eu-central-1.amazonaws.com/$userId.jpg',
                  fit: BoxFit.cover,
                  frameBuilder: (frameContext, child, _, __) {
                    return _initialsBuilder(frameContext, child);
                  },
                  errorBuilder: (errorContext, _, __) {
                    return _initialsBuilder(errorContext);
                  },
                );
              } catch (_) {
                return _initialsBuilder(builderContext);
              }
            },
          ),
        );
      },
    );
  }

  Widget _initialsBuilder(
    BuildContext context, [
    Widget? child,
  ]) {
    final initialsBuffer = StringBuffer();
    final names = name.split(' ');
    initialsBuffer.write(names.first.characters.first);
    if (names.length > 1) {
      initialsBuffer.write(names.last.characters.first);
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: colorScheme.primary,
          child: Center(
            child: Text(
              initialsBuffer.toString(),
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (child != null) child,
      ],
    );
  }
}

/// Ignoring Function useful for using `apptive_grid_error_reporting`
/// If this is used inside the `ignoreError` callback of `ApptiveGridErrorReporting`
/// this will not report FlutterError that are reported when requesting ProfilePicture from Users that do not have a Profile Picture set
bool ignoreNoProfilePictureError(dynamic error) {
  if (error is NetworkImageLoadException &&
      error.uri.host ==
          'apptiveavatarupload-apptiveavataruploadbucket-17hw58ak4gvs6.s3.eu-central-1.amazonaws.com' &&
      error.statusCode == 403) {
    return true;
  }
  return false;
}
