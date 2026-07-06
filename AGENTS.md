# AGENTS.md — mobile (Flutter)

Tài liệu bắt buộc cho AI coding agents làm việc trong repo này.

---

## BỐI CẢNH BẮT BUỘC

App mobile Flutter kết nối tới backend microservices.  
Trước khi sửa bất kỳ thứ gì, đọc:

1. `docs/merge-status.md` — trạng thái merge các flow hiện tại
2. `../laundry-locker-microservices/docs/BUSINESS_FLOWS_CURRENT.md` — nghiệp vụ + endpoint (nếu có access)

---

## QUY TẮC LÀM VIỆC

### Không được vi phạm

```
❌ KHÔNG commit .env (chứa API_BASE_URL và secrets)
❌ KHÔNG sửa *.g.dart tay — chỉ chạy build_runner
❌ KHÔNG dùng context.push() trong ShellRoute — dùng context.go()
❌ KHÔNG hardcode path route — luôn dùng AppRouter.<name>
❌ KHÔNG gọi endpoint trong danh sách DEAD ENDPOINTS bên dưới
❌ KHÔNG consolidate Provider/Riverpod/BLoC — 3 cái đang dùng đan xen
❌ KHÔNG import từ presentation/ của feature khác — chuyển vào shared/ trước
❌ KHÔNG dùng SnackBar/AlertDialog trực tiếp — dùng SmartDialog
❌ KHÔNG dùng màu orange cũ (0xFFfb8520) — chỉ dùng palette navy
❌ KHÔNG commit .agent/, .codegraph/, build/, .dart_tool/
```

### Branch

```
feat/<area>-<short-task>
fix/<area>-<short-task>
```

### Networking — QUAN TRỌNG

- `ApiClient` base URL = `API_BASE_URL` — **không tự thêm `/api`**
- Path phải viết đầy đủ: `/api/auth/login`, không phải `/auth/login`
- `AuthInterceptor` tự refresh token khi 401

---

## ROLE ROUTING (`lib/core/routing/role_routes.dart`)

| Role trong JWT | Landing page |
|---|---|
| `ADMIN` | `/admin-web-notice` → `AdminWebNoticePage` (admin chỉ dùng bản web) |
| `TECHNICIAN` | `/technician-home` → `TechnicianHomePage` (bảo trì vật lý tủ + thiết bị IoT) |
| `MAINTENANCE` | `/maintenance-home` → `MaintenanceHomePage` (chỉ đội bay drone) |
| Tất cả còn lại (gồm `MANAGER`/`STAFF` đã bỏ) | `/home` → customer shell |

**COURIER** = mode toggle trong `CourierModeProvider`, không phải shell riêng.

---

## DEAD ENDPOINTS — KHÔNG GỌI

```
GET  /wallet/balance                 → walletEnabled = false
GET  /payments/transactions*         → transactionsEnabled = false
GET  /promotions/vouchers/my         → dùng /api/promotions/active thay thế
GET  /advertisements, /blogs         → homeContentFeedEnabled = false
POST /auth/ai/*, /auth/face-verify   → faceRecognitionEnabled = false
     /courier/*, /orders/courier/*   → không có backend
     /staff-applications             → staff-service đã gỡ
     /plans/customer, /subscriptions → subscriptionEnabled = false
     /delegations/*                  → dùng POST /api/orders/{id}/delegate
```

Flip flag trong `lib/core/config/feature_flags.dart` khi backend sẵn sàng.

---

## UI CONVENTIONS

Brand palette — **navy blue** only:
```dart
navyPrimary   = Color(0xFF0A2342)
navySecondary = Color(0xFF12355B)
navyAccent    = Color(0xFF1E5A8A)
navySurface   = Color(0xFFF6F8FB)
```

- Toast/overlay: `SmartDialog`
- Icons: `lucide_icons_flutter` → Material → SVG có sẵn
- Ops widgets (manager/maintenance/staff/technician): `ops_widgets.dart`

---

## COMMANDS

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # sau khi đổi .env hoặc @JsonSerializable
dart format lib test
flutter analyze                  # new errors = blocker; warning debt cũ bỏ qua
flutter build apk --debug
```

Build với Android SDK:
```bash
ANDROID_HOME=/home/kane/Android/Sdk /home/kane/flutter/bin/flutter build apk --release
ANDROID_HOME=/home/kane/Android/Sdk /home/kane/flutter/bin/flutter build appbundle --release
```

---

## SAU KHI LÀM XONG

1. `flutter analyze` — 0 new errors
2. `flutter build apk --debug` — build pass
3. Nếu đổi route/flow/API: cập nhật `../laundry-locker-microservices/docs/BUSINESS_FLOWS_CURRENT.md` + `PROJECT_PROGRESS_TRACKER.md`
4. Ghi vào `docs/merge-status.md` nếu merge flow mới

---

## FORMAT BÁO CÁO CUỐI

```
✅ Đã làm: ...
📁 File chính đã sửa: ...
🧪 flutter analyze: PASS/FAIL | flutter build: PASS/FAIL
📝 Đã cập nhật docs sống: có/chưa
⚠️ Còn lại / rủi ro: ...
🌿 Branch/commit/push: ...
```

---

Xem chi tiết đầy đủ về platform: `../AGENTS.md` (root workspace)
