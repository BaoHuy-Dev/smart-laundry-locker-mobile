# USER flow merge status

<!-- CURRENT_STATUS_START -->
> **Cập nhật 2026-06-15:** UX/UI revamp luồng tủ khóa cho Customer đã hoàn tất trên branch `feat/mobile-user-ui-revamp` (develop). Các thay đổi chính: (1) Tab Tủ + Xem tất cả home đều dẫn đến lưới ô tủ thực tế thay vì danh sách địa điểm; (2) Ô DRONE hiển thị icon máy bay + màu indigo + không cho đặt dịch vụ thường; (3) Booking (Thuê tủ/Gửi hàng) bỏ picker khi đến từ lưới ô; (4) CellType.java constants class được thêm vào backend với Javadoc đầy đủ. `flutter analyze` 0 error.
<!-- CURRENT_STATUS_END -->

## Files changed

### 2026-07-03 — Live map theo dõi drone real-time cho NGƯỜI NHẬN (Phase 2, STOMP) (branch `feat/mobile-delivery-push-notifications` + BE `feat/notification-drone-position`)

Bổ sung vào feature `lib/features/drone_delivery/` (không tạo feature mới). Mở **on-demand**: nút "Theo dõi trên bản đồ" ở trang timeline (Phase 1) → live map; chỉ subscribe STOMP khi mở map, unsubscribe khi rời. **Gọi STOMP THẬT (không mock)** + thêm publisher backend.

Mobile:

- `domain/entities/drone_position_snapshot.dart` — **mới**: `{ orderId, status, lat, lng, headingDeg, etaMinutes, speedMps?, batteryPercent?, timestamp }` + getter `stage`
- `domain/repositories/drone_position_repository.dart` — **mới**: `Stream<DronePositionSnapshot> watchPosition(orderId)` + `stopWatching(orderId)`
- `infrastructure/models/drone_position_response.dart` — **mới**: parse frame STOMP (mềm lỗi), `ts` epoch/ISO
- `infrastructure/services/drone_position_socket_service.dart` — **mới**: STOMP `/ws` mirror `RealtimeNotificationService` (Bearer token, reconnect 5s, heartbeat 10s), subscribe theo orderId `/topic/deliveries/{orderId}/position`, đóng socket khi hết listener
- `infrastructure/repositories/drone_position_repository_impl.dart` — **mới**
- `presentation/providers/drone_live_map_providers.dart` — **mới**: `StreamProvider.autoDispose.family` + `ref.onDispose → stopWatching` (on-demand)
- `presentation/pages/drone_live_map_page.dart` — **mới**: `flutter_map` (OSM tile giống mission_planner), marker xoay heading, **interpolate mượt** (AnimationController lerp previous→target ~1.5s, lerp góc ngắn nhất), watchdog **mất tín hiệu >10s → đóng băng + banner "Mất tín hiệu · vị trí lúc HH:MM"**, overlay status + ETA, nút follow, vệt breadcrumb đã đi
- `presentation/widgets/drone_marker.dart` — **mới**
- `presentation/pages/drone_delivery_tracking_page.dart` — nút "Theo dõi trên bản đồ" (chỉ hiện khi status ∈ {dispatched, approaching} và `droneLiveMapEnabled`)
- `core/config/feature_flags.dart` — `droneLiveMapEnabled = false`; `core/routing/app_router.dart` — route `droneLiveMap = '/drone-delivery/live-map'`

Backend (`notification-service`, branch `feat/notification-drone-position`):

- `dto/DronePositionRequest.java` + `service/DronePositionService.java` + endpoint `POST /internal/deliveries/{orderId}/position` (NotificationController) → `WebSocketNotificationService.sendToDestination('/topic/deliveries/{orderId}/position', payload)`. Internal-only (gateway chặn `/internal/**`), KHÔNG lưu DB, KHÔNG FCM. iot-service sẽ downsample telemetry rồi gọi endpoint này.

### 2026-07-03 — Theo dõi giao drone cho NGƯỜI NHẬN qua push notification (Phase 1) (branch `feat/mobile-delivery-push-notifications`)

Feature mới `lib/features/drone_delivery/` đủ 4 layer, mirror `logistics_send`. Phase 1 **chỉ push notification + timeline**, CHƯA có live map/websocket. Không đụng `drone_telemetry`/`drone_mission` (phía pilot/MAVLink).

Domain + application:

