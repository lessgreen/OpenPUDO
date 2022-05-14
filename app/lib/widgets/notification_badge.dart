import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimension.padding),
      child: Consumer<CurrentUser>(
        builder: (BuildContext context, currentUser, Widget? child) => InkWell(
          child: Badge(
              animationType: BadgeAnimationType.fade,
              elevation: 0,
              showBadge: currentUser.unreadNotifications > 0,
              badgeContent: currentUser.unreadNotifications > 99
                  ? Text(
                      "+99",
                      style: Theme.of(context).textTheme.captionWhite,
                    )
                  : Text(
                      currentUser.unreadNotifications.toString(),
                      style: Theme.of(context).textTheme.captionWhite,
                    ),
              shape: currentUser.unreadNotifications > 99 ? BadgeShape.square : BadgeShape.circle,
              borderRadius: BorderRadius.circular(Dimension.borderRadiusSearch),
              child: SvgPicture.asset(
                ImageSrc.bell,
                width: 30,
                height: 30,
                color: Colors.white,
              )),
          onTap: () => Navigator.of(context).pushNamed(Routes.notificationsList),
        ),
      ),
    );
  }
}
