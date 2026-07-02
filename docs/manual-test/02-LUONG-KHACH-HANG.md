# 02 — Luồng Khách hàng (Customer)

> Mỗi bước: **Role · Màn hình · Thao tác · Kết quả mong đợi · Bàn giao role kế tiếp**.
> Đọc [01-CHUAN-BI-VA-TAI-KHOAN.md](01-CHUAN-BI-VA-TAI-KHOAN.md) trước.

---

## FLOW 1 — Đăng ký & Đăng nhập

- [ ] **1.1** — Role: Khách vãng lai · Màn: **Đăng nhập/Đăng ký** · mở app → tab **Đăng ký** → nhập Họ tên, Email, SĐT, Mật khẩu (≥6 ký tự) → tick **Đồng ý điều khoản** → **Tạo tài khoản** · Kết quả: toast "Đăng ký thành công! Vui lòng đăng nhập.", tự về tab Đăng nhập với email điền sẵn. *(Backend ép role = CUSTOMER.)*
- [ ] **1.2** — Màn Đăng nhập · nhập email/SĐT + mật khẩu → **Đăng nhập** · Kết quả: vào Home khách, header "Hi <tên>", card **Số dư ví**.
- [ ] **1.3 (Google)** — nút **Google** → chọn tài khoản · Kết quả: đăng nhập/tạo CUSTOMER qua Firebase. *(Cần SHA-1 trong Firebase console.)*
- [ ] **1.4 (SĐT OTP)** — nút **SĐT** → nhập số (0xxx hoặc +84xxx) → **Gửi mã OTP** → nhập 6 số → **Xác nhận** · Kết quả: đăng nhập bằng Firebase Phone.
- [ ] **1.5 (Facebook)** — nút **Facebook** · Kết quả: chạy khi đã bật Facebook provider + key hash trong console; chưa cấu hình sẽ báo lỗi.
- [ ] **1.6 (Quên mật khẩu)** — bấm **Quên mật khẩu?** · Kết quả hiện tại: chỉ toast "Liên hệ hỗ trợ" (⚠️ chưa có luồng reset thật).

---

## FLOW 2 — Thuê tủ giữ đồ (RENTAL) — vòng đời đầy đủ

- [ ] **2.1** — Customer · Home → chip **Cửa hàng** (hoặc card "Các nơi đặt locker") → chọn 1 cửa hàng → trang **Tủ locker** · Kết quả: danh sách tủ, bấm tủ để bung sơ đồ ô.
- [ ] **2.2** — bung 1 tủ → chạm 1 **ô xanh (Trống)** loại thường/XL → sheet "Ô tủ trống" → **Thuê tủ** · Kết quả: mở màn **Thuê tủ giữ đồ** đã chọn sẵn tủ + loại ô.
- [ ] **2.3** — chọn **Loại ô** (thường 5.000đ/h · XL 10.000đ/h), chọn **số giờ** (chip 2/4/8/12/24 hoặc slider 1–72h), Ghi chú (tùy chọn), (tùy chọn) **Mã giảm giá** → **Thuê ngay** · Kết quả: tạo đơn RENTAL, hiện **PIN + QR** (dùng nhiều lần trong kỳ thuê), hạn thuê.
- [ ] **2.4** — **Tôi đã bỏ đồ — bắt đầu kỳ thuê** · Kết quả: đơn → **STORING**, banner "Kỳ thuê đang chạy".
- [ ] **2.5 (Thanh toán)** — về **Đơn tủ** → mở đơn → **Thanh toán <số tiền>** → chọn phương thức (xem Flow 4) · Kết quả: `paymentStatus = PAID`.
- [ ] **2.6 (Gia hạn)** — chi tiết đơn STORING → **Gia hạn thuê** → chọn thêm giờ → **Gia hạn** · Kết quả: hạn thuê dời ra, toast "Đã gia hạn N giờ".
- [ ] **2.7 (Kết thúc)** — **Kết thúc thuê & trả ô** · Kết quả: đơn **COMPLETED**, ô về AVAILABLE (có thể phát sinh phí quá giờ nếu trễ).
- [ ] **2.8 (Mở tủ thật)** — nếu có nút **Mở tủ**: gọi `POST /api/iot/unlock` → chỉ mở thật khi IoT simulator/hardware đang chạy.

