# 04 — Đánh giá: Gap & Đề xuất cải tiến

> Phạm vi dự án hiện tại: **tủ locker gửi/giữ đồ** — SEND (gửi hàng C2C) + RENTAL (thuê ô giữ đồ).
> **Không** bao gồm: giặt sấy (LAUNDRY), giao hàng qua courier, staff-service.
> Đánh giá dựa trên phân tích source 4 dự án + `laundry-locker-microservices/docs/BUSINESS_FLOWS_CURRENT.md`.

## D.1 — Luồng còn thiếu / chưa chạy end-to-end

1. **Giao hàng bằng Drone — chỉ demo cục bộ.**
   Đặt drone không tạo đơn backend (`DroneDeliveryStore` in-memory), phí "Miễn phí (Demo)", tracking mô phỏng.
   → *Đề xuất:* khi có drone-service thật, nối đặt ô drone → đơn thật + bắn event `delivery.status.changed` (hạ tầng noti đã sẵn) để tracking/notify thật.

2. **Reset mật khẩu — chưa có.** "Quên mật khẩu?" chỉ hiện toast.
   → *Đề xuất:* thêm luồng OTP email/SĐT để đặt lại mật khẩu.

3. **Không có UI cabinet (tablet) để mở ô tại chỗ.** Mở ô phụ thuộc `POST /api/iot/unlock` từ mobile hoặc force-open của Maintenance + IoT simulator.
   → *Đề xuất:* hoàn thiện tablet-web cabinet UI (đang là việc tương lai).

## D.2 — Chức năng còn thiếu / chưa hoàn chỉnh

4. **Thanh toán không bắt buộc.**
   PIN/QR được cấp trước và **không phụ thuộc đã thanh toán** — khách dùng ô mà chưa trả tiền.
   → *Đề xuất:* chặn cấp PIN (hoặc chặn "bắt đầu kỳ thuê") tới khi `PAID`, hoặc chính sách trả sau rõ ràng.

5. **Nhiều mục Profile bị ẩn do backend chưa có** (feature flags OFF): Gói dịch vụ, Kho voucher, Nhận diện khuôn mặt, Quảng cáo/blog home.
   → *Đề xuất:* hoàn thiện backend rồi bật cờ, hoặc bỏ khỏi roadmap để UI khỏi "nửa vời".

6. **Manager không đổi được trạng thái đơn** (tab đơn read-only), trong khi Admin làm được.
   → *Đề xuất:* cấp thao tác đơn ở mức Manager theo phạm vi tủ được quản.

## D.3 — Vấn đề đúng đắn của luồng tủ (theo gap map dự án)

7. **Ô kẹt RESERVED (G1/G2 — đã vá phần order):** đơn INITIALIZED >24h nay tự hủy + release ô (job 15 phút). Còn **TTL cấp ô (locker-service) là follow-up**.
   → *Kiểm thử:* tạo đơn rồi bỏ dở, chờ job, xác nhận ô về AVAILABLE.
8. **Quá hạn lấy hàng chỉ nhắc + tính phí (G3):** ô vẫn OCCUPIED tới khi có lệnh complete — **chưa tự move-to-storage/giải phóng**.
   → *Đề xuất:* job dời hàng/giải phóng ô sau X giờ quá hạn.
9. **Trạng thái ô là bản sao best-effort của đơn (G4):** occupy/release nuốt lỗi → **rủi ro lệch trạng thái, chưa có job đối soát**.
   → *Đề xuất:* job reconcile định kỳ giữa order-service ↔ locker-service (và box-health IoT).
10. **`EXPIRED` chưa là trạng thái ô** (chỉ ở cấp đơn qua deadline).

## D.4 — Role / phân quyền

11. **Tên role chưa đồng nhất** (`CUSTOMER` vs `USER` trong seed) — routing coi mọi role ≠ vận hành là customer; nên chuẩn hóa một tên.
12. **Không tự đăng ký role vận hành trên mobile** (đúng chủ đích: ADMIN/MANAGER/MAINTENANCE tạo qua Admin web, tạo cả `auth_account`). Cần verify tài khoản vận hành do Admin tạo **login được**.

## D.5 — Đề xuất cải tiến theo thực tế (ưu tiên)

| Ưu tiên | Hạng mục | Lý do |
|---|---|---|
| 🔴 Cao | Chính sách thanh toán trước khi cấp PIN | Rủi ro doanh thu (điểm 4) |
| 🔴 Cao | Reset mật khẩu | Chức năng cơ bản còn thiếu (điểm 2) |
| 🟠 TB | Job đối soát trạng thái ô + TTL ô (G3/G4) | Chống kẹt/lệch ô (điểm 7–9) |
| 🟠 TB | Manager đổi trạng thái đơn theo phạm vi quản | Hoàn chỉnh vận hành (điểm 6) |
| 🟢 Thấp | Nối drone/subscription/voucher/face khi có backend | Bật lại các mục đang ẩn (điểm 1, 5) |

## D.6 — Kết luận: nên nghiệm thu gì

- **Nghiệm thu nghiệp vụ (chạy thật):** Đăng ký/Đăng nhập → Thuê tủ (RENTAL) → Gửi hàng (SEND) → Thanh toán/Nạp ví → Ủy quyền → Báo lỗi↔Bảo trì → Reorder/Hủy → Khuyến mãi → Manager/Maintenance/Technician/Admin.
- **Chỉ nghiệm thu giao diện (chưa có backend thật):** Drone delivery (khách đặt).
- **Cần thiết bị/hạ tầng riêng để test thật:** Mở tủ IoT (simulator/hardware), Push FCM (Firebase credential production).
