# Chính sách bảo mật — Lock.R  (Smart Locker)

**Ngày hiệu lực:** 18/06/2026

Smart Locker ("chúng tôi") vận hành ứng dụng di động Lock.R (gói ứng dụng: `com.laundrylocker.mobile`, "Ứng dụng"). Chính sách này giải thích chúng tôi thu thập, sử dụng, chia sẻ và bảo vệ thông tin của bạn như thế nào khi bạn sử dụng Ứng dụng.

## 1. Thông tin chúng tôi thu thập

### 1.1 Thông tin bạn cung cấp trực tiếp
- **Thông tin tài khoản:** họ tên, email hoặc số điện thoại, mật khẩu (được mã hóa), vai trò sử dụng (khách hàng/quản lý/bảo trì/admin).
- **Thông tin đơn hàng:** lịch sử thuê tủ, gửi/nhận hàng, mã PIN và mã QR mở tủ, trạng thái đơn.
- **Hình ảnh:** ảnh chụp từ camera hoặc chọn từ thư viện (ví dụ: ảnh xác nhận tình trạng đồ giặt, ảnh báo cáo sự cố/bảo trì, ảnh đại diện).
- **Nội dung bạn gửi:** báo cáo sự cố, phản hồi, tin nhắn hỗ trợ.

### 1.2 Thông tin thu thập tự động
- **Vị trí (GPS):** dùng để tìm tủ locker gần bạn nhất (chỉ khi bạn cấp quyền vị trí).
- **Thông tin thiết bị:** model máy, hệ điều hành, định danh thiết bị, ngôn ngữ.
- **Token thông báo đẩy (push notification):** qua Firebase Cloud Messaging, để gửi thông báo trạng thái đơn hàng/tủ locker.
- **Dữ liệu sử dụng:** lượt đăng nhập, thao tác trong app, log lỗi kỹ thuật.

### 1.3 Thông tin từ bên thứ ba
- Nếu bạn đăng nhập bằng **Google Sign-In**, chúng tôi nhận tên, email và ảnh đại diện theo phạm vi bạn cho phép.
- Khi thanh toán, bạn được **chuyển hướng đến cổng thanh toán của bên thứ ba** (ví dụ VNPay/Momo/ZaloPay hoặc cổng tương đương) thông qua trình duyệt trong ứng dụng. **Chúng tôi không thu thập hoặc lưu trữ số thẻ, mã CVV hay thông tin tài khoản ngân hàng** — toàn bộ giao dịch thanh toán do cổng thanh toán bên thứ ba xử lý theo chính sách bảo mật riêng của họ. Chúng tôi chỉ nhận lại trạng thái giao dịch (thành công/thất bại) và mã tham chiếu đơn hàng.

## 2. Quyền truy cập thiết bị (permissions)

| Quyền | Mục đích |
|---|---|
| Camera | Quét mã QR để mở tủ, chụp ảnh xác nhận/báo cáo |
| Vị trí | Tìm tủ locker gần bạn |
| Bộ nhớ/Thư viện ảnh | Chọn ảnh tải lên cho đơn hàng/báo cáo |
| Thông báo | Gửi thông báo trạng thái đơn hàng, tủ locker |
| Internet | Kết nối với hệ thống backend để xử lý đơn hàng, thanh toán, realtime cập nhật trạng thái tủ |

Bạn có thể từ chối hoặc thu hồi các quyền này bất kỳ lúc nào trong cài đặt hệ điều hành, tuy nhiên một số chức năng (ví dụ quét QR mở tủ) sẽ không hoạt động nếu thiếu quyền tương ứng.

## 3. Mục đích sử dụng thông tin

Chúng tôi sử dụng thông tin thu thập để:
- Tạo và quản lý tài khoản, xác thực đăng nhập.
- Xử lý đơn thuê tủ, gửi/nhận hàng và mở tủ locker bằng mã PIN/QR.
- Gửi thông báo về trạng thái đơn hàng, sự cố, bảo trì.
- Hỗ trợ khách hàng và xử lý báo cáo sự cố.
- Cải thiện chất lượng dịch vụ, phát hiện và khắc phục lỗi kỹ thuật.
- Tuân thủ nghĩa vụ pháp lý khi có yêu cầu từ cơ quan nhà nước có thẩm quyền.

Chúng tôi **không** sử dụng dữ liệu của bạn cho mục đích quảng cáo nhắm đối tượng (targeted advertising) hay bán dữ liệu cho bên thứ ba.

## 4. Chia sẻ thông tin với bên thứ ba

Chúng tôi chia sẻ thông tin trong các trường hợp sau:
- **Firebase (Google):** lưu trữ, xác thực, gửi thông báo đẩy (Firebase Cloud Messaging), phân tích lỗi.
- **Cổng thanh toán bên thứ ba:** xử lý giao dịch thanh toán (không bao gồm dữ liệu tài chính chi tiết — xem mục 1.3).
- **Đối tác vận hành tủ locker (nếu có):** để xác nhận và xử lý đơn hàng vật lý.
- **Cơ quan pháp luật:** khi được yêu cầu hợp pháp theo quy định pháp luật Việt Nam.

Chúng tôi không bán hoặc cho thuê thông tin cá nhân của bạn cho bên thứ ba vì mục đích thương mại.

## 5. Lưu trữ và bảo mật dữ liệu

- Mật khẩu được mã hóa (hashing) trước khi lưu trữ; token đăng nhập được lưu an toàn trên thiết bị qua cơ chế lưu trữ bảo mật (secure storage).
- Dữ liệu được truyền tải qua kết nối HTTPS.
- Chúng tôi lưu trữ dữ liệu trong thời gian cần thiết để cung cấp dịch vụ hoặc theo yêu cầu pháp lý, sau đó sẽ xóa hoặc ẩn danh hóa khi không còn cần thiết.

## 6. Quyền của bạn

Bạn có quyền:
- Truy cập, chỉnh sửa thông tin tài khoản của mình trong ứng dụng.
- Yêu cầu xóa tài khoản và dữ liệu cá nhân liên quan.
- Thu hồi các quyền truy cập thiết bị (camera, vị trí, v.v.) bất kỳ lúc nào.
- Yêu cầu một bản sao dữ liệu cá nhân mà chúng tôi đang lưu trữ.

Để thực hiện các quyền trên, vui lòng liên hệ qua email ở mục 8.

## 7. Trẻ em

Ứng dụng không hướng đến người dùng dưới 13 tuổi. Chúng tôi không cố ý thu thập thông tin cá nhân từ trẻ em dưới 13 tuổi. Nếu phát hiện trường hợp này, chúng tôi sẽ xóa thông tin đó khỏi hệ thống.

## 8. Liên hệ

Nếu có câu hỏi về chính sách bảo mật này hoặc muốn thực hiện quyền dữ liệu cá nhân, vui lòng liên hệ:

**Email:** insvie.vi@gmail.com

## 9. Thay đổi chính sách

Chúng tôi có thể cập nhật chính sách này theo thời gian. Phiên bản mới sẽ được công bố tại cùng địa chỉ này kèm ngày hiệu lực mới. Việc bạn tiếp tục sử dụng Ứng dụng sau khi thay đổi có hiệu lực đồng nghĩa với việc bạn chấp nhận chính sách đã cập nhật.
