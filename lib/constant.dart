class Common {
  static String keyHUD = "KEY_HUD";
  static String stringConfirm;
  static String stringNotification;
  static String stringAlertCamera;
  static String selectGallery;
  static String takePhoto;
  init(
      {String strConfirm,
      String strNotification,
      String strAlertCamera,
      String strSelectGallery,
      String strTakePhoto}) {
    stringConfirm = strConfirm ?? "Xác nhận";
    stringNotification = strNotification ?? "Thông báo";
    stringAlertCamera =
        strAlertCamera ?? "Điện thoại bạn không có hỗ trợ chức năng camera";
    selectGallery = strSelectGallery ?? "Chọn từ bộ sưu tập hình ảnh";
    takePhoto = strTakePhoto ?? "Chụp ảnh";
  }
}
