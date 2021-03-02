import Flutter
import UIKit
import BSImagePicker
import Photos

public class SwiftApplicationImagePickerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter.io/gallery", binaryMessenger: registrar.messenger())
    let instance = SwiftApplicationImagePickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "gallery" {
        guard let args:[String: Any] = (call.arguments as? [String: Any]) else {
            result(FlutterError(code: "400", message:  "Bad arguments", details: "iOS could not recognize flutter arguments in method: (start)") )
            return
        }
        let imgPicker = ImagePickerRetro()
        imgPicker.result = result
        imgPicker.limit = Int(args["limitMultiPick"] as! String) ?? 3
        imgPicker.pickImages()
    }
    else {
        result(FlutterMethodNotImplemented);
        return
    }
  }
}

class ImagePickerRetro : NSObject {
    var result:FlutterResult!
    var limit:Int = 3
    override init() {
        super.init()
    }
    func pickImages() {
        let imagePicker = ImagePickerController()
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.selection.max = limit
        if let topController = UIApplication.topViewController() {
            topController.presentImagePicker(imagePicker, select: { (asset) in },
            deselect: { (asset) in },
            cancel: { (assets) in
                self.result(nil)
            }, finish: { (assets) in
                self.assetsReading(assets: assets)
            })
        }
    }
    private func assetsReading(assets:[PHAsset]) {
        var _arr:[String] = []
            if (assets.count > 0) {
                for i in 0...assets.count-1 {
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
                    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                    requestOptions.isSynchronous = true
                    PHImageManager.default().requestImage(for: assets[i], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { (image, info) in
                        let path = "photo/temp/\(Bundle.main.displayName ?? "wao")/\(Date().timeIntervalSince1970).jpg"
                            guard let url = image?.save(at: .documentDirectory,
                                            pathAndImageName: path) else {return}
                            _arr.append(url.absoluteString)
                        }
                        if i == assets.count-1 {
                            self.result(_arr)
                        }
                    }
                }
            else {
                self.result(nil)
            }
    }
}
extension Bundle {
    var displayName: String? {
            return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
extension UIApplication {
    class func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }
}
extension UIImage {
    func save(at directory: FileManager.SearchPathDirectory,
              pathAndImageName: String,
              createSubdirectoriesIfNeed: Bool = true,
              compressionQuality: CGFloat = 1.0)  -> URL? {
        do {
        let documentsDirectory = try FileManager.default.url(for: directory, in: .userDomainMask,
                                                             appropriateFor: nil,
                                                             create: false)
        return save(at: documentsDirectory.appendingPathComponent(pathAndImageName),
                    createSubdirectoriesIfNeed: createSubdirectoriesIfNeed,
                    compressionQuality: compressionQuality)
        } catch {
            print("-- Error: \(error)")
            return nil
        }
    }
    func save(at url: URL,
              createSubdirectoriesIfNeed: Bool = true,
              compressionQuality: CGFloat = 1.0)  -> URL? {
        do {
            if createSubdirectoriesIfNeed {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            guard let data = jpegData(compressionQuality: compressionQuality) else { return nil }
            try data.write(to: url)
            return url
        } catch {
            print("-- Error: \(error)")
            return nil
        }
    }
}
extension UIImage {
    convenience init?(fileURLWithPath url: URL, scale: CGFloat = 1.0) {
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data, scale: scale)
        } catch {
            print("-- Error: \(error)")
            return nil
        }
    }
}