---

## FLOW 3 — Gửi hàng C2C qua tủ (SEND) — 2 người, PIN 2 giai đoạn

**Người gửi (Sender = Customer A):**
- [ ] **3.1** — Home → Cửa hàng → tủ → ô trống → **Gửi hàng** (hoặc quick action Gửi hàng) · Kết quả: mở màn **Gửi hàng qua tủ** (stepper bước 1).
- [ ] **3.2** — chọn Kích thước hàng (Nhỏ/Vừa/Lớn), nhập **SĐT người nhận** (≥9 số), Tên (tùy chọn), Ghi chú, (tùy chọn) Mã giảm giá → **Tạo đơn & lấy PIN bỏ hàng** · Kết quả: đơn SEND `INITIALIZED`, hiện **PIN bỏ hàng** + QR, phí gửi (mặc định 15.000đ).
- [ ] **3.3** — tới tủ, dùng PIN mở ô, bỏ hàng → **Tôi đã bỏ hàng vào ô** · Kết quả: đơn → **STORING**; PIN **xoay vòng** thành PIN nhận hàng; nếu SĐT người nhận đã có tài khoản → gán `receiverId` + **gửi thông báo** cho người nhận; nếu chưa → sender tự chuyển PIN.
- [ ] **3.4 (Thanh toán)** — như Flow 4 (nếu muốn trả phí gửi).

➡️ **Bàn giao Người nhận (Receiver = Customer B):**
- [ ] **3.5** — Màn **Thông báo** (chuông) → thấy noti "PIN nhận hàng"; hoặc nhận PIN từ Sender · dùng **PIN/QR nhận hàng** mở ô, lấy hàng.
- [ ] **3.6** — Màn **Đơn tủ** của B → mở đơn → **Tôi đã lấy đồ — hoàn tất** · Kết quả: đơn **COMPLETED**, ô về AVAILABLE.

---

## FLOW 4 — Thanh toán đa hình thức + Nạp ví

