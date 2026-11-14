# ZevCheatiOS · Tactical Container Injector & Web Hub

Hệ thống toàn diện gồm **Web Admin Hub** quản lý nạp file/tạo key và **iOS IPA App (ZevCheatiOS)** nạp trực tiếp file cache vào `Documents` của Free Fire / Free Fire MAX (hỗ trợ từ iOS 17 đến iOS 18+).

---

## 1. Thành phần Hệ Thống

### A. Web Admin Hub (`/zev_panel/`)
* **Đường dẫn**: `http://127.0.0.1:8899/zev_panel/` (hoặc `https://crackbomaydihihi.sbs/zev_panel/`)
* **Tài khoản đăng nhập**:
  * **Username**: `admin`
  * **Password**: `zev123`
* **Tính năng**:
  * 🔑 **Quản lý Key**: Tạo key số lượng lớn (1 đến 50 key), tùy chọn thời hạn (1 ngày, 7 ngày, 30 ngày, vĩnh viễn), tiền tố Prefix (`ZEV`), Reset HWID khi khách đổi máy, gia hạn ngày, xóa key.
  * 📁 **Nạp File Cache (File Slots)**: Upload trực tiếp file `.json`, `.bytes`, `.bin` từ máy tính lên máy chủ. Tự động tính dung lượng, SHA-256 checksum và gán vào đường dẫn `Documents/` tương ứng.
  * ⚡ **Slot Mặc Định**:
    1. `local_config`: `Documents/localConfig.json` (Config Aim/ESP/NoRecoil)
    2. `aim_cache`: `Documents/aim-cache.bin` (Aim Lock Engine)
    3. `mod_skin`: `Documents/contentcache/Compulsory/ios/gameassetbundles/avatar/` (Mod Trang Phục / Súng)
    4. `ifix_patch`: `Documents/Assembly-CSharp-patch.bytes` (IFix CodePatch Engine)
    5. `antiban_safe`: `Documents/antiban_config.json` (Chặn Telemetry / Antiban)
    6. `reset_guest`: `Documents/reset_guest.flag` (Dọn dẹp Guest)
  * 🛡 **Cài đặt Hệ Thống**: Bật/Tắt chế độ bảo trì, chỉnh sửa DNS DoH URL & IP.

### B. App iOS (`ZevCheatiOS.ipa`)
* **Vị trí file IPA đã đóng gói sẵn**:
  * `d:\Source_Setup\ZevCheatiOS.ipa`
  * `C:\Users\Nhat Qui\Downloads\ZevCheatiOS.ipa`
  * `d:\Source_Setup\web_hosting_crackbomaydihihi\zev_panel\ZevCheatiOS.ipa` (Tải trực tiếp từ Web Admin)
* **Thông tin App**:
  * **Tên hiển thị**: `ZevCheatiOS`
  * **Bundle ID**: `com.apple.mobile.MobileHouseArrest`
  * **SDK Platform**: iOS 18.2 / iOS 17.0+
  * **Màu sắc**: Tím Cyber / Dark Neon (`#9d4edd`, `#8800f8`, `#080410`) chuẩn theo Logo Catbox.
  * **Ngụy trang (Camouflage)**: Hỗ trợ đổi icon ngoài màn hình chính thành Máy tính, Máy ảnh, ChatGPT, CapCut, v.v.

---

## 2. Hướng dẫn Khởi chạy Web Panel trên Windows

1. Nhấp đúp vào file: **`d:\Source_Setup\web_hosting_crackbomaydihihi\zev_panel\START_PANEL.bat`**
2. Mở trình duyệt truy cập: **`http://127.0.0.1:8899/zev_panel/`**
3. Đăng nhập với tài khoản: `admin` / `zev123`

---

## 3. Hướng dẫn Ký và Cài đặt IPA lên iPhone

Vì `ZevCheatiOS.ipa` là file cài đặt sạch, bạn có thể ký và cài đặt bằng bất kỳ công cụ nào:
* **Cách 1 (ESign / Scarlet / Gbox)**: Import file `ZevCheatiOS.ipa` vào app, chọn Chứng chỉ P12 doanh nghiệp hoặc chứng chỉ nhà phát triển rồi bấm Ký & Cài đặt.
* **Cách 2 (TrollStore)**: Nếu máy đã cài TrollStore, chỉ cần mở file `ZevCheatiOS.ipa` và chọn *Install with TrollStore*.
* **Cách 3 (Sideloadly / AltStore)**: Ký bằng Apple ID cá nhân qua máy tính.

---

## 4. Kiểm Thử Hệ Thống (Automated Test)

Đã chạy toàn bộ bộ kịch bản kiểm thử tự động tại `test_zev_panel.py`:
* **Health Check**: PASS ✓
* **Admin Login Authentication**: PASS ✓
* **Admin Create Keys**: PASS ✓
* **Key HWID Binding & Anti-Share**: PASS ✓
* **Fetch Features & Download File Stream**: PASS ✓
* **Admin Reset HWID**: PASS ✓
* **MobileConfig DoH Profile Generator**: PASS ✓
* **Client Injection Telemetry Report**: PASS ✓

Tỷ lệ kiểm thử: **8/8 bài test PASS 100%!**

