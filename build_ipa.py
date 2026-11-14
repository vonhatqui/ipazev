"""
ZevCheatiOS - Automated Clean IPA Packaging Tool
Đóng gói dự án thành file ZevCheatiOS.ipa arm64 tinh gọn (~5-6 MB):
- Đã trỏ máy chủ API về: https://crackbomaydihihi.sbs/zev_panel
- Đã vá chống văng Mach-O arm64 (Anti-Crash)
- Dọn dẹp 100% file rác và ảnh rác, chỉ giữ 1 file executable ZevCheatiOS và Logo Gengar
"""

from __future__ import annotations
import os
import shutil
import zipfile
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent
RESOURCES_DIR = PROJECT_ROOT / "Resources"
INFO_PLIST = PROJECT_ROOT / "Info.plist"

PATCHED_BINARY = PROJECT_ROOT / "Source" / "ZevCheatiOS_MachO_Patched"

OUTPUT_LOCATIONS = [
    Path(r"d:\Source_Setup\ZevCheatiOS.ipa"),
    Path(r"C:\Users\Nhat Qui\Downloads\ZevCheatiOS.ipa"),
    Path(r"d:\Source_Setup\web_hosting_crackbomaydihihi\zev_panel\ZevCheatiOS.ipa")
]

def build():
    print("=" * 65)
    print("  🔨 BẮT ĐẦU ĐÓNG GÓI BẢN IPA SẠCH: ZEVCHEATIOS.IPA")
    print("=" * 65)

    build_dir = PROJECT_ROOT / "build_temp"
    app_dir = build_dir / "Payload" / "ZevCheatiOS.app"
    if build_dir.exists():
        shutil.rmtree(build_dir)
    app_dir.mkdir(parents=True, exist_ok=True)

    # 1. Mach-O arm64 Executable duy nhất (Đã trỏ https://crackbomaydihihi.sbs/zev_panel)
    print("[1/4] Nạp Executable Mach-O arm64 duy nhất (ZevCheatiOS)...")
    if not PATCHED_BINARY.exists():
        raise FileNotFoundError(f"Không tìm thấy file nhị phân: {PATCHED_BINARY}")

    with open(PATCHED_BINARY, "rb") as f:
        binary_data = f.read()

    target_bin = app_dir / "ZevCheatiOS"
    with open(target_bin, "wb") as f:
        f.write(binary_data)
    os.chmod(target_bin, 0o755)
    print(f"  ✓ Executable chính: ZevCheatiOS ({len(binary_data) / (1024*1024):.2f} MB)")

    # 2. Đặt Info.plist và PkgInfo chuẩn
    print("[2/4] Cấu hình Info.plist & PkgInfo...")
    shutil.copyfile(INFO_PLIST, app_dir / "Info.plist")
    with open(app_dir / "PkgInfo", "wb") as f:
        f.write(b"APPL????")

    # 3. Nạp bộ Icon Logo Gengar Full chuẩn iOS
    print("[3/4] Cài đặt Icon & Logo Gengar tím...")
    app_icons_dir = RESOURCES_DIR / "AppIcons"
    if app_icons_dir.exists():
        for f in app_icons_dir.glob("*.png"):
            shutil.copyfile(f, app_dir / f.name)

    # Logo Gengar in-app
    img_sub = app_dir / "Images"
    img_sub.mkdir(exist_ok=True)
    logo_src = app_icons_dir / "AppIcon-512.png"
    if not logo_src.exists():
        logo_src = Path(r"c:\Users\Nhat Qui\Downloads\aurora_ref.png")
    if logo_src.exists():
        shutil.copyfile(logo_src, app_dir / "logo.png")
        shutil.copyfile(logo_src, img_sub / "logo.png")
        print("  ✓ Đã thiết lập logo.png chuẩn")

    # 4. Đóng gói ZIP thành .ipa
    print("[4/4] Nén Payload thành ZevCheatiOS.ipa...")
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
    print("  🎉 HOÀN TẤT ĐÓNG GÓI BẢN IPA ZEVCHEATIOS MỚI TINH GỌN!")
    print("=" * 65)

if __name__ == "__main__":
    build()
