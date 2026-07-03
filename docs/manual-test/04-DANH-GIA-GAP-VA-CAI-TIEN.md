# 04 — Đánh giá: Gap & Đề xuất cải tiến

> Phạm vi dự án hiện tại: **tủ locker gửi/giữ đồ** — SEND (gửi hàng C2C) + RENTAL (thuê ô giữ đồ).
> **Không** bao gồm: giặt sấy (LAUNDRY), giao hàng qua courier, staff-service.
> Đánh giá dựa trên phân tích source 4 dự án + `laundry-locker-microservices/docs/BUSINESS_FLOWS_CURRENT.md`.
> Các mục đánh dấu ✅ đã được xử lý (đợt cải tiến 06–07/2026, xem cột Trạng thái ở D.5).

## D.1 — Luồng còn thiếu / chưa chạy end-to-end

1. **Giao hàng bằng Drone — chỉ demo cục bộ.**
   Đặt drone không tạo đơn backend (`DroneDeliveryStore` in-memory), phí "Miễn phí (Demo)", tracking mô phỏng.
   → *Đề xuất:* khi có drone-service thật, nối đặt ô drone → đơn thật + bắn event `delivery.status.changed` (hạ tầng noti đã sẵn) để tracking/notify thật.

2. ✅ **Reset mật khẩu — ĐÃ CÓ.** "Quên mật khẩu?" (màn đăng nhập + bottom sheet) mở luồng: nhập email → nhận OTP 6 số qua email (hết hạn 5 phút) → nhập OTP + mật khẩu mới. Backend `POST /api/auth/forgot-password` → `POST /api/auth/reset-password`; đổi xong backend thu hồi toàn bộ refresh token cũ.

3. **Không có UI cabinet (tablet) để mở ô tại chỗ.** Mở ô phụ thuộc `POST /api/iot/unlock` từ mobile hoặc force-open của Maintenance + IoT simulator.
   → *Đề xuất:* hoàn thiện tablet-web cabinet UI (đang là việc tương lai).

## D.2 — Chức năng còn thiếu / chưa hoàn chỉnh

4. ✅ **Thanh toán trước khi dùng ô — ĐÃ CHẶN.** `OrderService.confirm` từ chối bỏ hàng/bắt đầu thuê khi đơn có phí mà chưa `PAID` (lỗi `ORDER_UNPAID`). Tắt được bằng `app.order.require-payment-before-drop=false`.

5. **Nhiều mục Profile bị ẩn do backend chưa có** (feature flags OFF): Gói dịch vụ, Kho voucher, Nhận diện khuôn mặt, Quảng cáo/blog home.
   → *Đề xuất:* hoàn thiện backend rồi bật cờ, hoặc bỏ khỏi roadmap để UI khỏi "nửa vời".

6. ✅ **Manager đổi được trạng thái đơn — ĐÃ CÓ.** `PATCH /api/manage/orders/{id}/status` (gateway giới hạn MANAGER/ADMIN, manager được ghi làm actor trong timeline); tab Đơn hàng trên app Manager bấm vào đơn → bottom sheet đổi trạng thái.
   *Ghi chú:* chưa có mô hình "gán tủ cho manager" trong DB nên phạm vi hiện là mọi tủ (giống Admin); nếu cần giới hạn theo tủ được quản thì phải thêm bảng gán tủ ↔ manager (việc tương lai).

## D.3 — Vấn đề đúng đắn của luồng tủ (theo gap map dự án)

