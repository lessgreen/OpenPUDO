import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/utilities/date_time_extension.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/widgets/table_view_cell.dart';

class PackageTile extends StatelessWidget {
  final Function(PackageSummary) onTap;
  final PackageSummary packageSummary;

  const PackageTile({Key? key, required this.onTap, required this.packageSummary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableViewCell(
      onTap: () => onTap(packageSummary),
      fullWidth: true,
      showTrailingChevron: true,
      title: SizedBox(
          height: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${packageSummary.createTms!.ddmmyyyy} ${packageSummary.packageName ?? ""}",
                style: Theme.of(context).textTheme.bodyTextBold,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(style: Theme.of(context).textTheme.bodyTextLight!.copyWith(color: CupertinoColors.secondaryLabel), children: [
                  const TextSpan(text: "Destinatario: "),
                  TextSpan(text: "AC${packageSummary.userId}", style: Theme.of(context).textTheme.bodyTextBold),
                ]),
              ),
            ],
          )),
    );
  }
}
