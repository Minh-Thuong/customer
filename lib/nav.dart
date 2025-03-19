import 'package:customer/screen/category/category_screen.dart';
import 'package:customer/screen/chats/chatpages_screen.dart';
import 'package:customer/screen/home/homescreen.dart';
import 'package:customer/screen/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> with RouteAware {
  int _selectedIndex = 0;
  final List<Widget> _widgetOpions = const <Widget>[
    Homescreen(),
    CategoryScreen(),
    ChatPages(),
    ProfileScreen(),
  ];

  // Tạo RouteObserver instance
  final RouteObserver<ModalRoute<void>> _routeObserver =
      RouteObserver<ModalRoute<void>>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đăng ký RouteAware với RouteObserver
    _routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Hủy đăng ký khi widget bị hủy
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOpions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: "Danh mục"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_sharp), label: "Trò chuyện"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hồ sơ"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white70,
      ),
    );
  }

  // Triển khai các phương thức RouteAware
  @override
  void didPush() {
    // Gọi khi tuyến đường hiện tại được đẩy lên ngăn xếp
    print('Nav: didPush');
  }

  @override
  void didPop() {
    // Gọi khi tuyến đường hiện tại bị bật ra khỏi ngăn xếp
    print('Nav: didPop');
  }

  @override
  void didPushNext() {
    // Gọi khi một tuyến đường mới được đẩy lên và tuyến đường hiện tại không còn hiển thị
    print('Nav: didPushNext');
  }

  @override
  void didPopNext() {
    // Gọi khi tuyến đường trên cùng bị bật ra và tuyến đường hiện tại trở lại hiển thị
    print('Nav: didPopNext');
  }
}