- [ ] **4.1 (Nạp ví)** — Home → card **Số dư ví** / **Nạp tiền** → màn **Nạp tiền** → nhập số tiền (≥1.000đ) → VNPay → WebView → thanh toán sandbox · Kết quả: quay lại app, **số dư ví tăng** (idempotent theo txnRef).
- [ ] **4.2 (Ví)** — mở đơn UNPAID → **Thanh toán** → **Ví của tôi** (chỉ chọn được khi đủ số dư) · Kết quả: trừ ví tức thì, đơn → **PAID**.
- [ ] **4.3 (VNPay/MoMo)** — chọn **VNPay**/**MoMo** → WebView cổng → thanh toán → callback · Kết quả: đơn → PAID. *(MoMo cần backend cấu hình `MOMO_*`; chưa cấu hình báo `MOMO_NOT_CONFIGURED`.)*
- [ ] **4.4 (Tiền mặt)** — **Tiền mặt** · Kết quả: đơn đánh dấu PAID (trả tại quầy).
- [ ] **4.5 (Lịch sử)** — Profile → Quản lý → **Giao dịch** · Kết quả: danh sách giao dịch ví.

---

## FLOW 5 — Ủy quyền người khác nhận hộ (Delegation)

- [ ] **5.1** — Chủ đơn (Customer A) · **Đơn tủ → chi tiết đơn** (STORING/RETURNED) → **Ủy quyền người khác lấy hộ** → nhập SĐT (+ tên) → **Ủy quyền** · Kết quả: PIN mới sinh và gửi cho người lấy hộ.
- [ ] **5.2** — Người được ủy quyền (Customer C) · **Profile → Đơn ủy quyền** (`/my-delegations`) hoặc màn **Mở ô được ủy quyền** · dùng PIN/access code mở ô.
- [ ] **5.3** — hoàn tất đơn như Flow 3.6.

---

## FLOW 6 — Báo lỗi ô tủ + Đánh giá (vòng Customer ↔ Maintenance)

- [ ] **6.1** — Customer · **Đơn tủ → chi tiết đơn** (ô còn gắn đơn) → **Báo ô lỗi** → mô tả → **Gửi báo lỗi** · Kết quả: ô → **FAULT**, tạo phiếu sự cố, toast có nút "Xem".
- [ ] **6.2** — **Profile → Báo cáo của tôi** (`/my-reports`) · Kết quả: thấy phiếu OPEN.

➡️ **Bàn giao Maintenance** (xem [03 – Flow 14.2](03-LUONG-VAN-HANH.md)). Sau khi KTV **claim** rồi **resolve**:
- [ ] **6.3** — Customer · **Thông báo** · Kết quả: nhận noti "đã nhận xử lý" / "đã sửa xong".
- [ ] **6.4** — **Báo cáo của tôi** → phiếu RESOLVED → **đánh giá 1–5 sao** + bình luận · Kết quả: lưu (ghi đè nếu đánh giá lại); vào điểm trung bình của KTV.

---

## FLOW 7 — Đặt lại đơn / Hủy đơn

- [ ] **7.1 (Reorder)** — Customer · **chi tiết đơn** COMPLETED/CANCELED → **Đặt lại đơn** · Kết quả: đơn mới cùng tham số, PIN/QR mới.
- [ ] **7.2 (Cancel)** — đơn **INITIALIZED** → **Hủy đơn** · Kết quả: đơn → CANCELED, ô release. *(Chỉ hủy khi INITIALIZED/RESERVED/WAITING.)*

---

## FLOW 8 — Khuyến mãi / Mã giảm giá

- [ ] **8.1** — Customer · Home → chip **Ưu đãi** (hoặc Flash Sale) → **Promotions** → mở khuyến mãi → **copy mã**.
- [ ] **8.2** — trong màn Thuê tủ/Gửi hàng → ô **Mã giảm giá** → dán mã → validate → giá tạm tính giảm.

---

## FLOW 9 — Đăng ký trở thành Nhân viên/Người giao hàng (self-service)

- [ ] **9.1** — Customer · **Profile → Quản lý → Đăng ký trở thành Nhân viên** → nhập Họ tên pháp lý, Biển số xe, Loại phương tiện, chụp/chọn **3 ảnh** (trước xe, sau xe, chân dung) → tick điều khoản → **Nộp hồ sơ** · Kết quả: hồ sơ **PENDING**, Profile hiện "Đang chờ duyệt hồ sơ...".

➡️ **Bàn giao Admin duyệt** (⚠️ Admin mobile **chưa có** màn duyệt — hiện duyệt qua Admin web/DB). Sau khi APPROVED (role COURIER):
- [ ] **9.2** — Customer (đã duyệt) · Profile → card **Chế độ người giao hàng** bật được → chuyển giao diện Courier (Flow 10).

---

## FLOW 10 — Chế độ Người giao hàng (Courier)

> ⚠️ Backend giao hàng qua courier (**PARCEL_RECEIVE / logistics dispatch**) **chưa có** (Gap G6). Các màn courier gọi endpoint legacy → **không chạy end-to-end**. Chỉ test UI/điều hướng.

- [ ] **10.1** — Courier · Profile → bật **Chế độ người giao hàng** → Home chuyển giao diện courier (banner, ví, "Đơn hoàn thành hôm nay").
- [ ] **10.2** — **Bắt đầu làm việc** → cấp quyền vị trí → Online → **Bản đồ theo dõi**.
- [ ] **10.3** — quick action **Lấy hàng (OTP)** → màn nhập OTP; **Giao hàng** → quét QR; **Hỗ trợ** → dialog.
- [ ] **10.4** — **Dừng làm việc** → confirm → offline.

---

## FLOW 11 — Giao hàng bằng Drone (⚠️ DEMO cục bộ)

> ⚠️ Demo client-side: đơn drone lưu trong bộ nhớ app (`DroneDeliveryStore`), phí "Miễn phí (Demo)", **không tạo đơn backend**, tracking mô phỏng.

- [ ] **11.1** — Customer · Cửa hàng → tủ → **chạm ô màu tím (Drone)** → sheet **Đặt ô Drone** → mô tả hàng (tùy chọn) → **Xác nhận đặt ô Drone** · Kết quả: mở màn **Theo dõi drone** (mô phỏng).
- [ ] **11.2** — quan sát các mốc tracking mô phỏng tới "đã giao".
