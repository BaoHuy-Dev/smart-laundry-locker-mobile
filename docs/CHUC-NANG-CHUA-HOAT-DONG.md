# Mobile — Danh sách chức năng CHƯA hoạt động / cần bổ sung / cần sửa

> Repo: `smart-laundry-locker-mobile` · Cập nhật: 2026-07-03
> Nguồn: rà soát trực tiếp source (`lib/`), `pubspec.yaml`, `feature_flags.dart`.
> Ký hiệu mức độ: 🔴 chưa có / hỏng · 🟠 làm dở / phụ thuộc cấu hình · 🟢 chạy được nhưng cần hoàn thiện.

Mục lục:
1. [Xác thực & bảo mật](#1-xác-thực--bảo-mật)
2. [Thanh toán](#2-thanh-toán)
3. [Mở tủ / OTP / QR](#3-mở-tủ--otp--qr)
4. [Giao hàng (Courier & Drone)](#4-giao-hàng-courier--drone)
5. [Tính năng bị ẩn bằng feature flag](#5-tính-năng-bị-ẩn-bằng-feature-flag)
6. [Các mục "đang phát triển" trong Hồ sơ](#6-các-mục-đang-phát-triển-trong-hồ-sơ)
7. [Thông báo đẩy (FCM)](#7-thông-báo-đẩy-fcm)
8. [Nợ kỹ thuật khác](#8-nợ-kỹ-thuật-khác)
9. [Bảng tổng hợp ưu tiên](#9-bảng-tổng-hợp-ưu-tiên)

---

## 1. Xác thực & bảo mật

### 1.1 🔴 Đăng nhập bằng vân tay / sinh trắc học — CHƯA TÍCH HỢP
- **Hiện trạng:** không có trong app. `pubspec.yaml` **không** khai báo `local_auth` (package tiêu chuẩn cho vân tay/Face Unlock của thiết bị).
- **Nguyên nhân:** chưa làm.
- **Cần bổ sung:** thêm `local_auth`, lưu token bằng `flutter_secure_storage` (đã có), thêm nút "Đăng nhập bằng vân tay/khuôn mặt thiết bị" ở màn đăng nhập, quản lý bật/tắt trong mục **Bảo mật**.

### 1.2 🔴 "Đăng nhập khuôn mặt" (Face Recognition) — TẮT / KHÔNG CHẠY
- **Hiện trạng:** nút "Đăng nhập khuôn mặt" (`auth_bottom_sheet.dart` → `AppRouter.faceVerify`) và mục "Đăng ký khuôn mặt" trong Hồ sơ. Cả hai bị ẩn/không dùng được.
- **Nguyên nhân:** `FeatureFlags.faceRecognitionEnabled = false`; backend **chưa có AI service** — `/api/auth/ai/register`, `/api/auth/ai/verify`, `/api/auth/ai/registered/{userId}` trả **500**.
- **Cần làm:** dựng AI service phía backend rồi bật cờ; hoặc gỡ hẳn nút/màn nếu không theo đuổi.
- **Lưu ý:** đây là nhận diện khuôn mặt qua camera + AI, **khác** với sinh trắc học thiết bị ở mục 1.1.

### 1.3 🟠 Đăng nhập Google / Facebook / SĐT (OTP) — cần cấu hình console
- **Hiện trạng:** code đã wire (`google_sign_in`, `flutter_facebook_auth`, Firebase Phone) → gọi `POST /api/auth/firebase`.
- **Nguyên nhân chưa chạy thật trên máy thật:** cần khai báo **SHA‑1 (Firebase)**, **Facebook key hash + App ID/Secret**, bật provider tương ứng trong Firebase console, thêm OAuth redirect URI.
- **Cần làm:** hoàn tất cấu hình console cho từng môi trường (debug/release).

### 1.4 🔴 Quên mật khẩu — CHƯA CÓ LUỒNG THẬT
- **Hiện trạng:** `login_screen.dart` bấm "Quên mật khẩu?" chỉ hiện toast "Vui lòng liên hệ hỗ trợ để đặt lại mật khẩu."
- **Cần bổ sung:** luồng reset qua OTP email/SĐT (màn nhập email → nhận mã → đặt mật khẩu mới) + endpoint backend tương ứng.

---

## 2. Thanh toán

### 2.1 🟠 Thanh toán thật VNPay / MoMo — cần credentials production
- **Hiện trạng:** app mở **WebView** cổng VNPay/MoMo (`webview_flutter`) qua `POST /api/payments/checkout`. Ví (WALLET) và Tiền mặt (CASH) settle tức thì; VNPay/MoMo trả URL để redirect.
- **Nguyên nhân chưa "thật":** đang dùng cấu hình **sandbox/demo**. **MoMo** chỉ hoạt động khi backend đặt biến `MOMO_*`; chưa cấu hình sẽ trả `MOMO_NOT_CONFIGURED`. VNPay cần merchant thật để đối soát.
- **Cần làm:** cấu hình **merchant/credential production** VNPay + MoMo ở backend; kiểm thử end‑to‑end (thanh toán → callback → cộng ví/đơn PAID → đối soát).

### 2.2 🟢 Ví & Nạp tiền — chạy được, cần kiểm thử sandbox→thật
- **Hiện trạng:** `walletEnabled = true`; số dư đọc `GET /api/wallet`, nạp qua VNPay topup, lịch sử giao dịch bật.
- **Cần hoàn thiện:** verify luồng nạp thật (không chỉ sandbox), xử lý thất bại/hoàn tiền rõ ràng trên UI.

> ✅ *Đã bổ sung ở phiên trước:* chặn bỏ hàng/bắt đầu thuê khi đơn **chưa thanh toán** (backend `ORDER_UNPAID`).

---

## 3. Mở tủ / OTP / QR

### 3.1 🔴 Màn "Lấy hàng (OTP)" của tủ — MOCK, KHÔNG GỌI API
- **Hiện trạng:** `locker_otp_page.dart` → `_onVerifyPressed()` chỉ `SmartDialog.showToast('Đang xác thực OTP...')`, kèm `// TODO: Gọi API xác thực OTP thật.`
- **Ảnh hưởng:** quick action **"Lấy hàng (OTP)"** ở màn courier không thực sự mở tủ.
- **Cần làm:** nối vào API mở tủ thật (`POST /api/iot/unlock` hoặc `verify-access`) như nút "Mở tủ" trong chi tiết đơn đã làm.

### 3.2 🟠 Quét QR — chỉ phục vụ ĐĂNG NHẬP KIOSK, không mở tủ/giao hàng
- **Hiện trạng:** `qr_scanner_page.dart` (dùng `mobile_scanner` — camera chạy thật) chỉ gọi `QrLoginProvider.confirmQrLogin(code)` để đăng nhập trên kiosk/web. Tiêu đề màn: "Quét mã QR Kiosk".
- **Vấn đề:** quick action **"Giao hàng"** của courier trỏ tới đúng màn quét QR‑login này → **sai chức năng** (không phải quét để giao/lấy hàng).
- **Phụ thuộc:** QR‑login cần backend kiosk sinh mã QR + xác nhận.
- **Cần làm:** tách màn "Quét QR để mở ô/giao‑nhận hàng" (đọc QR token của đơn → `verify-access`/`unlock`), và sửa lại điều hướng cho quick action courier.

### 3.3 🟢 Nút "Mở tủ" trong chi tiết đơn — ĐÃ CHẠY (mobile→backend→IoT)
- **Hiện trạng:** đã bổ sung ở phiên trước; đã kiểm chứng cabinet phản hồi thật qua MQTT.
- **Cần hoàn thiện:** app hiện chỉ báo "đã gửi lệnh"; nên **đọc kết quả trả về** (SUCCESS/OPENING) để hiển thị "cửa đã mở" chính xác thay vì thông báo chung.

---

## 4. Giao hàng (Courier & Drone)

### 4.1 🔴 Giao hàng qua Courier — KHÔNG CÓ BACKEND
- **Hiện trạng:** UI đầy đủ (courier dashboard, dispatch, active‑delivery, "Tìm tài xế", màn thanh toán ship) nhưng gọi endpoint legacy/không tồn tại.
- **Nguyên nhân:** backend chưa có luồng dispatch/PARCEL_RECEIVE (Gap G6).
- **Cần làm:** hoặc dựng backend dispatch/courier (đơn ship, gán tài xế, access code riêng cho courier), hoặc **ẩn sau feature flag** để tránh hiểu nhầm là chức năng thật.

### 4.2 🔴 Đặt giao bằng Drone — DEMO CỤC BỘ (không có backend)
- **Hiện trạng:** `drone_booking_sheet.dart` ghi "Miễn phí (Demo)"; đơn drone lưu trong bộ nhớ app (`DroneDeliveryStore` in‑memory); tracking mô phỏng.
- **Cần làm:** khi có drone‑service thật → tạo đơn thật + bắn event `delivery.status.changed` để tracking/notify thật.

### 4.3 🟠 Đăng ký làm Nhân viên/Courier — thiếu màn duyệt
- **Hiện trạng:** khách nộp hồ sơ (ảnh xe + biển số) → PENDING; nhưng **Admin mobile không có màn duyệt** → phụ thuộc admin web/DB.
- Ngoài ra `courier_registration_status_page.dart` báo "Tính năng Courier Dashboard đang được phát triển".

---

## 5. Tính năng bị ẩn bằng feature flag

Nguồn: `lib/core/config/feature_flags.dart`. Các cờ **OFF** vì backend chưa có:

| Cờ | Trạng thái | Ảnh hưởng / màn liên quan | Backend còn thiếu |
|---|---|---|---|
| `subscriptionEnabled` | 🔴 OFF | "Gói dịch vụ" (màn `plans_page` tồn tại, còn ghi "chưa hỗ trợ hạ cấp gói") | `/plans/*`, `/subscriptions/*` (404) |
| `vouchersEnabled` | 🔴 OFF | "Ưu đãi & Quà tặng" (kho voucher cá nhân) | `/promotions/vouchers/my` (404) |
| `homeContentFeedEnabled` | 🔴 OFF | Quảng cáo/blog ở trang chủ | `/advertisements`, `/blogs` (404) |
| `faceRecognitionEnabled` | 🔴 OFF | Đăng ký/đăng nhập khuôn mặt (xem 1.2) | AI service (`/api/auth/ai/*` 500) |
| `walletEnabled` | 🟢 ON | Ví/nạp tiền | có |
| `transactionsEnabled` | 🟢 ON | Lịch sử giao dịch ví | có |

> *Lưu ý:* trang "Ưu đãi" (khuyến mãi công khai, `GET /api/promotions/active`) **vẫn chạy** và không bị ẩn.

---

## 6. Các mục "đang phát triển" trong Hồ sơ

Trong `profile_page.dart`, các mục sau chỉ hiện toast **"Tính năng đang được phát triển"**:
- 🔴 **Ngôn ngữ** (đa ngôn ngữ chưa có).
- 🔴 **Vị trí** (cài đặt vị trí).
- 🔴 **Trợ giúp**.
- 🔴 **Liên hệ**.

→ Cần bổ sung nội dung/màn thật hoặc gỡ khỏi menu.

---

## 7. Thông báo đẩy (FCM)

- 🟠 **Push notification** (đơn/giao hàng): code đã xong (đăng ký token, foreground/background, deep‑link mở chi tiết đơn, STOMP realtime).
- **Nguyên nhân chưa chạy thật:** cần **Firebase credential production** + thiết bị thật; luồng drone bắn `delivery.status.changed` vẫn TODO ở backend.
- **Cần làm:** cấu hình FCM production, kiểm thử trên thiết bị thật.

---

## 8. Nợ kỹ thuật khác

- 🟠 `api_constants.dart`: `// TODO: Update with actual provinces API endpoint` — danh sách tỉnh/thành chưa nối API thật.
- 🟠 `locker_providers.dart`: `localDataSource: null // TODO: implement local caching` — chưa có cache offline cho danh sách tủ.
- 🟠 **Mission Planner / Flight Data (drone telemetry)**: công cụ MAVLink cục bộ, chỉ chạy khi có drone/SITL thật; chưa nối hệ thống.
- 🟢 Nút "Mở tủ" nên đọc kết quả IoT để hiển thị chính xác (xem 3.3).

---

## 9. Bảng tổng hợp ưu tiên

| Ưu tiên | Hạng mục | Loại | Ghi chú |
|---|---|---|---|
| 🔴 Cao | OTP mở tủ còn mock (3.1) | Sửa | Đang đánh lừa người dùng |
| 🔴 Cao | Quét QR courier sai chức năng (3.2) | Sửa | Trỏ nhầm sang QR‑login |
| 🔴 Cao | Thanh toán thật VNPay/MoMo (2.1) | Cấu hình BE | Cần merchant production |
| 🔴 Cao | Quên mật khẩu (1.4) | Bổ sung | Chức năng cơ bản còn thiếu |
| 🟠 TB | Đăng nhập vân tay/sinh trắc (1.1) | Bổ sung | Thêm `local_auth` |
| 🟠 TB | Ẩn/hoặc dựng backend Courier delivery (4.1) | Quyết định | Tránh chức năng "chết" |
| 🟠 TB | Cấu hình Google/FB/Phone + FCM production (1.3, 7) | Cấu hình | Console Firebase/Facebook |
| 🟠 TB | Dọn các mục "đang phát triển" trong Hồ sơ (6) | Sửa/gỡ | Ngôn ngữ/Vị trí/Trợ giúp/Liên hệ |
| 🟢 Thấp | Bật lại subscription/voucher/face/home‑feed khi có backend (5) | Phụ thuộc BE | Theo roadmap |
| 🟢 Thấp | Drone đặt hàng thật (4.2), telemetry (8) | Phụ thuộc BE/thiết bị | |

---

### Tóm tắt nhanh cho bạn
- **Chưa có hẳn:** vân tay/sinh trắc học; quên mật khẩu; backend courier delivery; drone thật; subscription/voucher/quảng cáo/khuôn mặt.
- **Có nhưng chưa chạy đúng:** OTP mở tủ (mock), quét QR courier (sai điều hướng), thanh toán VNPay/MoMo (sandbox), FCM (cần production).
- **Đã chạy tốt:** đăng ký/đăng nhập email‑mật khẩu, xem tủ/cửa hàng, tạo đơn Gửi hàng/Thuê tủ, ví + nạp tiền, thanh toán ví/tiền mặt, nút **Mở tủ** (IoT), thông báo trong app, các màn vận hành Manager/Maintenance/Technician/Admin.
