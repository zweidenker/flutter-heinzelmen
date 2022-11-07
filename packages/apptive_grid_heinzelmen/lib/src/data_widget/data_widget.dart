import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:apptive_grid_heinzelmen/src/data_widget/attachment/thumbnail.dart';
import 'package:apptive_grid_heinzelmen/src/data_widget/profile_picture.dart';
import 'package:apptive_grid_theme/apptive_grid_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zweidenker_heinzelmen/zweidenker_heinzelmen.dart';

/// A Widget to Display a [DataEntity]
/// The Widget will adjust based on the type of DataEntity
class DataWidget extends StatelessWidget {
  /// Creates a new DataWidget for a given [data]
  ///
  /// The TextStyle will adjust to [textStyle]
  /// If [emptyBuilder] is null it will show a [Text] with '-' in case [data.value] is null or empty
  /// [UriDataEntity] will launch [UriDataEntity.value] with [linkLauncher] if it is null a new [LinkLauncher] will be created
  const DataWidget({
    super.key,
    required this.data,
    this.textStyle,
    this.emptyBuilder,
    this.linkLauncher,
  });

  /// The data that should be displayed
  final DataEntity data;

  /// The TextStyle that should be used
  final TextStyle? textStyle;

  /// A Builder that will be used to create a Widget for an empty [DataEntity]
  final WidgetBuilder? emptyBuilder;

  /// The [LinkLauncher] that will be used to launch [Uri]s in [UriDataEntity]s
  final LinkLauncher? linkLauncher;

  @override
  Widget build(BuildContext context) {
    if (data.value == null || (data.value is List && data.value.isEmpty)) {
      return emptyBuilder?.call(context) ??
          Text(
            '-',
            style: textStyle,
          );
    }

    if (data is StringDataEntity) {
      return Text(
        data.value,
        style: textStyle,
      );
    }

    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMd(locale);

    if (data is DateTimeDataEntity) {
      final timeFormat = dateFormat.add_Hm();

      return Text(
        timeFormat.format(data.value),
        style: textStyle,
      );
    }

    if (data is DateDataEntity) {
      return Text(
        dateFormat.format(data.value),
        style: textStyle,
      );
    }

    if (data is IntegerDataEntity) {
      return Text(
        data.value.toString(),
        style: textStyle,
      );
    }

    if (data is DecimalDataEntity) {
      final numberFormat = NumberFormat.decimalPattern(locale);
      return Text(
        numberFormat.format(data.value),
        style: textStyle,
      );
    }

    if (data is BooleanDataEntity) {
      return IgnorePointer(
        child: SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(value: data.value, onChanged: (_) {}),
        ),
      );
    }

    if (data is EnumDataEntity) {
      return Chip(label: Text(data.value, style: textStyle));
    }

    if (data is EnumCollectionDataEntity) {
      return Wrap(
        children: [
          for (final value in data.value)
            Chip(label: Text(value, style: textStyle))
        ],
      );
    }

    if (data is CrossReferenceDataEntity) {
      return Chip(
        label: Text(
          data.value,
          style: textStyle,
        ),
      );
    }

    if (data is AttachmentDataEntity) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final attachment in data.value)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Thumbnail(attachment: attachment),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(attachment.name, style: textStyle)),
              ],
            ),
        ],
      );
    }

    if (data is GeolocationDataEntity) {
      return Text(
        [data.value.latitude, data.value.longitude].join(', '),
        style: textStyle,
      );
    }

    if (data is MultiCrossReferenceDataEntity) {
      return Wrap(
        children: [
          for (final reference in data.value)
            Chip(
              label: Text(
                reference.value,
                style: textStyle,
              ),
            ),
        ],
      );
    }

    if (data is CreatedByDataEntity) {
      late final String label;
      late final Widget avatar;
      final createdBy = data.value;
      switch (createdBy.type) {
        case CreatedByType.user:
          if (createdBy.displayValue == null ||
              createdBy.displayValue!.isEmpty) {
            label = 'ApptiveGrid-User';
          } else {
            label = createdBy.displayValue;
          }
          avatar = ProfilePicture(userId: createdBy.id, name: label);
          break;
        case CreatedByType.apiCredentials:
          label = createdBy.name;
          avatar = const SizedBox(
            width: 24,
            height: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ApptiveGridColors.apptiveGridBlue,
              ),
              child: Icon(
                Icons.api,
                color: Colors.white,
                size: 16,
              ),
            ),
          );
          break;
        case CreatedByType.formLink:
          label = createdBy.name;
          avatar = const SizedBox(
            width: 24,
            height: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ApptiveGridColors.form,
              ),
              child: Icon(
                ApptiveGridIcons.form,
                color: Colors.white,
                size: 16,
              ),
            ),
          );
          break;
      }

      return Chip(
        label: Text(label, style: textStyle),
        avatar: avatar,
      );
    }

    if (data is UserDataEntity) {
      final user = data.value;
      return Chip(
        label: Text(user.displayValue, style: textStyle),
        avatar: ProfilePicture(
          userId: user.uri.pathSegments.last,
          name: user.displayValue,
        ),
      );
    }

    if (data is CurrencyDataEntity) {
      final currencyFormat = NumberFormat.currency(
        locale: Localizations.localeOf(context).toString(),
        symbol: NumberFormat()
            .simpleCurrencySymbol((data as CurrencyDataEntity).currency),
      );
      return Text(
        currencyFormat.format(data.value),
        style: textStyle,
      );
    }

    if (data is UriDataEntity) {
      return InkWell(
        onTap: () {
          (linkLauncher ?? const LinkLauncher())
              .openWebPage(url: data.value, openExternally: true);
        },
        child: Text(
          data.value.toString(),
          style: (textStyle ?? const TextStyle()).copyWith(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    if (data is PhoneNumberDataEntity) {
      return InkWell(
        onTap: () {
          (linkLauncher ?? const LinkLauncher()).openWebPage(
            url: Uri.parse('tel:${data.value}'),
            openExternally: true,
          );
        },
        child: Text(
          data.value.toString(),
          style: (textStyle ?? const TextStyle()).copyWith(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    if (data is EmailDataEntity) {
      return InkWell(
        onTap: () {
          (linkLauncher ?? const LinkLauncher()).openWebPage(
            url: Uri.parse('mailto:${data.value}'),
            openExternally: true,
          );
        },
        child: Text(
          data.value.toString(),
          style: (textStyle ?? const TextStyle()).copyWith(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    if (data is SignatureDataEntity) {
      return AspectRatio(
        aspectRatio: 2,
        child: Thumbnail(attachment: data.value),
      );
    }

    return Text(
      data.value.toString(),
      style: textStyle,
    );
  }
}
