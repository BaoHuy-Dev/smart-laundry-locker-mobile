# Hướng dẫn sử dụng — Smart Laundry Locker (Gửi & Giữ đồ qua tủ)

> Tài liệu hướng dẫn cho người dùng cuối. Ảnh chụp thật từ ứng dụng chạy trên
> Android (emulator Pixel 4), kết nối backend + **IoT tủ khoá phản hồi thật**.
> Cập nhật: 2026-07-02.

Ứng dụng giúp bạn **gửi hàng cho người khác qua tủ khoá thông minh (SEND)** và
**thuê ô để giữ đồ theo giờ (RENTAL)**. Mỗi ô tủ mở bằng **mã PIN / mã QR**, và
bạn có thể bấm **"Mở tủ"** ngay trong app để tủ tự mở (không cần nhập tay tại tủ).

---

## 1. Trang chủ

Sau khi đăng nhập, bạn vào Trang chủ:

![Trang chủ](img/01-home.png)

- **Số dư ví** + nút **Nạp tiền** ở đầu trang.
- Hàng phím tắt: **Đơn hàng · Tủ · Cửa hàng · Thông báo · Ưu đãi**.
- **Các nơi đặt locker**: danh sách cửa hàng/điểm đặt tủ gần bạn.
- **Flash Sale**: mã giảm giá đang có (chạm để sao chép mã).
- Thanh điều hướng dưới cùng: **Trang chủ · Đơn · Quét mã · Tủ · Hồ sơ**.

> **Đăng nhập/Đăng ký:** ở màn hình đầu tiên, nhập **Email/SĐT + mật khẩu** rồi
> bấm **Đăng nhập**; hoặc chọn tab **Đăng ký** để tạo tài khoản mới; hoặc đăng
> nhập nhanh bằng **Google / Số điện thoại (OTP)**.

---

## 2. Gửi hàng qua tủ (SEND)

### Bước 1 — Chọn cửa hàng và xem ô trống

Trang chủ → **Cửa hàng** (hoặc chạm một điểm trong "Các nơi đặt locker") → chọn
tủ → app hiển thị **sơ đồ ô** của tủ đó. Ô **xanh = Trống**, xám = đang dùng,
vàng = đã đặt, đỏ = lỗi, tím = ô Drone.

![Sơ đồ ô tủ](img/02-so-do-o-tu.png)

### Bước 2 — Chọn ô trống và chọn dịch vụ

Chạm một **ô Trống** → hộp thoại hiện thông tin ô (kích cỡ, vị trí, trạng thái)
và hỏi bạn muốn làm gì:

![Chọn dịch vụ](img/03-chon-dich-vu.png)

- **Thuê tủ** — giữ đồ của bạn, tính tiền theo giờ.
- **Gửi hàng** — gửi cho người khác (chuyển C2C). Chọn mục này để tiếp tục.

### Bước 3 — Điền thông tin gửi hàng

![Form gửi hàng](img/04-form-gui-hang.png)

- Chọn **Kích thước hàng** (Nhỏ / Vừa / Lớn).
- Nhập **Số điện thoại người nhận** (bắt buộc) và **Tên người nhận** (tùy chọn).
- Nhập **Ghi chú** nếu cần (VD: hàng dễ vỡ).
- (Tùy chọn) nhập **Mã giảm giá**.
- Bấm **Tạo đơn & lấy PIN bỏ hàng**.

Sau khi tạo, đơn ở trạng thái **Khởi tạo** và phí gửi mặc định **15.000đ**.

### Bước 4 — Thanh toán (bắt buộc trước khi bỏ hàng)

> ⚠️ **Mới:** bạn phải **thanh toán trước khi bỏ hàng vào tủ**. Nếu bấm "Đã bỏ
> hàng" khi chưa trả tiền, hệ thống báo: *"Vui lòng thanh toán đơn trước khi bỏ
> hàng vào tủ."*

Mở chi tiết đơn → bấm **Thanh toán** → chọn phương thức:
**Ví của tôi / VNPay / MoMo / Tiền mặt**. Ví và Tiền mặt thanh toán tức thì;
VNPay/MoMo mở cổng thanh toán. Sau khi trả xong, đơn chuyển **Đã thanh toán**.

