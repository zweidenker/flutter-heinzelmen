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
    if (data.value == null || (data.value is Iterable && data.value.isEmpty)) {
      return emptyBuilder?.call(context) ??
          Text(
            '-',
            style: textStyle,
          );
    }
    final locale = Localizations.localeOf(context).toString();
    return switch (data) {
      StringDataEntity() => Text(
          data.value,
          style: textStyle,
        ),
      DateTimeDataEntity() => Text(
          DateFormat.yMd(locale).add_Hm().format(data.value),
          style: textStyle,
        ),
      DateDataEntity() => Text(
          DateFormat.yMd(locale).format(data.value),
          style: textStyle,
        ),
      BooleanDataEntity() => IgnorePointer(
          child: SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(value: data.value, onChanged: (_) {}),
          ),
        ),
      IntegerDataEntity() => Text(
          data.value.toString(),
          style: textStyle,
        ),
      DecimalDataEntity() => Text(
          NumberFormat.decimalPattern(locale).format(data.value),
          style: textStyle,
        ),
      EnumDataEntity() => Chip(label: Text(data.value, style: textStyle)),
      EnumCollectionDataEntity() => Wrap(
          children: [
            for (final value in data.value)
              Chip(label: Text(value, style: textStyle)),
          ],
        ),
      CrossReferenceDataEntity() => Chip(
          label: Text(
            data.value,
            style: textStyle,
          ),
        ),
      AttachmentDataEntity() => Column(
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
        ),
      GeolocationDataEntity() => Text(
          [data.value.latitude, data.value.longitude].join(', '),
          style: textStyle,
        ),
      MultiCrossReferenceDataEntity() => Wrap(
          children: [
            for (final reference in data.value)
              Chip(
                label: Text(
                  reference.value,
                  style: textStyle,
                ),
              ),
          ],
        ),
      CreatedByDataEntity() => _CreatedBy(
          createdBy: data.value,
          textStyle: textStyle,
        ),
      UserDataEntity() => Chip(
          label: Text(data.value.displayValue, style: textStyle),
          avatar: ProfilePicture(
            userId: data.value.uri.pathSegments.last,
            name: data.value.displayValue,
          ),
        ),
      CurrencyDataEntity() => Text(
          NumberFormat.currency(
            locale: locale,
            symbol: NumberFormat()
                .simpleCurrencySymbol((data as CurrencyDataEntity).currency),
          ).format(data.value),
          style: textStyle,
        ),
      UriDataEntity() => InkWell(
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
        ),
      EmailDataEntity() => InkWell(
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
        ),
      PhoneNumberDataEntity() => InkWell(
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
        ),
      SignatureDataEntity() => AspectRatio(
          aspectRatio: 2,
          child: Thumbnail(attachment: data.value),
        ),
      DataEntity<DataEntity, dynamic>() => DataWidget(
          data: data.value!,
          textStyle: textStyle,
          emptyBuilder: emptyBuilder,
          linkLauncher: linkLauncher,
        ),
      ResourceDataEntity() => Text(
          data.value.name,
          style: textStyle,
        ),
    };
  }
}

class _CreatedBy extends StatelessWidget {
  const _CreatedBy({required this.createdBy, this.textStyle});

  final CreatedBy createdBy;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final label = switch (createdBy.type) {
      CreatedByType.user =>
        (createdBy.displayValue == null || createdBy.displayValue!.isEmpty)
            ? 'ApptiveGrid-User'
            : createdBy.displayValue!,
      CreatedByType.apiCredentials || CreatedByType.formLink => createdBy.name,
    };
    final Widget avatar = switch (createdBy.type) {
      CreatedByType.user => ProfilePicture(userId: createdBy.id, name: label),
      CreatedByType.apiCredentials => const SizedBox(
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
        ),
      CreatedByType.formLink => SizedBox(
          width: 24,
          height: 24,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ApptiveGridColors.form,
            ),
            child: Icon(
              ApptiveGridIcons.form,
              color: Colors.white,
              size: 16,
            ),
          ),
        )
    };

    return Chip(
      label: Text(label, style: textStyle),
      avatar: avatar,
    );
  }
}
