# 01 — Chuẩn bị & Tài khoản test

## 1. Môi trường

- Backend dùng chung: `https://api.locker-drone.tech`.
- Kiểm tra file `smart-laundry-locker-mobile/.env` → biến `API_BASE_URL` phải trỏ đúng backend.
- Nếu đổi `.env`, chạy lại:
  ```powershell
  dart run build_runner build --delete-conflicting-outputs
  ```
- Chạy app trên emulator/thiết bị:
  ```powershell
  Set-Location G:\BigProject\smart-laundry-locker-mobile
  C:\flutter\bin\flutter.bat pub get
  C:\flutter\bin\flutter.bat run
  ```
  (Với Android emulator gọi backend local dùng `http://10.0.2.2:8080`; với backend dùng chung dùng IP trên.)

## 2. Tài khoản test (mật khẩu `12345678` cho tất cả)

| Vai trò | Đăng nhập | Màn hình sau login |
|---|---|---|
| ADMIN | `baohuy2k12k4@gmail.com` | Admin Home (`/admin-home`) |
| MANAGER | `huynqbse180211@fpt.edu.vn` | Manager Home (`/manager`) |
| MAINTENANCE | `se180211nguyenquocbaohuy@gmail.com` | Maintenance Home (`/maintenance-home`) |
| STAFF | `staff@lockr.test` | Staff Home (`/staff-home`) |
| TECHNICIAN | `tech@lockr.test` | Technician Home (`/technician-home`) |
| CUSTOMER | `nqbhuy2004nt@gmail.com` | Home khách (`/home`) |

> Khách tự đăng ký trên mobile luôn ra role **CUSTOMER**. Role vận hành (ADMIN/MANAGER/MAINTENANCE) chỉ do Admin web tạo (tạo cả `auth_account` để login được).

## 3. Điều hướng theo role (`role_routes.dart`)

Thứ tự ưu tiên khi 1 tài khoản có nhiều role:

```
ADMIN  →  MANAGER  →  TECHNICIAN  →  MAINTENANCE  →  STAFF  →  (còn lại) CUSTOMER
```

- `ADMIN` → `/admin-home`
- `MANAGER` → `/manager`
- `TECHNICIAN` → `/technician-home`
- `MAINTENANCE` → `/maintenance-home`
- `STAFF` → `/staff-home`
- Còn lại → `/home` (customer)

## 4. Cách chuyển role khi test

Mỗi màn hình vận hành có nút **Đăng xuất** (icon logout ở header) → về màn Đăng nhập → nhập tài khoản của role kế tiếp.
Khách hàng đăng xuất tại **Profile → Đăng xuất**.

## 5. Trạng thái nghiệp vụ cần nhớ

**Trạng thái đơn (order-service):**

```
INITIALIZED ──▶ STORING ──▶ RETURNED ──▶ COMPLETED
      └────────────────────────────────▶ CANCELED
```

- Hủy được (CANCELABLE) khi đơn ở: `INITIALIZED / RESERVED / WAITING`.
- SEND: `INITIALIZED` (tạo) → `STORING` (bỏ hàng, PIN xoay vòng) → `COMPLETED` (người nhận lấy).
- RENTAL: `INITIALIZED` (tạo) → `STORING` (bắt đầu thuê) → `COMPLETED` (kết thúc/trả ô).
- LAUNDRY (legacy): confirm → collect → weight → process → ready → return (`RETURNED`) → complete.

**Trạng thái thanh toán:** `UNPAID / PAID / REFUNDED`.

**Trạng thái ô tủ (locker-service):**

```
AVAILABLE ─▶ RESERVED ─▶ OCCUPIED ─▶ AVAILABLE
AVAILABLE/RESERVED/OCCUPIED ─▶ FAULT ─▶ AVAILABLE (clear-fault)
AVAILABLE/FAULT ─▶ OUT_OF_SERVICE | CLEANING ─▶ AVAILABLE (return-to-service)
```

- Loại ô: `STANDARD` (ô thường), `XL` (ô vali), `DRONE` (ô drone thả hàng).
- Ô `OUT_OF_SERVICE`/`CLEANING` tự động bị loại khỏi phân phối cho khách.

## 6. Phương thức thanh toán hỗ trợ

`WALLET` (ví nội bộ) · `VNPAY` · `MOMO` · `CASH` (tiền mặt).
- WALLET/CASH: settle tức thì (đơn → PAID ngay).
- VNPAY/MOMO: mở WebView cổng thanh toán → callback → PAID. (MoMo cần backend cấu hình `MOMO_*`.)

## 7. Sơ đồ handoff giữa các role (đọc nhanh)

```
SEND:     Sender tạo+bỏ hàng ──(PIN xoay vòng + noti)──▶ Receiver lấy + hoàn tất
RENTAL:   Customer thuê ▶ dùng ▶ gia hạn / kết thúc          (không handoff)
BÁO LỖI:  Customer báo ▶ Maintenance claim→resolve ▶ Customer nhận noti + đánh giá
ỦY QUYỀN: Chủ đơn ủy quyền ──(PIN mới)──▶ Người lấy hộ mở ô
ĐĂNG KÝ NV: Customer nộp hồ sơ (PENDING) ──▶ Admin duyệt ──▶ Courier bật chế độ giao hàng
ĐỊNH KỲ:  Admin tạo lịch bảo trì ──▶ Maintenance "Đã kiểm tra"
PHÂN QUYỀN: Admin đổi role ──▶ user đăng nhập lại vào đúng Home
```

## 8. Feature flags (bật/tắt tính năng ở UI)

| Cờ | Trạng thái | Ảnh hưởng |
|---|---|---|
| `walletEnabled` | ✅ ON | Card ví, nạp tiền |
| `transactionsEnabled` | ✅ ON | Lịch sử giao dịch ví |
| `subscriptionEnabled` | ❌ OFF | Ẩn "Gói dịch vụ" |
| `vouchersEnabled` | ❌ OFF | Ẩn "Ưu đãi & Quà tặng" (kho voucher). *Trang "Ưu đãi" ở Home vẫn chạy* |
| `homeContentFeedEnabled` | ❌ OFF | Ẩn quảng cáo/blog ở Home |
| `faceRecognitionEnabled` | ❌ OFF | Ẩn "Đăng ký khuôn mặt" |
