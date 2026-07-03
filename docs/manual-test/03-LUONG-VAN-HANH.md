# 03 — Luồng Vận hành (Manager / Staff / Maintenance / Technician / Admin)

> Mỗi bước: **Role · Màn hình · Thao tác · Kết quả mong đợi**.
> Đăng nhập bằng đúng tài khoản role (xem [01](01-CHUAN-BI-VA-TAI-KHOAN.md)).

---

## FLOW 12 — Manager (Quản lý vận hành)

- [ ] **12.1** — MANAGER · Đăng nhập → **Manager Home**, 3 tab: Thống kê / Sơ đồ tủ / Đơn hàng.
- [ ] **12.2 (Thống kê)** — tab **Thống kê**: mỗi tủ hiện Tổng ô/Trống/Giữ chỗ/Có đồ/Hỏng, % công suất, số phiếu sự cố mở, cờ bãi đáp drone.
- [ ] **12.3 (Sơ đồ tủ)** — tab **Sơ đồ tủ** → chọn tủ (dropdown) → grid ô theo màu → **giữ (long-press) 1 ô** → dialog **Báo hỏng** (nhập lý do) hoặc **Mở lại ô** (nếu FAULT) · Kết quả: ô đổi trạng thái.
- [ ] **12.4 (Đơn hàng)** — tab **Đơn hàng** → lọc trạng thái (Tất cả/INITIALIZED/STORING/RETURNED/COMPLETED/CANCELED) · Kết quả: danh sách đơn (chỉ xem — Manager không đổi trạng thái đơn).

---

## FLOW 13 — Staff (Nhân viên ca) — ⚠️ read-only

> Backend `/api/staff/**` chỉ GET — chỉ xem, chưa thao tác đơn/mở tủ.

- [ ] **13.1** — STAFF · Đăng nhập → **Staff Home**, 3 tab: Tủ của tôi / Đơn hàng / Thống kê.
- [ ] **13.2** — tab **Tủ của tôi**: tủ được phân công → chọn tủ → sơ đồ ô + tóm tắt (Tổng/Sẵn sàng/Lỗi). *(Chưa phân công → rỗng.)*
- [ ] **13.3** — tab **Đơn hàng**: đơn trong ca (xem); tab **Thống kê**: tổng quan ô hôm nay.
- [ ] **13.4** — nếu endpoint trả 403/404 → banner "Tính năng đang được kích hoạt".

---

## FLOW 14 — Maintenance (Đội bảo trì) — 5 tab

- [ ] **14.1 (Kiểm tra tủ)** — MAINTENANCE · **Maintenance Home** → tab **Kiểm tra tủ** → chọn tủ → grid ô + **Tình trạng phần cứng ô** (cửa mở/đóng, "cần chú ý"). Chạm 1 ô → bottom sheet hành động **theo trạng thái**: Báo hỏng / Ngưng dùng ô / Đánh dấu đang vệ sinh / Khôi phục ô / **Mở tủ khẩn cấp** (force-open, luôn ghi audit log).
- [ ] **14.2 (Sự cố — nhận & xử lý)** — tab **Sự cố** → phiếu do khách/nhân viên báo (kèm địa chỉ tủ + SĐT người báo + badge SLA) → **Chỉ đường** (bản đồ ngoài) → **Nhận xử lý** (claim: OPEN→IN_PROGRESS) → sau khi sửa → **Hoàn tất** (resolve → clear fault, ô về AVAILABLE). ➡️ đóng vòng với [Flow 6.3/6.4](02-LUONG-KHACH-HANG.md).
- [ ] **14.3 (Cảnh báo phần cứng)** — đầu tab Sự cố: mục "Cửa mở bất thường" gom mọi ô cửa OPEN nhưng không OCCUPIED trên tất cả tủ (nếu IoT có báo).
- [ ] **14.4 (Việc của tôi)** — tab **Việc của tôi**: phiếu đang xử lý / đã hoàn thành; xem điểm đánh giá trung bình.
- [ ] **14.5 (Định kỳ)** — tab **Định kỳ**: lịch bảo trì phòng ngừa (Admin tạo) → mục **Đến hạn** → **Đã kiểm tra** → dời mốc kế tiếp.
- [ ] **14.6 (Drone fleet)** — tab **Drone**: danh sách drone (IDLE/CHARGING/IN_FLIGHT/MAINTENANCE/FAULT, % pin, KTV phụ trách). Chạm drone → **Nhận xử lý** / **Đổi trạng thái** (FAULT bắt buộc lý do) / **Cập nhật pin %** / **Nhật ký**. *(Pin/trạng thái nhập tay, chưa có telemetry.)*
- [ ] **14.7 (Mission Planner)** — tab Drone → **Lập kế hoạch bay** → chạm bản đồ thêm waypoint, đặt độ cao/lệnh, xuất `.waypoints`/JSON, lưu thư viện. *(Cục bộ, không gọi backend.)*
- [ ] **14.8 (Flight Data)** — tab Drone → **Telemetry & điều khiển** → chọn UDP/TCP + host/port → kết nối flight controller MAVLink thật/SITL → HUD + gửi ARM/RTL/TAKEOFF. *(Chỉ chạy khi có drone/SITL thật; không qua backend.)*