- `lib/features/drone_delivery/domain/entities/drone_delivery_stage.dart` — **tạo mới**: enum 6 mốc (`dispatched → approaching → arrived → delivered → delayed → failed`) + `unknown`; `fromRaw()`, `timeline`, `order`, `icon` (lucide), `color` (giữ semantic: success=green, delayed=amber, failed=red), `title`/`body(eta)`
- `lib/features/drone_delivery/domain/entities/drone_delivery_status.dart` — **tạo mới**: entity `{ status, deliveryId, orderId, orderCode, droneCode, etaMinutes, updatedAt }` + getter `stage` (mirror `DispatchStatusEntity`)
- `lib/features/drone_delivery/domain/repositories/drone_delivery_repository.dart` — **tạo mới**: contract `getDeliveryStatus(orderId)` → `Either<Failure, DroneDeliveryStatus>`
- `lib/features/drone_delivery/application/use_cases/get_drone_delivery_status_use_case.dart` — **tạo mới**: mirror `GetDispatchStatusUseCase`

Infrastructure:

- `lib/features/drone_delivery/infrastructure/models/drone_delivery_response.dart` (+ `.g.dart` sinh bằng build_runner) — **tạo mới**: `@JsonSerializable`, `fromJson` chịu nesting `data`, `toEntity()`
- `lib/features/drone_delivery/infrastructure/data_sources/drone_delivery_remote_datasource.dart` — **tạo mới**: `GET /api/orders/{orderId}/drone-delivery`; guard bằng flag `droneDeliveryEnabled` → trả **mock** khi tắt (KHÔNG gọi endpoint chết)
- `lib/features/drone_delivery/infrastructure/repositories/drone_delivery_repository_impl.dart` — **tạo mới**: try/catch → `Either<Failure, …>` (mirror `LogisticsSendRepositoryImpl`)

FCM router (mở rộng, KHÔNG viết lại):

- `lib/core/services/firebase_messaging_service.dart` — thêm set `droneDeliveryTypes` (6 type `drone_*`); `_handleForegroundMessage` không toast trùng; `_handleTapData` → `context.go(AppRouter.droneDeliveryTracking, extra: orderId)`. Tái dùng `_showLocalNotification` + channel `aisl_high_importance_channel`.

Presentation:

- `lib/features/drone_delivery/presentation/providers/drone_delivery_providers.dart` — **tạo mới**: Riverpod 3; `getDroneDeliveryStatusUseCaseProvider` + `droneDeliveryFcmTickProvider` (StreamProvider lọc FCM theo orderId) + `droneDeliveryStatusProvider` (FutureProvider.family, refetch khi có mốc mới — mirror `NotificationProvider`)
- `lib/features/drone_delivery/presentation/pages/drone_delivery_tracking_page.dart` — **tạo mới**: `DroneDeliveryTrackingPage(orderId)`, timeline 4 mốc + header card + banner delayed/failed + pull-to-refresh
- `lib/features/drone_delivery/presentation/widgets/drone_delivery_timeline.dart` — **tạo mới**: timeline dọc, mốc hiện tại nổi bật
- `lib/features/drone_delivery/presentation/widgets/drone_approaching_sheet.dart` — **tạo mới**: sheet nhắc ra nhận khi `drone_approaching` (mirror `finding_courier_sheet`)

Core wiring:

- `lib/core/config/feature_flags.dart` — thêm `droneDeliveryEnabled = false`
- `lib/core/routing/app_router.dart` — thêm hằng `droneDeliveryTracking = '/drone-delivery'` + `GoRoute` (top-level, ngoài ShellRoute) nhận `orderId` qua `extra`

### 2026-06-15 — UX revamp lưới ô tủ + DRONE cell type (branch `feat/mobile-user-ui-revamp`)

Routing và home:

- `lib/core/routing/app_router.dart` — thêm route `/stores/lockers` (future deep link); "Xem tất cả" home → LockerPage
- `lib/features/home/presentation/pages/home_page.dart` — `onSeeAll` → `context.go(AppRouter.lockers)` thay vì StoresPage

Lưới ô tủ (mới):

- `lib/features/stores/presentation/pages/store_lockers_page.dart` — **tạo mới**: `StoreLockerGridPage`, lưới ô 2D, `_LockerCard` lazy-load, `_CellGrid`, `_CellTile` (DRONE icon + màu indigo + non-tappable), `_BookingSheet`, `_GridLegend` (thêm Drone), `_CellPalette` (thêm drone = `0xFF6366F1`), `_cellTypeForBooking()` helper

Locker list tab:

- `lib/features/locker/presentation/pages/locker_page.dart` — `_navigateToMap` → `StoreLockerGridPage` thay `LockerDetailMapPage`; bridge `LockerLocation` → `Store` qua `int.tryParse`