### Bước 5 — Xem đơn của bạn

Vào tab **Đơn** (dưới cùng) để xem tất cả đơn. Đơn vừa tạo hiển thị
**"Gửi hàng · Đang trong tủ · Tủ 2 · Ô 17 · 15.000đ"**:

![Danh sách đơn](img/05-danh-sach-don.png)

### Bước 6 — Mở tủ để bỏ hàng vào ô

Chạm đơn để mở chi tiết. Bạn thấy **mã QR** và **mã PIN** (ví dụ `4 8 0 0 8 7`),
cùng nút **Mở tủ**:

![Chi tiết đơn — PIN, QR, nút Mở tủ](img/06-chi-tiet-don-pin-qr-motu.png)

Có **2 cách mở ô**:
1. Tới tủ, **nhập PIN** hoặc **quét QR** tại màn hình tủ; **hoặc**
2. Bấm **Mở tủ** ngay trong app — ứng dụng gửi lệnh mở xuống tủ, tủ **tự mở cửa**.

Sau khi bấm **Mở tủ**, app xác nhận đã gửi lệnh và **cửa ô mở ra**:

![Kết quả mở tủ](img/07-ket-qua-mo-tu.png)

Bỏ hàng vào ô, đóng cửa, rồi bấm **"Tôi đã bỏ hàng vào ô"**. Hệ thống **sinh PIN
nhận hàng mới** và gửi cho người nhận.

---

## 3. Người nhận lấy hàng

- Người nhận nhận **thông báo + PIN/QR nhận hàng** (nếu đã có tài khoản), hoặc
  bạn tự chuyển mã PIN cho họ.
- Người nhận tới tủ, **nhập PIN / quét QR** (hoặc bấm **Mở tủ** trong app của họ)
  để mở ô, lấy hàng.
- Sau khi lấy, bấm **"Tôi đã lấy đồ — hoàn tất"**; đơn chuyển **Hoàn thành**, ô
  tủ được giải phóng.

---

## 4. Thuê ô giữ đồ (RENTAL) — tóm tắt

Tương tự Gửi hàng nhưng chọn **Thuê tủ** ở Bước 2:
1. Chọn **loại ô** (thường / vali XL) và **số giờ thuê**.
2. Bấm **Thuê ngay** → nhận **PIN dùng nhiều lần** trong suốt kỳ thuê.
3. Thanh toán → bấm **bắt đầu kỳ thuê** → dùng nút **Mở tủ** để mở ô bất cứ lúc nào.
4. Khi xong: **Gia hạn** thêm giờ, hoặc **Kết thúc thuê & trả ô**.

---

## 5. Ghi chú kỹ thuật — Chuỗi Mobile → Backend → IoT

Nút **"Mở tủ"** không chỉ hiển thị PIN mà thực sự điều khiển tủ khoá:

```
App (bấm "Mở tủ")
   → POST /api/iot/unlock  (lockerId, boxId, pinCode)
   → iot-service xác minh PIN, publish lệnh MQTT "OPEN" tới tủ
   → Tủ (cabinet) mở cửa và PHẢN HỒI kết quả về hệ thống
```

Nhật ký tủ khoá (cabinet) khi nhận lệnh mở từ thao tác trên app — **tủ phản hồi
thật** (không phải mô phỏng phía app):

```
[SIM] OPEN request: locker=2 box=17 commandId=108547b8-...
[SIM] OK -> cabinet/2/command/open/result:
      {"status":"SUCCESS","hwState":"OPENING","errorMessage":"Simulated: door opened"}
[SIM] HW state -> cabinet/2/locker/17/status: box=17 OPEN
```

Nghĩa là: khi bạn bấm **Mở tủ** trên điện thoại, backend gọi xuống tủ và **tủ trả
lời "đã mở cửa"** — đúng luồng vận hành thật của tủ khoá thông minh.

> Ảnh chụp trong tài liệu này được thực hiện trên môi trường chạy đầy đủ:
> ứng dụng mobile ↔ backend (Docker) ↔ tủ khoá IoT (qua MQTT).
