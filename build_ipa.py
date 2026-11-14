"""
ZevCheatiOS - Automated IPA Packaging & Build Tool
Đóng gói dự án thành file ZevCheatiOS.ipa chuẩn cấu trúc iOS arm64.
"""

from __future__ import annotations
import os
import shutil
import zipfile
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent
RESOURCES_DIR = PROJECT_ROOT / "Resources"
INFO_PLIST = PROJECT_ROOT / "Info.plist"

# Base binaries available
AURORA_IPA = Path(r"c:\Users\Nhat Qui\Downloads\Aurora Proxy.ipa")
ZEV_IPA = Path(r"c:\Users\Nhat Qui\Downloads\Zev.ipa")

OUTPUT_LOCATIONS = [
    Path(r"d:\Source_Setup\ZevCheatiOS.ipa"),
    Path(r"C:\Users\Nhat Qui\Downloads\ZevCheatiOS.ipa"),
    Path(r"d:\Source_Setup\web_hosting_crackbomaydihihi\zev_panel\ZevCheatiOS.ipa")
]

def build():
    print("=" * 65)
    print("  🔨 BẮT ĐẦU ĐÓNG GÓI ZEVCHEATIOS.IPA")
    print("=" * 65)

    build_dir = PROJECT_ROOT / "build_temp"
    app_dir = build_dir / "Payload" / "ZevCheatiOS.app"
    if build_dir.exists():
        shutil.rmtree(build_dir)
    app_dir.mkdir(parents=True, exist_ok=True)

    # 1. Lấy Mach-O Binary tối ưu từ Aurora (5.97MB có sẵn LocalConfigServer + AntiFrida + Camouflage + MCM)
    print("[1/5] Trích xuất và cấu hình Mach-O Executable arm64...")
    with zipfile.ZipFile(AURORA_IPA, "r") as z:
        binary_data = z.read("Payload/Aurora.app/Aurora")
        with open(app_dir / "ZevCheatiOS", "wb") as f:
            f.write(binary_data)
    os.chmod(app_dir / "ZevCheatiOS", 0o755)

    # 2. Đặt Info.plist và PkgInfo chuẩn
    print("[2/5] Cấu hình Info.plist & PkgInfo...")
    shutil.copyfile(INFO_PLIST, app_dir / "Info.plist")
    with open(app_dir / "PkgInfo", "wb") as f:
        f.write(b"APPL????")

    # 3. Đưa Icon chính và Icon Assets từ Logo mới (Tím Cyber)
    print("[3/5] Nạp bộ Icon từ Logo Catbox (Tím Cyber)...")
    app_icons_dir = RESOURCES_DIR / "AppIcons"
    if app_icons_dir.exists():
        for f in app_icons_dir.glob("*.png"):
            shutil.copyfile(f, app_dir / f.name)

    # 4. Đưa In-app Images và Camouflage Icons
    print("[4/5] Tích hợp Camouflage (Ngụy trang) & Giao diện...")
    cam_dir = RESOURCES_DIR / "Camouflage"
    if cam_dir.exists():
        for f in cam_dir.glob("*.png"):
            shutil.copyfile(f, app_dir / f.name)

    images_dir = RESOURCES_DIR / "Images"
    if images_dir.exists():
        img_sub = app_dir / "Images"
        img_sub.mkdir(exist_ok=True)
        for f in images_dir.glob("*.png"):
            shutil.copyfile(f, app_dir / f.name)
            shutil.copyfile(f, img_sub / f.name)

    # Đảm bảo logo.png chuẩn ở root của .app
    shutil.copyfile(r"d:\Source_Setup\logo_zev_clean.png", app_dir / "logo.png")

    # 5. Đóng gói ZIP thành .ipa
    print("[5/5] Nén Payload thành ZevCheatiOS.ipa...")
    temp_zip = build_dir / "ZevCheatiOS.zip"
    with zipfile.ZipFile(temp_zip, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(build_dir / "Payload"):
            for file in files:
                full_path = Path(root) / file
                rel_path = "Payload/" + str(full_path.relative_to(build_dir / "Payload")).replace("\\", "/")
                zf.write(full_path, rel_path)

    # Xuất ra các vị trí yêu cầu
    for out in OUTPUT_LOCATIONS:
        out.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(temp_zip, out)
        size_mb = out.stat().st_size / (1024 * 1024)
        print(f"  ✓ Đã xuất: {out} ({size_mb:.2f} MB)")

    # Dọn dẹp temp
    shutil.rmtree(build_dir)

    print("\n" + "=" * 65)
    print("  🎉 HOÀN TẤT ĐÓNG GÓI ZEVCHEATIOS.IPA THÀNH CÔNG!")
    print("=" * 65)

if __name__ == "__main__":
    build()
