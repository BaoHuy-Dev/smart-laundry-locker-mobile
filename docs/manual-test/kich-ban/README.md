# Bộ tài liệu hướng dẫn sử dụng theo kịch bản (có ảnh từng màn hình)

> Ảnh chụp **thật** từ ứng dụng chạy trên Android (emulator Pixel 4), kết nối
> backend đầy đủ (Docker) + **tủ khoá IoT phản hồi thật** (MQTT).
> Cập nhật: 2026-07-03. Tài khoản demo mật khẩu `12345678`.

Bộ tài liệu này đi theo **kịch bản end-to-end**, phủ **mọi vai trò từ Admin
xuống người dùng**. Mỗi màn hình có ảnh chụp + mô tả cụ thể từng thao tác.

## Danh mục kịch bản

| File | Vai trò | Nội dung |
|---|---|---|
| [00-xac-thuc.md](00-xac-thuc.md) | Chung | Đăng nhập · Đăng ký · Quên mật khẩu (OTP email) |
| [01-khach-hang.md](01-khach-hang.md) | **Customer** | Gửi hàng qua tủ → thanh toán → mở tủ (IoT) · Hồ sơ · Khoá sinh trắc học |
| [02-bao-tri.md](02-bao-tri.md) | **Maintenance** | Kiểm tra tủ · nhận & xử lý phiếu sự cố · clear fault · bảo trì định kỳ |
| [03-quan-ly.md](03-quan-ly.md) | **Manager** | Thống kê tủ · danh sách đơn · đổi trạng thái đơn |
| [04-admin.md](04-admin.md) | **Admin** | Dashboard · quản lý người dùng + **đổi role** · cửa hàng · khuyến mãi |
| [05-ky-thuat-vien.md](05-ky-thuat-vien.md) | **Technician** | Danh sách thiết bị IoT · chi tiết · điều khiển/restart |

## Bản đồ vai trò (Admin → User)

```
ADMIN         Toàn quyền: dashboard, quản lý user + đổi role, cửa hàng, đơn, khuyến mãi, drone
  │  (cấp role qua "Đổi role")
  ├── MANAGER       Vận hành tủ: thống kê, sơ đồ tủ, đổi trạng thái đơn
  ├── MAINTENANCE   Bảo trì tủ: kiểm tra ô, nhận/xử lý phiếu sự cố, clear fault, lịch định kỳ, đội drone
  ├── TECHNICIAN    Kỹ thuật IoT: xem/điều khiển/restart thiết bị cabinet
  └── CUSTOMER      Khách: gửi/giữ đồ qua tủ, thanh toán, mở tủ, ủy quyền, báo lỗi
```

Điều hướng sau đăng nhập tự động theo role (ưu tiên cao → thấp):
**ADMIN → MANAGER → TECHNICIAN → MAINTENANCE → STAFF → CUSTOMER**.

## Chuỗi phối hợp giữa các vai trò (cross-role)

```
Khách GỬI HÀNG ──(PIN xoay vòng + thông báo)──▶ Người nhận LẤY HÀNG
Khách BÁO Ô LỖI ─▶ MAINTENANCE nhận phiếu → sửa → Hoàn tất ─(thông báo)─▶ Khách đánh giá
ADMIN đổi role ─▶ user đăng nhập lại vào đúng Home (vd CUSTOMER → TECHNICIAN)
MANAGER/ADMIN đổi trạng thái đơn ─▶ Khách nhận thông báo
```

## Tài khoản demo

| Vai trò | Đăng nhập |
|---|---|
| ADMIN | `baohuy2k12k4@gmail.com` |
| MANAGER | `huynqbse180211@fpt.edu.vn` |
| MAINTENANCE | `se180211nguyenquocbaohuy@gmail.com` |
| CUSTOMER | `nqbhuy2004nt@gmail.com` |
| TECHNICIAN | tài khoản CUSTOMER được Admin đổi role sang TECHNICIAN (xem [04-admin.md](04-admin.md)) |
