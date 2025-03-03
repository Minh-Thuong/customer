import 'package:flutter/material.dart';

class InforPersonScreen extends StatelessWidget {
  const InforPersonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text('Thông tin tài khoản'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hình đại diện
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  "https://cdn-media.sforum.vn/storage/app/media/anh-dep-110.jpg"),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 20),
            // Tên và SĐT
            Text(
              "Huỳnh Minh Thường",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "0338216870",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            // Giới tính
            Row(
              children: [
                const Text("Giới tính: ", style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Row(
                      children: [
                        const Text("Nam"),
                        Radio(value: 1, groupValue: 1, onChanged: (value) {}),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Nữ"),
                        Radio(value: 2, groupValue: 1, onChanged: (value) {}),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Ngày sinh
            Row(
              children: const [
                Text("Ngày sinh: ", style: TextStyle(fontSize: 16)),
                Text("03/03/2025",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),
            // Thay đổi mật khẩu
            TextButton(
              onPressed: () {},
              child: const Text(
                "Thay đổi mật khẩu",
                style: TextStyle(color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),
            // Nút Cập nhật và Xóa tài khoản
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 80.0, right: 80.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("CẬP NHẬT",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 80.0, right: 80.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("XÓA TÀI KHOẢN",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
