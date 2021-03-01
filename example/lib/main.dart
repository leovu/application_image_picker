import 'dart:io';
import 'package:application_image_picker/application_image_picker.dart';
import 'package:application_image_picker/ulitilites/dialog.dart';
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
                var tempImage = await RetroImagePicker.pickImage(
                    context,
                    appBarColor: "#FF0000",
                    titleAppBar: "Gallery");
                if (tempImage != null) {
                  setState(() {
                    print(tempImage.absolute.path);
                    image = tempImage;
                  });
                }
              },
            ),
          ),
        ),
        Container(
          height: 40.0,
          child: Center(
            child: MaterialButton(
              child: Text('Get Images'),
              onPressed: () async {
                var tempImage = await RetroImagePicker.pickImages(
                    context,
                    appBarColor: "#FF0000",
                    titleAppBar: "Gallery",
                    limitMultiPick: 3);
                if (tempImage != null) {
                  setState(() {
                    print(tempImage);
                    image = tempImage.last;
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
