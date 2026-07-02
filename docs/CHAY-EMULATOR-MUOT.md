# Hướng dẫn chạy app mượt trên Android Emulator

> Tối ưu cho đúng cỗ máy đang dùng: **Intel i7-1065G7** (ULV 4 nhân, iGPU Iris yếu),
> **16 GB RAM** (thường chỉ còn ~1 GB trống), **NVMe SSD**, **WHPX bật OK**.
> AVD đang dùng: **Pixel_4** (`emulator-5554`), Android 14 / API 34, ảnh `google_apis_playstore`.

Làm **lần lượt từ trên xuống**. Phần lớn cảm giác mượt đến từ Bước 1–3; bước sau chỉ
cần khi vẫn còn giật.

---

## ⚡ TL;DR — combo mượt nhất, làm ngay
```powershell
# 1) Hạ độ phân giải render của emulator (đỡ ~55% pixel/frame)
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell wm size 720x1520
& $adb -s emulator-5554 shell wm density 300

# 2) Chạy app ở chế độ RELEASE (mượt nhất) hoặc PROFILE
C:\flutter\bin\flutter.bat run --release
```
Chỉ 2 lệnh này đã giải quyết ~80% độ giật. Các bước dưới để tối ưu sâu thêm.

---

## 1. Chạy đúng chế độ build (đòn bẩy LỚN NHẤT)

Debug mode là JIT + tắt mọi tối ưu → **bản chất đã giật**, không phản ánh hiệu năng thật.

| Lệnh | Khi nào dùng |
|---|---|
| `flutter run --release` | Xem app chạy thật mượt hay không (mất hot reload) |
| `flutter run --profile` | Vừa mượt vừa đo được jank trong DevTools |
| `flutter run` (debug) | Chỉ khi cần hot reload sửa UI nhanh |

```powershell
C:\flutter\bin\flutter.bat run --release
```

> Quy tắc: muốn "cảm nhận độ mượt" → luôn `--release`/`--profile`. Đừng đánh giá lag bằng debug.

## 2. Hạ độ phân giải / DPI của emulator (đòn bẩy lớn cho iGPU yếu)

iGPU Iris phải vẽ 1080×2280 mỗi frame là quá nặng. Hạ xuống 720×1520 giảm ~55% pixel,
**giữ nguyên tỉ lệ** nên layout không vỡ. Áp dụng tức thì, không cần restart emulator:

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell wm size 720x1520
& $adb -s emulator-5554 shell wm density 300
```
Hồi phục: `& $adb -s emulator-5554 shell wm size reset; & $adb -s emulator-5554 shell wm density reset`

## 3. Tắt Impeller nếu giật (thủ phạm phổ biến nhất trên emulator)

Flutter 3.44 mặc định bật **Impeller-Vulkan**; emulator Android render Vulkan hay kém.
Thử ép về Skia/GL rồi so sánh:

```powershell
C:\flutter\bin\flutter.bat run --release --no-enable-impeller
```
Nếu mượt hơn rõ → cố định bằng cách thêm vào
`android/app/src/main/AndroidManifest.xml`, **bên trong** thẻ `<application>`:
```xml
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="false" />
```

## 4. Giải phóng RAM (máy thường chỉ còn ~1 GB trống → swap → giật)

- **Đóng Chrome** (~1.3 GB) và **Android Studio** (~1.2 GB) khi chạy app.
- **Không bật `run-all.ps1` / Docker backend cùng lúc.** Nếu chỉ làm UI, trỏ
  `API_BASE_URL` trong `.env` sang domain đã deploy `https://locker-drone.tech`
  thay vì backend local → tiết kiệm vài GB.
- Sau khi đổi `.env` nhớ chạy lại build_runner (envied):
  ```powershell
  C:\flutter\bin\flutter.bat pub run build_runner build --delete-conflicting-outputs
  ```

## 5. Mở emulator từ CLI, KHÔNG nhúng trong Android Studio

Android Studio ăn ~1.2 GB và chế độ embedded thêm overhead vẽ. Đóng hẳn Studio,
dùng VS Code/CLI, mở emulator bằng lệnh tối ưu:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Pixel_4 `
  -gpu host -no-boot-anim -no-snapshot-save -no-audio -netfast
```
- Nếu đồ họa lỗi/giật: đổi `-gpu host` → `-gpu angle_indirect`
  (ANGLE dịch GLES→D3D11, ổn định hơn trên iGPU Intel).
- `-no-snapshot-save` tránh ghi snapshot lớn lúc tắt (đỡ I/O).

## 6. Dùng AVD nhẹ hơn (ảnh `google_apis`, không Play Store)

AVD hiện chạy ảnh **`google_apis_playstore`** → kèm Play Store + đồng bộ nền (nặng).
Tạo AVD mới dùng ảnh **`google_apis`**: vẫn đủ Play Services nên
**Firebase / Google Sign-In / FCM vẫn chạy**, nhưng nhẹ hơn.

Gợi ý cấu hình AVD mới:
- System image: `google_apis` x86_64, API 34 (hoặc 30 cho nhẹ hơn)
- RAM: 2048 MB · CPU cores: 2 · VM heap: 256 (giữ như hiện tại — đang hợp lý)
- Graphics: **Hardware - GLES 2.0**
- Camera back: **Emulated** (đổi từ `virtualscene` — đỡ tốn GPU khi không test scanner)
- Boot option: **Quick boot** (Cold boot = off)

## 7. Host / driver / nguồn điện

- **Cập nhật driver Intel Iris Graphics** (Intel Driver & Support Assistant) — driver cũ
  gây giật GPU emulator.
- **Luôn cắm sạc** khi dev. ULV tụt xung rất mạnh khi chạy pin.
- Power plan: đã nâng **Minimum processor state (AC) 5% → 50%** (xem mục Hồi phục).

## 8. Tối ưu trong code app (CHỈ làm nếu release vẫn giật)

Dùng `--profile` + DevTools → Performance/Timeline để tìm frame chậm:
- Animation nặng của `flutter_animate`; thêm `const` để tránh rebuild thừa.
- `ListView.builder` thay vì dựng cả list; chỉnh `cacheExtent` hợp lý.
- Ảnh: dùng `cached_network_image`, resize đúng kích thước hiển thị.
- `flutter_map`: giới hạn tile, tránh vẽ quá nhiều marker cùng lúc.
- Giảm shadow/blur/opacity lồng nhau (tốn raster).

---

## 🔧 Đã áp dụng sẵn trên máy này (và cách hồi phục)

| Thay đổi | Trạng thái | Hồi phục |
|---|---|---|
| Emulator render 720×1520 @ density 300 | đã set | `adb -s emulator-5554 shell wm size reset` + `... wm density reset` |
| Min processor state (AC) 5% → 50% | đã set | `powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5` rồi `powercfg /setactive SCHEME_CURRENT` |
| Gradle heap 3G + parallel + caching | đã set trong `android/gradle.properties` | sửa lại file nếu cần |

---

## ✅ Checklist mỗi lần chạy cho mượt
1. Cắm sạc, đóng Chrome + Android Studio thừa.
2. Không bật Docker/`run-all.ps1` nếu không cần backend (trỏ `.env` về domain deploy).
3. Mở emulator từ CLI (mục 5).
4. Hạ res emulator (mục 2) — chỉ cần làm lại nếu emulator khởi động lại.
5. `flutter run --release` (hoặc `--profile`). Nếu giật → thêm `--no-enable-impeller`.