7. ✅ **Ô kẹt RESERVED (G1/G2) — ĐÃ VÁ CẢ HAI LỚP:** đơn INITIALIZED >24h tự hủy + release ô (job 15 phút, order-service); TTL cấp ô cũng đã có — locker-service ghi `reservedUntil` khi reserve và sweep mỗi giờ nhả ô RESERVED quá hạn (backstop khi order-service chết).
8. ✅ **Quá hạn lấy hàng (G3) — ĐÃ CÓ JOB DỜI KHO:** sau `app.order.overdue-release-hours` (mặc định 24h) kể từ `pickupDeadline`, job (mỗi giờ) chốt phí quá hạn, chuyển đơn sang **EXPIRED**, thu hồi PIN, nhả ô và thông báo cho khách/người nhận. Nhân viên trao trả đồ từ kho bằng `POST /api/orders/{id}/checkout` (đã cho phép với đơn EXPIRED). Trigger tay: `POST /api/admin/scheduler/release-overdue`.
9. ✅ **Lệch trạng thái ô ↔ đơn (G4) — ĐÃ CÓ JOB ĐỐI SOÁT:** job mỗi giờ so khớp locker-service ↔ order-service hai chiều: ô RESERVED/OCCUPIED "mồ côi" (không đơn hoạt động nào tham chiếu) → nhả về AVAILABLE (RESERVED còn hạn giữ chỗ thì bỏ qua để tránh đụng đơn vừa tạo); đơn hoạt động mà ô lại AVAILABLE → giữ/chiếm lại. Trigger tay: `POST /api/admin/scheduler/reconcile-boxes`.
10. ✅ **`EXPIRED` đã thành trạng thái đơn tự động** (job G3 đặt); ở cấp ô thì ô được nhả về AVAILABLE ngay khi đơn expire nên không cần trạng thái ô riêng.

## D.4 — Role / phân quyền

11. **Tên role chưa đồng nhất** (`CUSTOMER` vs `USER` trong seed) — routing coi mọi role ≠ vận hành là customer; nên chuẩn hóa một tên.
12. **Không tự đăng ký role vận hành trên mobile** (đúng chủ đích: ADMIN/MANAGER/MAINTENANCE tạo qua Admin web, tạo cả `auth_account`). Cần verify tài khoản vận hành do Admin tạo **login được**.

## D.5 — Đề xuất cải tiến theo thực tế (ưu tiên)

| Ưu tiên | Hạng mục | Lý do | Trạng thái |
|---|---|---|---|
| 🔴 Cao | Chính sách thanh toán trước khi bỏ hàng | Rủi ro doanh thu (điểm 4) | ✅ Xong (PR #61 microservices) |
| 🔴 Cao | Reset mật khẩu | Chức năng cơ bản còn thiếu (điểm 2) | ✅ Xong (backend có sẵn + UI mobile mới) |
| 🟠 TB | Job đối soát trạng thái ô + xử lý quá hạn + TTL ô (G3/G4) | Chống kẹt/lệch ô (điểm 7–9) | ✅ Xong (3 job scheduler mới) |
| 🟠 TB | Manager đổi trạng thái đơn | Hoàn chỉnh vận hành (điểm 6) | ✅ Xong (endpoint + UI Manager) |
| 🟢 Thấp | Nối drone/subscription/voucher/face khi có backend | Bật lại các mục đang ẩn (điểm 1, 5) | ⏳ Chờ backend mới |

## D.6 — Kết luận: nên nghiệm thu gì

- **Nghiệm thu nghiệp vụ (chạy thật):** Đăng ký/Đăng nhập → **Quên mật khẩu (OTP email)** → Thuê tủ (RENTAL) → Gửi hàng (SEND) → **Thanh toán bắt buộc trước khi bỏ hàng** → Nạp ví → Ủy quyền → Báo lỗi↔Bảo trì → Reorder/Hủy → Khuyến mãi → **Manager đổi trạng thái đơn** → Maintenance/Technician/Admin → **job quá hạn (EXPIRED) + job đối soát ô**.
- **Chỉ nghiệm thu giao diện (chưa có backend thật):** Drone delivery (khách đặt).
- **Cần thiết bị/hạ tầng riêng để test thật:** Mở tủ IoT (simulator/hardware), Push FCM (Firebase credential production).
