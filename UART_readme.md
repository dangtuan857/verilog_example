<font size="15"> Bộ UART</font> 

[MỤC LỤC]()
- [1. Giới thiệu](#1-giới-thiệu)
- [2. Hệ thống nhận](#2-hệ-thống-nhận)
  - [2.1. Quy trình lấy mẫu quá mức](#21-quy-trình-lấy-mẫu-quá-mức)
  - [2.2. Bộ tạo tốc độ truyền](#22-bộ-tạo-tốc-độ-truyền)
  - [2.3. Máy thu UART](#23-máy-thu-uart)
  - [2.4. Mạch giao tiếp](#24-mạch-giao-tiếp)
- [3. HỆ THỐNG TRUYỀN UART](#3-hệ-thống-truyền-uart)
- [4. TỔNG THỂ HỆ THỐNG UART](#4-tổng-thể-hệ-thống-uart)
- [5. Testbench](#5-testbench)
- [6. Tài liệu tham khảo](#6-tài-liệu-tham-khảo)


## 1. Giới thiệu 

![ảnh minh họa giao tiếp UART](https://i.imgur.com/v8Twp6C.jpg)

Một giao thức truyền và nhận không đồng bộ (UART) là một mạch mà gửi song song dữ liệu thông qua một đường nối tiếp. Một UART bao gồm một máy phát và một máy thu. Máy phát về cơ bản là một thanh ghi dịch chuyển tải dữ liệu song song và sau đó dịch chuyển nó ra từng bit với một tốc độ cụ thể.Mặt khác, bên nhận thay đổi dữ liệu từng bit một và sau đó tập hợp lại dữ liệu. Các đường truyền nối tiếp có giá trị là 1 khi nó không hoạt động. Quá trình truyền bắt đầu bằng một bit bắt đầu( **start**) là 0, tiếp theo bởi các bit dữ liệu(**data**) và một bit chẵn lẻ tùy chọn(có hoặc không có bit này) , và kết thúc bằng các bit dừng(**stop**) là 1. Số bit dữ liệu có thể là *6*, *7* hoặc *8*. Bit chẵn lẻ tùy chọn được sử dụng để phát hiện lỗi. Bit chẵn lẻ bằng 1 nếu số bit 1 trong các bit data là lẻ và ngược lại, bằng 0 nếu tổng số bit 1 trong các bit data là chẵn. Số lượng các bit dừng có thể là 1, 1,5 

![C:\Users\dangt\OneDrive\Hình ảnh\line_transmision_uart](https://i.imgur.com/9LlVQiq.jpg)`
*Hình 1.1. Truyền 1 byte dữ liệu*


hoặc 2. Truyền với 8 bit dữ liệu, không có chẵn lẻ, và 1 bit dừng được thể hiện trong Hình 1.1. Ghi chú bit LSB của từ dữ liệu được truyền đầu tiên.Không có tín hiệu đồng hồ nào được chuyển tải qua đường nối tiếp. Trước khi quá trình truyền bắt đầu,người phát và người nhận phải thống nhất về các tham số, bao gồm tốc độ truyền (tức là số bit/giây), số lượng bit dữ liệu và bit dừng, và việc sử dụng bit chẵn lẻ. Tốc độ baud thường được sử dụng là 2400, 4800, 9600 và 19.200 baud. *Trong project này tôi thiết kế tùy chỉnh cho UART với tốc độ truyền 19.200, 8 bit dữ liệu, 1 điểm dừng bit và không có bit chẵn lẻ*

## 2. Hệ thống nhận

Vì không có tín hiệu đồng hồ nào được truyền từ tín hiệu đã truyền, bộ thu có thể lấy các bit dữ liệu chỉ bằng cách sử dụng các tham số định trước. Tôi sử dụng *lấy mẫu quá mức* (**oversampling**) để ước tính các điểm giữa của các bit đã truyền và sau đó truy xuất chúng tại các điểm này cho phù hợp.

###  2.1. Quy trình lấy mẫu quá mức

Tốc độ lấy mẫu được sử dụng phổ biến nhất là 16 lần tốc độ truyền, có nghĩa là mỗi bit nối tiếp được lấy mẫu 16 lần. Giả sử rằng giao tiếp sử dụng N bit dữ liệu và M dừng lại một chút. Sơ đồ lấy mẫu quá mức hoạt động như sau:

1. Chờ cho đến khi tín hiệu đến trở thành 0, đầu của bit bắt đầu, rồi bắt đầu bộ đếm đánh dấu lấy mẫu.
2. Khi bộ đếm đến 7, tín hiệu đến đạt điểm giữa của bit bắt đầu. Xóa bộ đếm về 0 và lặp lại.
3. Khi bộ đếm đạt đến 15, tín hiệu trên đường truyền truyền thêm được khoảng thời gian tương đương 1 bit và đạt đến giữa bit dữ liệu đầu tiên. Lấy giá trị của nó, chuyển nó vào một thanh ghi và khởi động lại biến đếm.
4. Lặp lại bước 3, N-1 lần nữa để lấy các bit dữ liệu còn lại.
5. Nếu sử dụng bit chẵn lẻ tùy chọn, hãy lặp lại bước 3 một lần để lấy bit chẵn lẻ.
6. Lặp lại bước 3 hf lần nữa để thu được các bit dừng.

Sơ đồ oversampling về cơ bản thực hiện chức năng của một tín hiệu đồng hồ. Thay vì sử dụng sườn dương của đồng hồ để cho biết khi nào tín hiệu đầu vào là hợp lệ, nó sử dụng dấu tích lấy mẫu để ước tính điểm giữa của mỗi bit. Trong khi người nhận không có thông tin về chính xác thời gian bắt đầu của bit bắt đầu, ước tính có thể bị sai lệch nhiều nhất là $1/16$. Các bit dữ liệu tiếp theo truy xuất ít nhất cũng bị sai lệch $1/16$ từ điểm giữa. Bởi vì lấy mẫu quá mức,tốc độ truyền có thể chỉ là một phần nhỏ của tốc độ đồng hồ hệ thống, và do đó, sơ đồ này không thích hợp với tốc độ dữ liệu cao.

![block_diagram_tránmistor_UART](https://i.imgur.com/ebSrglz.jpg)

*Hình 1.2. Sơ đồ khối khái niệm của một hệ thống con nhận UART.*

Sơ đồ khối khái niệm của một hệ thống con nhận UART được thể hiện trong Hình 1.2.Nó bao gồm ba thành phần chính:

- Một UART nhận: mạch để có được những từ dữ liệu thông qua oversampling 
- Một bộ tạo tốc độ truyền: mạch để tạo ra các tick lấy mẫu
- Một mạch giao tiếptiếp: mạch cung cấp một bộ đệm và tình trạng giữa bộ thu UART và hệ thống sử dụng UART
  
### 2.2. Bộ tạo tốc độ truyền

Bộ tạo tốc độ truyền tạo ra tín hiệu lấy mẫu có tần số chính xác là 16 lần tốc độ truyền được chỉ định của UART. Để tránh tạo miền đồng hồ mới và vi phạm nguyên tắc thiết kế đồng bộ, tín hiệu lấy mẫu phải hoạt động cho phép trong tích tắc thay vì kéo dài như tín hiệu đồng hồ tới bộ thu UART, như đã thảo luận trong phần trước .Đối với tốc độ 19.200 baud, tốc độ lấy mẫu phải là 307.200 (tức là $19.200 * 16$) tích tắc trên mỗi giây. Vì tốc độ đồng hồ hệ thống là 50 MHz, bộ tạo tốc độ truyền cần một **mod-163** (Bộ đếm $((50*10^6)/307200)$) , trong đó chu kỳ của stick được lên mức 1 một lần bằng 163 chu kì đồng hồ KIT

### 2.3. Máy thu UART

Với sự hiểu biết về quy trình lấy mẫu quá mức, chúng ta có thể lấy biểu đồ ASMD theo đó, như trong Hình 8.3. Để phù hợp với sửa đổi trong tương lai, hai tham số được sử dụng trong mô tả. 

- DBIT cho biết tổng số bit dữ liệu và bit chẵn lẻ.
- SB-TICK cho biết số lượng tick cần thiết cho các bit dừng, là 16, 24,và 32 lần lượt cho 1, 1,5 và 2 bit dừng. 

DBIT, SB-TICK và được gán cho 8, 16, 0 trong thiết kế này.Có ba trạng thái chính: start, data và stop, đại diện cho việc xử lý bit start, data bit và stop bit. Các tín hiệu s-tick cho phép đánh dấu từ bộ tạo tốc độ truyền(**baund rate generator**) và có 16 s-tick trong một khoảng thời gian bit. Lưu ý rằng FSMD vẫn ở trạng thái như cũ trừ khi tín hiệu s-tick nhận giá trị 1. Có hai bộ đếm, được biểu diễn bằng các thanh ghi s và n. Thanh ghi s lưu số chu kì lấy mẫu quá mức, s đếm đến 7 ở trạng thái start , đến 15 trong data và để SB-TICK ở trạng thái stop. Thanh ghi n theo dõi số lượng bit dữ liệu nhận được ở trạng thái data. Các bit nhận được chuyển vào và tập hợp lại trong thanh ghi b


![ASMD_UART](https://i.imgur.com/jFztV9B.jpg)

*Hình1.3. Sơ đồ thuật toán máy thu UART*

Một tín hiệu trạng thái **rx-done-tick** được thêm vào, Nó được gán giá trị bằng 1 một lần sau mỗi lần truyền xong báo hiệu quá trình nhận hoàn tất. 

### 2.4. Mạch giao tiếp

Trong một hệ thống lớn, UART thường là một mạch ngoại vi để truyền dữ liệu nối tiếp. Các hệ thống chính kiểm tra trạng thái của nó theo chu kỳ để truy xuất và xử lý dữ liệu đã nhận. Các mạch giao tiếp của máy thu có hai chức năng.

- Cung cấp một cơ chế để báo hiệu tính sẵn  của một byte dữ liệu mới và để ngăn buyte đã nhận được truy xuất nhiều lần. 
- Cung cấp không gian đệm giữa máy thu và hệ thống chính.
  
  
Ở đó là ba lược đồ thường được sử dụng:

- Cờ FF
- Một cờ FF và một bộ đệm một từ
- Bộ đệm FIFO


Lưu ý rằng bộ thu UART xác nhận tín hiệu rx_done_stick một chu kỳ đồng hồ sau một dữ liệu byte được nhận.


![tránmistor_uart_usingFIFObuffer](https://i.imgur.com/Uq6PfTn.jpg)
*Hình 1.3.Máy thu UART sử dụng bộ đệm FIFO*


Trong thiết kế của mình, tôi sử dụng *bộ đệm FIFO* để thực hiện. Bộ đệm FIFO cung cấp nhiều không gian đệm hơn và giảm thiểu hơn nữa khả năng bị tràn dữ liệu. Tôi có thể điều chỉnh số vị trí đợi mong muốn trong FIFO để đáp ứng nhu cầu xử lý của hệ thống chính.Sơ đồ khối chi tiết được thể hiện trên Hình 1.3 .Tín hiệu *rx-done-tick* được kết nối với tín hiệu wr của FIFO. Khi một dữ liệu từ mới được nhận, tín hiệu wr được kích hoạt một chu kỳ đồng hồ và dữ liệu tương ứng được ghi vào FIFO. Hệ thống chính lấy dữ liệu từ chân đọc của FIFO. Sau khi lấy một từ, nó xác nhận tín hiệu *rd* của FIFO một chu kỳ đồng hồ để loại bỏ từ đó. Tín hiệu *empty* của FIFO có thể được sử dụng để cho biết bất kỳ từ dữ liệu nhận sẵn sàng đọc. Lỗi mất dữ liệu xảy ra khi một từ dữ liệu mới đến và FIFO đã đầy.

## 3. HỆ THỐNG TRUYỀN UART

Tổ chức của một hệ thống con truyền UART tương tự như tổ chức của hệ thống con nhận UART. Nó bao gồm 

- Một bộ phát UART
- Một bộ tạo tốc độ truyền 
- Mạch giao tiếp.

Mạch giao diện tương tự như mạch của hệ thống con nhận ngoại trừ hệ thống chính ghi bộ đệm FIFO và bộ phát UART đọc bộ đệm FIFO. Bộ phát UART về cơ bản là một thanh ghi dịch chuyển ra các bit dữ liệu tại một tỷ lệ. Tốc độ có thể được kiểm soát bằng tích tắc cho phép một chu kỳ đồng hồ được tạo ra bởi bộ tạo tốc độ baud (baud rate generator). Thay vì tạo ra một bộ đếm mới, máy phát UART thường chia sẻ bộ tạo tốc độ truyền với máy thu UART và sử dụng bộ đếm để theo dõi số lượng *stick*. Một bit được chuyển ra sau mỗi 16 lần kích hoạ tín hiệu *stick* .Biểu đồ ASMD của bộ phát UART tương tự như biểu đồ của bộ thu UART.Sau khi xác nhận tín hiệu bắt đầu tx, FSMD tải từ dữ liệu và sau đó dần dần tiến trình thông qua các trạng thái **start**, **data** và **stop** để phân tích các bit tương ứng. Nó báo hiệu hoàn thành bằng cách xác nhận tín hiệu tx-done-tick trong một chu kỳ đồng hồ.

![uart](https://i.imgur.com/lim1Q67.jpg)
*Hình 2.1 Sơ đồ bộ UART hoàn chỉnh*

## 4. TỔNG THỂ HỆ THỐNG UART

![uart_final](https://i.imgur.com/dv4hBDM.jpg)
*Hình 3.1. Sơ đồ bộ UART*

Hoàn thiện lõi UART bằng cách kết hợp các hệ thống con nhận và truyền, tôi có thể xây dựng Lõi UART. Sơ đồ mức cao nhất được thể hiện trong Hình 2.1. Sơ đồ khối có thể được mô tả bằng cách mô tả thành phần.

## 5. Testbench

Tôi viết 1 testbend đơn giản gồm 2 bộ UART được kết nối với nhau, gửi 1 từ data trên một UART và quan sát tín hiệu nhận được trên UART còn lại.

## 6. Tài liệu tham khảo
- *Sách FPGA Prototyping By Verilog Examples.*