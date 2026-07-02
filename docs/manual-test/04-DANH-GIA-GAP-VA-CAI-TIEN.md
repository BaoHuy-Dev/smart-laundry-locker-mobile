# 04 — Đánh giá: Gap & Đề xuất cải tiến

> Đánh giá dựa trên phân tích source 4 dự án + tài liệu nghiệp vụ authoritative
> `laundry-locker-microservices/docs/BUSINESS_FLOWS_CURRENT.md` (mục 24, 25 — gap map G1–G16).

## D.1 — Luồng còn thiếu / chưa chạy end-to-end

1. **Giao hàng qua Courier (PARCEL_RECEIVE) — thiếu backend (Gap G6).**
   UI courier đầy đủ (dashboard, dispatch, active-delivery, logistics "Tìm tài xế", màn Thanh toán ship) nhưng gọi endpoint legacy/không tồn tại → **không test được end-to-end**.
   → *Đề xuất:* xây `dispatch/courier` backend (tạo đơn ship, gán tài xế, **access code riêng cho courier tách với PIN khách**), hoặc ẩn sau feature flag như subscription/voucher để tránh hiểu nhầm là chức năng thật.

2. **Giao hàng bằng Drone — chỉ demo cục bộ.**
   Đặt drone không tạo đơn backend (`DroneDeliveryStore` in-memory), phí "Miễn phí (Demo)", tracking mô phỏng.
   → *Đề xuất:* khi có drone-service thật, nối đặt ô drone → đơn thật + bắn event `delivery.status.changed` (hạ tầng noti đã sẵn) để tracking/notify thật.

3. **Tạo đơn Giặt ủi (LAUNDRY) — không có lối vào trên UI mới.**
   Màn "Đơn tủ" có bộ lọc "Giặt ủi" và backend còn lifecycle giặt (collect/weight/process/ready/return), nhưng **booking sheet chỉ cho Thuê/Gửi** → không tạo được đơn giặt.
   → *Đề xuất:* thêm dịch vụ "Giặt ủi" vào sheet chọn dịch vụ tại ô, hoặc gỡ hẳn bộ lọc/lifecycle nếu ngừng kinh doanh giặt.

4. **Reset mật khẩu — chưa có.** "Quên mật khẩu?" chỉ hiện toast.
   → *Đề xuất:* thêm luồng OTP email/SĐT để đặt lại mật khẩu.

5. **Không có UI cabinet (tablet) để mở ô tại chỗ.** Mở ô phụ thuộc `POST /api/iot/unlock` từ mobile hoặc force-open của Maintenance + IoT simulator.
   → *Đề xuất:* hoàn thiện tablet-web cabinet UI (đang là việc tương lai).

## D.2 — Chức năng còn thiếu / chưa hoàn chỉnh

6. **Duyệt hồ sơ Nhân viên/Courier không có trên Admin mobile.**
   Khách nộp hồ sơ PENDING nhưng Admin Home (6 tab) **không có màn duyệt/approve/reject** — chỉ đổi role thủ công.
   → *Đề xuất:* thêm tab "Hồ sơ ứng tuyển" trong Admin để duyệt/từ chối kèm lý do (đồng bộ `staffStatus`).

7. **Thanh toán không bắt buộc.**
   PIN/QR được cấp trước và **không phụ thuộc đã thanh toán** — khách dùng ô mà chưa trả tiền.
   → *Đề xuất:* chặn cấp PIN (hoặc chặn "bắt đầu kỳ thuê") tới khi `PAID`, hoặc chính sách trả sau rõ ràng.

8. **Nhiều mục Profile bị ẩn do backend chưa có** (feature flags OFF): Gói dịch vụ, Kho voucher, Nhận diện khuôn mặt, Quảng cáo/blog home.
   → *Đề xuất:* hoàn thiện backend rồi bật cờ, hoặc bỏ khỏi roadmap để UI khỏi "nửa vời".

9. **Staff read-only.**
   Backend `/api/staff/**` chỉ GET → Staff **không thể** thu gom/xử lý/trả đồ hay mở tủ trên mobile dù lifecycle giặt tồn tại.
   → *Đề xuất:* mở endpoint thao tác cho STAFF (collect/ready/return/unlock) để luồng giặt vận hành thật.

