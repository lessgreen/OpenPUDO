import 'package:flutter/material.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/utilities/date_time_extension.dart';
import 'package:qui_green/models/openpudo_notification.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/widgets/table_view_cell.dart';

class NotificationTile extends StatelessWidget {
  final Function(OpenPudoNotification) onTap;
  final OpenPudoNotification notification;

  const NotificationTile({Key? key, required this.onTap, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: TableViewCell(
        onTap: () => onTap(notification),
        fullWidth: true,
        showTopDivider: false,
        dividerPadding: EdgeInsets.zero,
        showTrailingChevron: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (!notification.isRead)
                  Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(Dimension.borderRadiusSearch)),
                    margin: const EdgeInsets.only(right: Dimension.paddingS),
                  ),
                Text(
                  notification.createTms!.ddmmyyyy,
                  style: Theme.of(context).textTheme.bodyTextBold,
                ),
              ],
            ),
            Text(
              notification.message ?? "",
              style: Theme.of(context).textTheme.bodyTextLightSecondary,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