---

## FLOW 15 — Technician (Kỹ thuật viên IoT)

- [ ] **15.1** — TECHNICIAN · **Technician Home**, 3 tab: Thiết bị / Chi tiết / Điều khiển.
- [ ] **15.2** — tab **Thiết bị** → chạm 1 thiết bị → tab **Chi tiết**: model/firmware/IP/MAC/vị trí/last seen + **nhật ký hoạt động**.
- [ ] **15.3** — tab **Điều khiển** → đổi trạng thái ONLINE/OFFLINE/ERROR; **Restart thiết bị** (confirm → publish MQTT, luôn ghi audit) · Kết quả: toast xác nhận, log cập nhật.

---

## FLOW 16 — Admin (Quản trị hệ thống) — 6 tab

- [ ] **16.1 (Tổng quan)** — ADMIN · **Admin Home** → tab **Tổng quan**: Tổng đơn / Người dùng / Cửa hàng / DT hôm nay, đơn theo trạng thái, doanh thu. *(KPI cross-service có thể = 0 vì chưa aggregate.)*
- [ ] **16.2 (Người dùng)** — tab **Người dùng** → tìm/lọc trạng thái+role+sắp xếp → chạm user → **Đổi role** (CUSTOMER/MANAGER/MAINTENANCE/STAFF/TECHNICIAN/ADMIN) / **Khoá–Mở khoá tài khoản**.
- [ ] **16.3 (Cửa hàng)** — tab **Cửa hàng** → **Thêm mới** (tên/địa chỉ/SĐT) / **Bật–Tắt** trạng thái.
- [ ] **16.4 (Đơn hàng)** — tab **Đơn hàng** → lọc trạng thái/loại/tìm kiếm → chạm đơn → **Đổi trạng thái** (INITIALIZED/STORING/COMPLETED/CANCELED).
- [ ] **16.5 (Khuyến mãi)** — tab **Khuyến mãi** → **Thêm mới** / lọc / xóa. ➡️ mã tạo ở đây dùng ở [Flow 8](02-LUONG-KHACH-HANG.md).
- [ ] **16.6 (Drone)** — tab **Drone**: danh sách + lọc trạng thái (quản lý đội drone cấp admin).

---

## FLOW 17 — Thông báo & Push trạng thái giao hàng

- [ ] **17.1** — mọi role · chuông (Home/Profile) → **Danh sách thông báo** → đọc / đánh dấu đã đọc; badge số chưa đọc cập nhật.
- [ ] **17.2** — noti trạng thái giao hàng (dispatched/approaching/arrived/delivered/delayed/failed) → **chạm noti** deep-link mở **chi tiết đơn** theo orderId; đơn tự reload. *(Push thật cần Firebase credential production + thiết bị thật; luồng drone bắn event vẫn TODO.)*
