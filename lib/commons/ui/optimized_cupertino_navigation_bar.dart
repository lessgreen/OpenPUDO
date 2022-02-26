import 'package:flutter/cupertino.dart';
import 'package:qui_green/resources/res.dart';

class OptimizedCupertinoNavigationBar {
  static CupertinoNavigationBar build(BuildContext context,
      {Brightness? brightness = Brightness.dark,
      EdgeInsetsDirectional? padding = EdgeInsetsDirectional.zero,
      Color? backgroundColor = AppColors.primaryColorDark,
      Widget? leading,
      Widget? middle,
      Widget? trailing}) {
    return CupertinoNavigationBar(
      padding: padding,
      brightness: brightness,
      backgroundColor: backgroundColor,
      leading: leading != null ? MediaQuery(data: MediaQueryData(textScaleFactor: MediaQuery.textScaleFactorOf(context)), child: leading) : null,
      trailing: trailing != null ? MediaQuery(data: MediaQueryData(textScaleFactor: MediaQuery.textScaleFactorOf(context)), child: trailing) : null,
      middle: middle != null ? MediaQuery(data: MediaQueryData(textScaleFactor: MediaQuery.textScaleFactorOf(context)), child: middle) : null,
    );
  }
}
