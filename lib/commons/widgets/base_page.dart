import 'package:flutter/material.dart';
import 'package:qui_green/models/page_type.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

class BasePage extends StatelessWidget {
  const BasePage({
    Key? key,
    required this.body,
    required this.index,
    required this.headerVisible,
    required this.icon,
    required this.onPressedIcon,
    required this.title,
    required this.showBackIcon,
    required this.onPressedBack,
  }) : super(key: key);

  final Widget body;
  final int index;
  final bool headerVisible;
  final Icon icon;
  final Function()? onPressedIcon;
  final String title;
  final bool showBackIcon;
  final Function()? onPressedBack;

  String fromIndexToRouteName(index) {
    switch (index) {
      case 0:
        return Routes.home;
      case 1:
        return Routes.homePudo;
      default:
        return Routes.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerVisible
          ? AppBar(
              backgroundColor: AppColors.primaryColorDark,
              leading: showBackIcon
                  ? Padding(
                      padding: const EdgeInsets.only(left: Dimension.padding),
                      child: InkWell(
                        onTap: onPressedBack,
                        child: const Icon(Icons.arrow_back_ios),
                      ),
                    )
                  : SizedBox(),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: Dimension.padding),
                  child: InkWell(
                    onTap: onPressedIcon,
                    child: icon,
                  ),
                ),
              ],
              title: Text(title),
            )
          : null,
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (val) => Navigator.of(context)
            .pushReplacementNamed(fromIndexToRouteName(val)),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Pudo'),
        ],
      ),
    );
  }
}
