import 'package:application_image_picker/constant.dart';
import 'package:application_image_picker/hex_color.dart';
import 'package:application_image_picker/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';


openAlertDialog(BuildContext context, String title, String content,
    [Function func]) async {
  return await showDialog(
      context: (context != null)
          ? context
          : NavigationService.singleton.navigatorKey.currentContext,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          content: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.all(Radius.circular(5))),
              height: 220,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 27),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(bottom: 11),
                    child: Text(
                      title,
                      style: TextStyle(
                          color: HexColor("#333333"),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      child: Text(
                        content,
                        style:
                            TextStyle(color: HexColor("#333333"), fontSize: 14),
                      ),
                    ),
                  )),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        // height: 80,
                        alignment: Alignment.bottomCenter,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            func == null
                                ? CustomNavigator().pop(context)
                                : () {
                                    CustomNavigator().pop(context);
                                    func();
                                  }();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.blue,
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 40),
                              child: Text(
                                Common.stringConfirm,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ))
                ],
              )),
        );
      });
}

class NavigationService {
  //singleton
  static final NavigationService _singleton = new NavigationService._internal();

  static NavigationService get singleton => _singleton;

  bool needToShowPopup = false;

  factory NavigationService() {
    return _singleton;
  }

  NavigationService._internal();

  GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  bool shouldOpenExistProduct;

  Future<dynamic> pushNamed(String routeName, {Object argument}) {
    return navigatorKey.currentState.pushNamed(routeName, arguments: argument);
  }

  Future<dynamic> pushNamedAndRemoveUntil(
      String routeName, bool Function(Route<dynamic>) predicate,
      {Object argument}) {
    return navigatorKey.currentState
        .pushNamedAndRemoveUntil(routeName, predicate, arguments: argument);
  }

  Future<dynamic> pushAndRemoveUntil<T extends Object>(
      Route<T> newRoute, bool Function(Route<dynamic>) predicate) {
    return navigatorKey.currentState.pushAndRemoveUntil(newRoute, predicate);
  }

  Future<dynamic> push<T extends Object>(Route<T> route) {
    return navigatorKey.currentState.push(route);
  }

  Future<dynamic> pushReplacement<T extends Object>(Route<T> route) {
    return navigatorKey.currentState.pushReplacement(route);
  }

  Future<dynamic> pushReplacementNamed(String routeName) {
    return navigatorKey.currentState.pushReplacementNamed(routeName);
  }

  void pop<T extends Object>([T result]) {
    return navigatorKey.currentState.pop(result);
  }

  void popUntil<T extends Object>(bool Function(Route<dynamic>) predicate) {
    return navigatorKey.currentState.popUntil(predicate);
  }
}

extension NavigatorStateExtension on NavigatorState {
  removeHUD() {
    bool isHUDOn = false;
    popUntil((route) {
      if (route.settings.name == Common.keyHUD) {
        isHUDOn = true;
      }
      return true;
    });

    if (isHUDOn) CustomNavigator().hideProgressDialog();
  }
}

class CustomNavigator {
  static ProgressDialog _pr;
  showProgressDialog(BuildContext context) {
    if (_pr == null) {
      _pr = ProgressDialog(context);
      _pr.show();
    }
  }

  hideProgressDialog() {
    if (_pr != null && _pr.isShowing()) {
      _pr.hide();
      _pr = null;
    }
  }

  push(BuildContext context, Widget screen,
      {bool root = true, bool opaque = true, bool isHero = false}) {
    Navigator.of(context, rootNavigator: root).removeHUD();
    return Navigator.of(context, rootNavigator: root)
        .push(CustomRoute(page: screen, opaque: opaque, isHero: isHero));
  }

  popToScreen(BuildContext context, Widget screen, {bool root = true}) {
    Navigator.of(context, rootNavigator: root).popUntil(
        (route) => route.settings.name == screen.runtimeType.toString());
  }

  popToRoot(BuildContext context, {bool root = true}) {
    Navigator.of(context, rootNavigator: root)
        .popUntil((route) => route.isFirst);
  }

  pop(BuildContext context, {dynamic object, bool root = true}) {
    if (object == null)
      Navigator.of(context, rootNavigator: root).pop();
    else
      Navigator.of(context, rootNavigator: root).pop(object);
  }

  pushReplacement(BuildContext context, Widget screen,
      {bool root = true, bool opaque = true, bool isHero = false}) {
    Navigator.of(context, rootNavigator: root).removeHUD();
    Navigator.of(context, rootNavigator: root).pushReplacement(
        CustomRoute(page: screen, opaque: opaque, isHero: isHero));
  }

  popToRootAndPushReplacement(BuildContext context, Widget screen,
      {bool root = true, bool opaque = true, bool isHero = false}) {
    Navigator.of(context, rootNavigator: root)
        .popUntil((route) => route.isFirst);
    Navigator.of(context, rootNavigator: root).pushReplacement(
        CustomRoute(page: screen, opaque: opaque, isHero: isHero));
  }

  showCustomPopupDialog(
    BuildContext context,
    Widget child, {
    bool root = true,
    bool isExpanded = false,
    bool cancelable = true,
    List<KeyboardActionsItem> actions,
  }) {
    return push(
        context,
        CustomDialog(
          screen: CustomPopupDialog(
            child: child,
            isExpanded: isExpanded,
          ),
          actions: actions,
          cancelable: cancelable,
        ),
        opaque: false,
        root: root);
  }

  showCustomBottomDialog(BuildContext context, Widget screen,
      {bool root = true, isScrollControlled = true}) {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: root,
        isScrollControlled: isScrollControlled,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return GestureDetector(
            child: screen,
            onTap: () {},
            behavior: HitTestBehavior.opaque,
          );
        });
  }
}

class CustomRoute extends PageRouteBuilder {
  final Widget page;
  final bool opaque;
  final bool isHero;
  CustomRoute({this.page, this.opaque = true, this.isHero = false})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                page,
            transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) =>
                (isHero || !opaque)
                    ? FadeTransition(
                        opacity: Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      )
                    : SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
            opaque: opaque,
            transitionDuration: Duration(milliseconds: isHero ? 1500 : 300));

  @override
  // TODO: implement settings
  RouteSettings get settings => opaque
      ? RouteSettings(name: page.runtimeType.toString())
      : super.settings;
}
