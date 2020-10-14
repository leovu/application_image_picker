# application_image_picker

A new flutter plugin project.

## Getting Started

**In Android: **

Need to add permision in your Manifest:
  >  <uses-permission android:name="android.permission.INTERNET" />
  >  <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    <uses-feature android:name="android.hardware.camera" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-feature android:name="android.hardware.camera.autofocus" />
    
also header have to : 
> <manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    
and add tools:replace="label" , requestLegacyExternalStorage only set when sdkCompile is >= 29 
  >  < application
         android:requestLegacyExternalStorage="true"
        tools:replace="label">


** In iOS: **

Add the following keys to your Info.plist file, located in <project root>/ios/Runner/Info.plist:
  NSPhotoLibraryUsageDescription
  NSCameraUsageDescription
  NSMicrophoneUsageDescription



Example:

- ImagePicker :
    File tempImage = await RetroImagePicker.openPictureSelection(
                    context,
                    appBarColor: "#FF0000",
                    titleAppBar: "Gallery");

- Permission:
    bool status = await RetroPermissionHandler.request(PermissionRequestType.CAMERA);
    bool status = await RetroPermissionHandler.check(PermissionRequestType.CAMERA);

- Check Platform
    bool isWeb = ApplicationPlatform.isWeb;