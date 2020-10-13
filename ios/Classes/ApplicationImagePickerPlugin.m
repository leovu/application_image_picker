#import "ApplicationImagePickerPlugin.h"
#if __has_include(<application_image_picker/application_image_picker-Swift.h>)
#import <application_image_picker/application_image_picker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "application_image_picker-Swift.h"
#endif

@implementation ApplicationImagePickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftApplicationImagePickerPlugin registerWithRegistrar:registrar];
}
@end
