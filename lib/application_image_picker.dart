import 'dart:async';
import 'dart:io';
import 'package:application_image_picker/ulitilites/constant.dart';
import 'package:application_image_picker/ulitilites/dialog.dart';
import 'package:application_image_picker/ulitilites/hex_color.dart';
import 'package:application_image_picker/ulitilites/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RetroImagePicker {
  static Future<File> pickImage(BuildContext context,
      {@required RetroImageSource source,
      double maxWidth,
      double maxHeight,
      int imageQuality,
      String strConfirm,
      String strNotification,
      String strAlertCamera,
      String strSelectGallery,
      String strTakePhoto,
      String appBarColor,
      String titleAppBar}) async {
    Common().init(
      strAlertCamera: strAlertCamera,
      strConfirm: strConfirm,
      strNotification: strNotification,
      strSelectGallery: strSelectGallery,
      strTakePhoto: strTakePhoto,
    );
    return ApplicationImagePicker.pickImage(context,
        source: source == RetroImageSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: imageQuality,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        appBarColor: appBarColor,
        titleAppBar: titleAppBar);
  }

  static Future<List<File>> pickImages(BuildContext context,
      {@required RetroImageSource source,
      double maxWidth,
      double maxHeight,
      int imageQuality,
      String strConfirm,
      String strNotification,
      String strAlertCamera,
      String strSelectGallery,
      String strTakePhoto,
      String appBarColor,
      String titleAppBar,
      int limitMultiPick}) async {
    Common().init(
      strAlertCamera: strAlertCamera,
      strConfirm: strConfirm,
      strNotification: strNotification,
      strSelectGallery: strSelectGallery,
      strTakePhoto: strTakePhoto,
    );
    Future<List<File>> results = ApplicationImagePicker.pickImages(context,
        imageQuality: imageQuality,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        appBarColor: appBarColor,
        titleAppBar: titleAppBar,
        limitMultiPick: limitMultiPick);
    List<File> result = await results;
    if (result != null) {
      for (int i = 0; i <= result.length - 1; i++) {
        result[i] = await ApplicationImagePicker.compressImage(result[i]);
      }
    }
    await Future.delayed(Duration(seconds: 1));
    return result;
  }

  static Future<File> openPictureSelection(BuildContext context,
      {String strConfirm,
      String strNotification,
      String strAlertCamera,
      String strSelectGallery,
      String strTakePhoto,
      String appBarColor,
      String titleAppBar}) async {
    Common().init(
      strAlertCamera: strAlertCamera,
      strConfirm: strConfirm,
      strNotification: strNotification,
      strSelectGallery: strSelectGallery,
      strTakePhoto: strTakePhoto,
    );
    String option = await showModalBottomSheet<String>(
        context: context,
        elevation: 1,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return renderPictureSelection(context);
        });
    if (option == "gallery") {
      return await _showPopupImage(context, 0,
          appBarColor: appBarColor, titleAppBar: titleAppBar);
    } else if (option == "camera") {
      return await _showPopupImage(context, 1,
          appBarColor: appBarColor, titleAppBar: titleAppBar);
    }
    return null;
  }

  static Future<List<File>> openPicturesSelection(BuildContext context,
      {String strConfirm,
      String strNotification,
      String strAlertCamera,
      String strSelectGallery,
      String strTakePhoto,
      String appBarColor,
      String titleAppBar}) async {
    Common().init(
      strAlertCamera: strAlertCamera,
      strConfirm: strConfirm,
      strNotification: strNotification,
      strSelectGallery: strSelectGallery,
      strTakePhoto: strTakePhoto,
    );
    String option = await showModalBottomSheet<String>(
        context: context,
        elevation: 1,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return renderPictureSelection(context);
        });
    if (option == "gallery") {
      return await _showPopupImages(context, 0,
          appBarColor: appBarColor, titleAppBar: titleAppBar);
    } else if (option == "camera") {
      return await _showPopupImages(context, 1,
          appBarColor: appBarColor, titleAppBar: titleAppBar);
    }
    return null;
  }

  static Widget renderPictureSelection(BuildContext context) {
    return Container(
        height: 180,
        child: Column(children: <Widget>[
          Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(top: 15, bottom: 5),
            alignment: Alignment.center,
            child: Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(2.5)),
                  color: Colors.white),
            ),
          ),
          Expanded(child: LayoutBuilder(builder:
              (BuildContext context, BoxConstraints viewportConstraints) {
            return ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              height: 30,
                              width: 30,
                              child: FlatButton(
                                onPressed: () {
                                  CustomNavigator().pop(context, object: null);
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                  child: Icon(
                                    Icons.close,
                                    color: HexColor("#C6C6C6"),
                                    size: 20,
                                  ),
                                  alignment: Alignment.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            CustomNavigator().pop(context, object: "gallery");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: HexColor("#C6C6C6"),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.filter,
                                  color: Colors.blue,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 18),
                                  child: Text(
                                    Common.selectGallery ?? "",
                                    style: TextStyle(
                                        color: HexColor("#333333"),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          )),
                      GestureDetector(
                          onTap: () {
                            CustomNavigator().pop(context, object: "camera");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: HexColor("#C6C6C6"),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.camera_alt,
                                  color: Colors.blue,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 18),
                                  child: Text(
                                    Common.takePhoto,
                                    style: TextStyle(
                                        color: HexColor("#333333"),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ))
                    ],
                  )),
            );
          }))
        ]));
  }

  static Future<File> _showPopupImage(BuildContext context, int imageType,
      {String appBarColor, String titleAppBar}) async {
    if (imageType == 1) {
      var image = await ApplicationImagePicker.pickImage(context,
          source: ImageSource.camera,
          imageQuality: 100,
          maxHeight: 2450,
          maxWidth: 1750,
          appBarColor: appBarColor,
          titleAppBar: titleAppBar);
      if (image != null) {
        return image;
      }
    } else {
      var image = await ApplicationImagePicker.pickImage(context,
          source: ImageSource.gallery,
          imageQuality: 100,
          maxHeight: 2450,
          maxWidth: 1750,
          appBarColor: appBarColor,
          titleAppBar: titleAppBar);
      if (image != null) {
        return image;
      }
    }
    return null;
  }

  static Future<List<File>> _showPopupImages(
      BuildContext context, int imageType,
      {String appBarColor, String titleAppBar}) async {
    if (imageType == 1) {
      var image = await ApplicationImagePicker.pickImage(context,
          source: ImageSource.camera,
          imageQuality: 100,
          maxHeight: 2450,
          maxWidth: 1750,
          appBarColor: appBarColor,
          titleAppBar: titleAppBar);
      if (image != null) {
        return [image];
      }
    } else {
      var images = await ApplicationImagePicker.pickImages(context,
          imageQuality: 100,
          maxHeight: 2450,
          maxWidth: 1750,
          appBarColor: appBarColor,
          titleAppBar: titleAppBar);
      if (images != null) {
        return images;
      }
    }
    return null;
  }
}

enum RetroImageSource {
  camera,
  gallery,
}
