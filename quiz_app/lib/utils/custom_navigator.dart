import 'package:flutter/material.dart';

class CreateNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget widget;
  const CreateNavigator({
    super.key,
    required this.navigatorKey,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        builder = (context) => widget;
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}