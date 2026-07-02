# Bộ tài liệu Kiểm thử thủ công — Smart Laundry Locker

> Cập nhật: 2026-07-02 · Phạm vi: 4 dự án
> `smart-laundry-locker-mobile` · `laundry-locker-microservices` · `laundry-locker-frontend` · `smart-locker-iot`

Bộ tài liệu này giúp **kiểm thử thủ công (manual test) toàn bộ luồng nghiệp vụ trên app mobile** mà không cần đọc source code. Mỗi bước ghi rõ: **(1) Role thực hiện · (2) Màn hình · (3) Thao tác · (4) Kết quả mong đợi · (5) Bàn giao cho role kế tiếp**.

## Danh mục tài liệu

| File | Nội dung |
|---|---|
| [01-CHUAN-BI-VA-TAI-KHOAN.md](01-CHUAN-BI-VA-TAI-KHOAN.md) | Môi trường, tài khoản test, điều hướng theo role, trạng thái đơn/ô tủ, sơ đồ handoff |
| [02-LUONG-KHACH-HANG.md](02-LUONG-KHACH-HANG.md) | Flow 1–11: Đăng ký/Đăng nhập, Thuê tủ, Gửi hàng, Thanh toán, Ủy quyền, Báo lỗi, Reorder, Khuyến mãi, Đăng ký NV, Courier, Drone |
| [03-LUONG-VAN-HANH.md](03-LUONG-VAN-HANH.md) | Flow 12–17: Manager, Staff, Maintenance, Technician, Admin, Thông báo |
| [04-DANH-GIA-GAP-VA-CAI-TIEN.md](04-DANH-GIA-GAP-VA-CAI-TIEN.md) | Đánh giá: luồng/chức năng/role còn thiếu, gap nghiệp vụ, đề xuất cải tiến |

## Cách dùng

1. Đọc **01** trước để chuẩn bị tài khoản + hiểu trạng thái.
2. Test lần lượt các flow trong **02** (khách hàng) rồi **03** (vận hành). Mỗi bước có checkbox `[ ]` để tick khi test xong.
3. Đối chiếu **04** để biết luồng nào chạy thật, luồng nào là demo/chưa có backend (tránh nghiệm thu nhầm).

## Mức độ sẵn sàng của các luồng (tóm tắt)

| Nhóm | Trạng thái |
|---|---|
| Đăng ký/Đăng nhập, Thuê tủ (RENTAL), Gửi hàng (SEND), Thanh toán/Ví, Ủy quyền, Báo lỗi↔Bảo trì, Reorder/Hủy, Khuyến mãi | ✅ Chạy thật end-to-end |
| Manager, Maintenance, Technician, Admin | ✅ Chạy thật |
| Staff | ⚠️ Read-only (chỉ xem) |
| Đăng ký Nhân viên/Courier | ⚠️ Nộp hồ sơ được; **thiếu màn duyệt trên Admin mobile** |
| Courier delivery (giao hàng) | ⚠️ UI có, **backend chưa có** (Gap G6) — không chạy end-to-end |
| Drone delivery (khách đặt) | ⚠️ **Demo cục bộ**, không có backend |
| Drone fleet / Mission Planner / Flight Data | ✅ Fleet có backend (pin nhập tay); Mission Planner + Flight Data là công cụ cục bộ/MAVLink |

> Chi tiết & lý do: xem [04-DANH-GIA-GAP-VA-CAI-TIEN.md](04-DANH-GIA-GAP-VA-CAI-TIEN.md).