Chi tiết cửa hàng:

- `lib/features/stores/presentation/pages/store_detail_page.dart` — "Xem tủ" dùng `Navigator.push` → `StoreLockerGridPage`

Booking pages (bỏ picker khi đến từ lưới ô):

- `lib/features/locker_ops/presentation/pages/rent_locker_page.dart` — thêm `initialLockerName`, `initialCellType`; bỏ picker + skip API load khi `initialLockerId != null`; card read-only tủ + card read-only loại ô
- `lib/features/locker_ops/presentation/pages/send_parcel_page.dart` — thêm `initialLockerName`; bỏ picker + skip API load khi `initialLockerId != null`; card read-only tủ

API service:

- `lib/features/locker_ops/data/locker_ops_service.dart` — thêm `lockersByStore(int storeId)`

Brand colors:

- `lib/features/locker/presentation/pages/locker_detail_map_page.dart` — AppBar/FAB/fallback dùng `AislBrand.navy`
- `lib/features/locker/presentation/widgets/locker_info_modal.dart` — size card header dùng `AislBrand.brandGradient`; "Đặt dịch vụ" → `AislBrand.navy`

### 2026-06-13 (trước đó)

Routing and USER entry:

- `lib/core/routing/app_router.dart`
- `lib/features/home/presentation/pages/home_page.dart`

New USER laundry module:

- `lib/features/user_laundry/infrastructure/models/user_laundry_models.dart`
- `lib/features/user_laundry/infrastructure/services/user_gateway_client.dart`
- `lib/features/user_laundry/infrastructure/services/user_auth_service.dart`
- `lib/features/user_laundry/infrastructure/services/user_service.dart`
- `lib/features/user_laundry/infrastructure/services/user_locker_service.dart`
- `lib/features/user_laundry/infrastructure/services/user_laundry_service.dart`
- `lib/features/user_laundry/infrastructure/services/user_order_service.dart`
- `lib/features/user_laundry/infrastructure/services/user_payment_service.dart`
- `lib/features/user_laundry/infrastructure/services/user_notification_service.dart`
- `lib/features/user_laundry/presentation/pages/user_laundry_order_page.dart`

Docs:

- `docs/flutter-current-role-flow.md`
- `docs/old-mobile-user-flow.md`
- `docs/user-flow-merge-plan.md`
- `docs/user-api-mapping.md`
- `docs/merge-status.md`

## USER flows merged

| Flow | Status | Notes |
| --- | --- | --- |
| Login/register | Partial | Shared Flutter login now calls `POST /api/auth/login` with `identifier/password`. USER `UserAuthService` gateway methods added. Register UI still needs a focused follow-up because it is shared by all roles. |
| Verify OTP | Partial | Email OTP service methods added. Existing shared OTP UI still needs integration with backend temp-token completion if used for new users. |
| Home USER | Merged | Added USER-only `Giat do` shortcut in non-courier `HomePage` branch. "Xem tất cả" locker → LockerPage (nhất quán với tab Tủ). |
| Create laundry order | Merged | New `UserLaundryOrderPage`. |
| Choose service | Partial | UI/service added, but backend `/api/services` route/controller was not confirmed. No mock data added. |
| Xem lưới ô tủ tại địa điểm | **Merged (2026-06-15)** | `StoreLockerGridPage` mới: load tủ theo store (`GET /api/lockers?storeId=X`), lazy-load layout từng tủ (`GET /api/lockers/{id}/layout`), lưới ô 2D theo rowIndex/colIndex, màu theo status, ô DRONE hiện icon máy bay + không cho đặt dịch vụ. Vào từ: tab Tủ → tap địa điểm, cửa hàng → "Xem tủ", home → "Xem tất cả". |
| Booking thuê tủ (từ lưới ô) | **Merged (2026-06-15)** | Khi vào `RentLockerPage` từ lưới ô (`initialLockerId` có sẵn): bỏ picker chọn tủ, bỏ API load danh sách tủ, hiện card read-only tủ + loại ô đã chọn (có icon khóa). |
| Booking gửi hàng (từ lưới ô) | **Merged (2026-06-15)** | Khi vào `SendParcelPage` từ lưới ô: bỏ picker chọn tủ, bỏ API load, hiện card read-only. |
| Choose locker | Merged | Uses `/api/stores`, `/api/lockers`, `/api/lockers/{lockerId}/boxes/available`. Nay thêm `/api/lockers?storeId=X` và `/api/lockers/{id}/layout`. |
| Payment | Merged | Creates payment via `/api/payments` and opens payment URL/deeplink if returned. |
| Track status | Merged | Refreshes order status via `/api/orders/{id}/status`. |
| Theo dõi giao drone (người nhận) | **Merged (2026-07-03)** | Feature `drone_delivery`, Phase 1 push-only. FCM 6 type `drone_*` → deep-link `DroneDeliveryTrackingPage(orderId)` (timeline). Fetch trạng thái `GET /api/orders/{orderId}/drone-delivery` **đang tắt sau flag `droneDeliveryEnabled` + mock** (backend chưa có endpoint). Phase 2 (live map/STOMP) chỉ cần thêm `{lat,lng,heading}` — contract hiện đã tương thích. |
| Order history | Service ready | `UserOrderService.getMyOrders()` added. Existing Flutter `OrderPage` not replaced to protect courier/customer switching. |
| Notifications | Service ready | USER notification service added. Existing notification page not replaced. |
| Profile | Service ready | USER profile service added. Existing profile UI not replaced. |
| Logout | Service ready | USER auth service logout added. Existing profile logout not replaced. |

