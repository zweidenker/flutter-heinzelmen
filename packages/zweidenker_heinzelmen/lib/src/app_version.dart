import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Shows the AppVersion String as Major.Minor.Patch.Build+Number based on the output of [getVersionInfo]
class AppVersion extends StatefulWidget {
  const AppVersion._({
    super.key,
    this.textStyle,
    required String Function(PackageInfo) calculateDisplayBuildNumber,
  }) : _calculateDisplayBuildNumber = calculateDisplayBuildNumber;

  /// Creates a TextWidget to show the output of [getVersionString] with [textStyle]
  /// During loading the build method will return a [SizedBox]
  const AppVersion({super.key, this.textStyle})
      : _calculateDisplayBuildNumber = _unscrambleBuildNumber;

  /// Creates a TextWidget to show the output of [getVersionString] with [textStyle]
  /// The displayed Build Number will be the result of the raw build number - offset
  factory AppVersion.offset({
    Key? key,
    TextStyle? textStyle,
    int offset = 0,
  }) {
    return AppVersion._(
      key: key,
      textStyle: textStyle,
      calculateDisplayBuildNumber: (info) =>
          _unscrambleWithOffset(info, offset: offset),
    );
  }

  /// TextStyle the Version will be shown with
  final TextStyle? textStyle;

  final String Function(PackageInfo) _calculateDisplayBuildNumber;

  @override
  State<AppVersion> createState() => _AppVersionState();
}

class _AppVersionState extends State<AppVersion> {
  String? _versionString;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getVersionInfo(widget._calculateDisplayBuildNumber).then((version) {
      _versionString = version;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_versionString != null) {
      return Text(
        _versionString!,
        style: widget.textStyle,
      );
    } else {
      return const SizedBox();
    }
  }
}

/// Gets the Version Number with an unscrambled Build Number
/// And returns it as Major.Minor.Patch+BuildNumber
Future<String> getVersionInfo([
  String Function(PackageInfo) displayBuildNumber = _unscrambleBuildNumber,
]) {
  return PackageInfo.fromPlatform().then((value) {
    return '${value.version}+${displayBuildNumber.call(value)}';
  });
}

/// Gets the Version Number with an unscrambled Build Number
/// The scrambling of the version is used bei the ZWEIDENKER CI Pipelines
/// The generation is:
/// Major * 100000000 +
///  Minor * 1000000 +
///  Patch * 10000 +
///  uniqueBuildNumber
///
/// CI code is here: https://github.com/zweidenker/flutter_workflows/blob/v1/.github/scripts/generate_build_number.sh
String _unscrambleBuildNumber(PackageInfo info) {
  final packagedBuildNumber = int.parse(info.buildNumber);

  // major, minor, patch
  final versions =
      info.version.split('.').map<int>((e) => int.parse(e)).toList();

  return (packagedBuildNumber -
          versions[0] * 100000000 -
          versions[1] * 1000000 -
          versions[2] * 10000)
      .toString();
}

/// Gets the Version Number with an unscrambled Build Number
/// The scrambling of the version is used bei the ZWEIDENKER CI Pipelines
/// The generation is:
/// Offset + unique Build Number
String _unscrambleWithOffset(PackageInfo info, {required int offset}) {
  final packagedBuildNumber = int.parse(info.buildNumber);

  return (packagedBuildNumber - offset).toString();
}