10. **Manager không đổi được trạng thái đơn** (tab đơn read-only), trong khi Admin làm được.
    → *Đề xuất:* cấp thao tác đơn ở mức Manager theo phạm vi tủ được quản.

## D.3 — Vấn đề đúng đắn của luồng tủ (theo gap map dự án)

11. **Ô kẹt RESERVED (G1/G2 — đã vá phần order):** đơn INITIALIZED >24h nay tự hủy + release ô (job 15 phút). Còn **TTL cấp ô (locker-service) là follow-up**.
    → *Kiểm thử:* tạo đơn rồi bỏ dở, chờ job, xác nhận ô về AVAILABLE.
12. **Quá hạn lấy hàng chỉ nhắc + tính phí (G3):** ô vẫn OCCUPIED tới khi có lệnh complete — **chưa tự move-to-storage/giải phóng**.
    → *Đề xuất:* job dời hàng/giải phóng ô sau X giờ quá hạn.
13. **Trạng thái ô là bản sao best-effort của đơn (G4):** occupy/release nuốt lỗi → **rủi ro lệch trạng thái, chưa có job đối soát**.
    → *Đề xuất:* job reconcile định kỳ giữa order-service ↔ locker-service (và box-health IoT).
14. **`EXPIRED` chưa là trạng thái ô** (chỉ ở cấp đơn qua deadline).

## D.4 — Role / phân quyền

15. **Tên role chưa đồng nhất** (`CUSTOMER` vs `USER` trong seed) — routing coi mọi role ≠ vận hành là customer; nên chuẩn hóa một tên.
16. **Không tự đăng ký role vận hành trên mobile** (đúng chủ đích: ADMIN/MANAGER/MAINTENANCE tạo qua Admin web, tạo cả `auth_account`). Cần verify tài khoản vận hành do Admin tạo **login được**.
17. **COURIER/TECHNICIAN qua hồ sơ tự nộp** nhưng thiếu màn duyệt (điểm 6) → phụ thuộc thao tác DB/admin web.

## D.5 — Đề xuất cải tiến theo thực tế (ưu tiên)

| Ưu tiên | Hạng mục | Lý do |
|---|---|---|
| 🔴 Cao | Màn duyệt hồ sơ NV/Courier trên Admin | Khóa cứng luồng tuyển courier (điểm 6) |
| 🔴 Cao | Ẩn/feature-flag hoặc dựng backend cho Courier delivery | Tránh chức năng "chết" gây hiểu nhầm khi demo (điểm 1) |
| 🔴 Cao | Chính sách thanh toán trước khi cấp PIN | Rủi ro doanh thu (điểm 7) |
| 🟠 TB | Reset mật khẩu | Chức năng cơ bản còn thiếu (điểm 4) |
| 🟠 TB | Job đối soát trạng thái ô + TTL ô (G3/G4) | Chống kẹt/lệch ô (điểm 12–13) |
| 🟠 TB | Mở thao tác cho STAFF (giặt/mở tủ) | Kích hoạt luồng giặt thật (điểm 9) |
| 🟢 Thấp | Nối drone/subscription/voucher/face khi có backend | Bật lại các mục Profile đang ẩn (điểm 2,8) |

## D.6 — Kết luận: nên nghiệm thu gì

- **Nghiệm thu nghiệp vụ (chạy thật):** Đăng ký/Đăng nhập → Thuê tủ (RENTAL) → Gửi hàng (SEND) → Thanh toán/Nạp ví → Ủy quyền → Báo lỗi↔Bảo trì → Reorder/Hủy → Khuyến mãi → Manager/Maintenance/Technician/Admin.
- **Chỉ nghiệm thu giao diện (chưa có backend thật):** Courier delivery, Drone delivery (khách đặt).
- **Cần thiết bị/hạ tầng riêng để test thật:** Mở tủ IoT (simulator/hardware), Flight Data MAVLink (drone/SITL), Push FCM (Firebase credential production).