## Other roles impact

No non-USER role flow was intentionally changed.

Kept unchanged:

- Courier mode provider and courier dispatch listener.
- Courier dashboard, courier order, active delivery, courier map.
- Staff/technician profile/application/maintenance screens.
- Admin/backend-only role behavior.
- Existing bottom navigation tabs.
- Existing order/profile/notification providers.

The only visible UI change is in USER Home when courier mode is off.

## APIs connected

Connected through new USER services:

- `/api/auth/login`
- `/api/auth/register`
- `/api/auth/email/send-otp`
- `/api/auth/email/verify-otp`
- `/api/auth/email/complete-registration`
- `/api/auth/logout`
- `/api/user/profile`
- `/api/user/me/statistics`
- `/api/user/fcm-token`
- `/api/user/password`
- `/api/stores`
- `/api/lockers`
- `/api/lockers/{lockerId}/boxes`
- `/api/lockers/{lockerId}/boxes/available`
- `/api/lockers?storeId={storeId}` *(thêm 2026-06-15 — load tủ theo cửa hàng)*
- `/api/lockers/{id}/layout` *(thêm 2026-06-15 — lưới ô vật lý, trả về danh sách CellResponse)*
- `/api/lockers/{id}/report`
- `/api/orders`
- `/api/orders/{id}/confirm`
- `/api/orders/{id}/status`
- `/api/orders/{id}`
- `/api/orders/my-orders`
- `/api/orders/{id}/cancel`
- `/api/payments`
- `/api/payments/order/{orderId}`
- `/api/notifications/all`
- `/api/notifications/unread`
- `/api/notifications/unread/count`
- `/api/notifications/{id}/read`
- `/api/notifications/read-all`
- `/api/notifications/{id}`

## APIs still TODO

- `/api/services`: Flutter service selection calls this, but backend route/controller was not confirmed in the current microservice tree.
- Full promotion/voucher picker: old mobile uses promotion and loyalty services; only raw promotion code passthrough was merged.
- Shared register/OTP UI integration: requires a focused change because current Flutter auth screens are shared by all roles.
- `GET /api/orders/{orderId}/drone-delivery`: mobile đã sẵn sàng tiêu thụ (feature `drone_delivery`) nhưng backend chưa có endpoint → đang tắt sau flag `droneDeliveryEnabled` + mock. Bật cờ khi backend triển khai. Backend cũng cần gửi FCM data payload `{ type: drone_*, title, content, orderId, deliveryId, status, eta }`.

## Checks

Completed:

- `flutter pub get`: passed.
- `flutter analyze`: ran. Plain command exits with code 1 because the project currently has 443 info-level lint findings. No error/warning-level issue was introduced by the merge.
- `flutter analyze --no-fatal-infos`: passed.
- `flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8080`: passed after wiring shared login to `/api/auth/login`, generated `build/app/outputs/flutter-apk/app-debug.apk`.

Blocked:

- `flutter run` on Android emulator: blocked because the available AVD `Pixel_8` exits during startup with `Your device does not have enough disk space to run avd: Pixel_8`.
- Web/desktop fallback is not usable for this repo because only `android/` and `ios/` platform folders exist; `web/` and `windows/` are not configured.

## Local seed data created

- Account: `nqbhuy2004nt@gmail.com`
- Role: `CUSTOMER`
- User id: `1`
- Temporary password: `Huy@123456`
- Store: `Lockerly Demo Store`, id `1`
- Locker: `Demo Locker 01`, id `1`
- Available boxes: ids `1`, `2`, `3`
