library progress_dialog;

import 'package:application_image_picker/application_platform.dart';
import 'package:application_image_picker/ulitilites/constant.dart';
import 'package:application_image_picker/ulitilites/dialog.dart';
import 'package:application_image_picker/ulitilites/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class ProgressDialog {
  bool _isShowing = false;

  BuildContext buildContext;

  ProgressDialog(this.buildContext);

  show() {
    _showDialog();
    _isShowing = true;
  }

  bool isShowing() {
    return _isShowing;
  }

  hide() {
    _isShowing = false;
    CustomNavigator().pop(buildContext);
  }

  _showDialog() {
    showDialog(
      barrierDismissible: false,
      context: buildContext,
      builder: (BuildContext context) {
        return WillPopScope(
          child: Scaffold(
            backgroundColor: Colors.black.withOpacity(0.3),
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: ApplicationPlatform.isIOS
                    ? CupertinoActivityIndicator()
                    : CircularProgressIndicator(),
              ),
            ),
          ),
          onWillPop: () async => false,
        );
      },
    );
  }
}

class CustomDialog extends StatelessWidget {
  final Widget screen;
  final bool bottom;
  final bool cancelable;
  final List<KeyboardActionsItem> actions;

  CustomDialog(
      {@required this.screen,
      this.bottom = false,
      this.cancelable = true,
      this.actions})
      : assert(screen != null && cancelable != null);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomKeyboardForm(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              GestureDetector(
                onTap: cancelable ? () => CustomNavigator().pop(context) : null,
              ),
              Column(
                mainAxisAlignment:
                    bottom ? MainAxisAlignment.end : MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: screen,
                  )
                ],
              )
            ],
          ),
        ),
      ),
      actions: actions ?? [],
    );
  }
}

class CustomPopupDialog extends StatelessWidget {
  final Widget child;
  final bool isExpanded;

  CustomPopupDialog({@required this.child, this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: isExpanded
          ? Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              height: MediaQuery.of(context).size.height * 0.5,
              child: child,
            )
          : Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: child,
            ),
      onTap: () => hideKeyboard(context),
    );
  }
}

hideKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
}

class CustomKeyboardForm extends StatelessWidget {
  final Widget body;
  final List<KeyboardActionsItem> actions;
  final Color backgroundColor;

  CustomKeyboardForm(
      {@required this.body, @required this.actions, this.backgroundColor})
      : assert(body != null && actions != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor ?? Colors.white,
        body: ApplicationPlatform.isAndroid
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: body,
              )
            : KeyboardActions(
                config: configKeyboardActions(actions),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: body,
                ),
              ));
  }
}

configKeyboardActions(List<KeyboardActionsItem> actions) {
  return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      actions: actions);
}

class CustomAlertDialog extends StatelessWidget {
  final Color color;
  final String icon;
  final String title;
  final Widget contentWidget;
  final String content;
  final List<CustomOptionDialog> options;
  final bool dismissible;

  CustomAlertDialog(
      {this.color,
      this.icon,
      this.title,
      this.contentWidget,
      this.content,
      this.options,
      this.dismissible = true});

  Widget _buildButton(String text, Color color, Function onTap) {
    return InkWell(
      child: Container(
        height: 40.0,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                color: color, fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    var maxWidth = MediaQuery.of(context).size.width;
    var maxPadding = maxWidth * 0.05;
    var minPadding = maxPadding / 2;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: InkWell(
        onTap: dismissible ? () => CustomNavigator().pop(context) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: maxPadding),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 10.0,
                    decoration: BoxDecoration(
                        color: color ?? Colors.blue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.all(maxPadding),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: color ?? Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                  child: icon != null
                                      ? ImageIcon(
                                          AssetImage(icon),
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : Icon(
                                          Icons.email,
                                          size: 20,
                                          color: Colors.white,
                                        )),
                            ),
                            Container(
                              width: maxPadding,
                            ),
                            Expanded(
                              child: Text(
                                title ?? Common.stringNotification,
                                textAlign: TextAlign.left,
                                softWrap: true,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            )
                          ],
                        ),
                        Container(
                          height: minPadding,
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              width: 40.0 + maxPadding,
                            ),
                            Expanded(
                              child: Container(
                                height: 1.0,
                                color: HexColor("E8E8E8"),
                              ),
                            )
                          ],
                        ),
                        Container(
                          height: maxPadding,
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              width: 40.0 + maxPadding,
                            ),
                            Expanded(
                              child: contentWidget ??
                                  Text(
                                    content ?? "",
                                    textAlign: TextAlign.left,
                                    softWrap: true,
                                    style: TextStyle(
                                        color: HexColor("A5A5A5"),
                                        fontSize: 15.0),
                                  ),
                            )
                          ],
                        ),
                        Container(
                          height: maxPadding,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: options == null
                              ? [
                                  _buildButton(
                                      Common.stringConfirm,
                                      color ?? Colors.blue,
                                      () => CustomNavigator().pop(context))
                                ]
                              : options
                                  .map((e) => Row(
                                        children: <Widget>[
                                          Container(
                                            width: maxPadding,
                                          ),
                                          _buildButton(
                                              e.text ?? "",
                                              e.isMain
                                                  ? Colors.blue
                                                  : (e.color ??
                                                      HexColor("6D6D6D")),
                                              e.onTap)
                                        ],
                                      ))
                                  .toList(),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomOptionDialog {
  final bool isMain;
  final String text;
  final Color color;
  final Function onTap;

  CustomOptionDialog(this.text, {this.isMain = true, this.color, this.onTap});
}
