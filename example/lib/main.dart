import 'dart:io';
import 'package:application_image_picker/application_image_picker.dart';
import 'package:application_image_picker/application_location_request.dart';
import 'package:application_image_picker/dialog.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: MaterialButton(
          child: Text('Open function'),
          onPressed: () => CustomNavigator().push(context, MainPage()),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<MainPage> {
  File image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(children: [
        Expanded(
            child: image == null
                ? Container()
                : Image.file(
                    image,
                    fit: BoxFit.scaleDown,
                  )),
        Container(
          height: 40.0,
          child: Center(
            child: MaterialButton(
              child: Text('Get Image'),
              onPressed: () async {
                var tempImage = await RetroImagePicker.openPictureSelection(
                    context,
                    appBarColor: "#FF0000",
                    titleAppBar: "Gallery");
                if (tempImage != null) {
                  setState(() {
                    image = tempImage;
                  });
                }
              },
            ),
          ),
        )
      ]),
    );
  }
}
