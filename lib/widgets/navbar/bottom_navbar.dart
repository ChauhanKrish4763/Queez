import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quiz_app/screens/create_page.dart'; // Import your create page here
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/page_transition.dart';
import 'package:quiz_app/widgets/navbar/create_button.dart';
import 'package:quiz_app/widgets/navbar/navbar_shape.dart';

class BottomNavbarController extends StatefulWidget {
  const BottomNavbarController({super.key});

  @override
  State<BottomNavbarController> createState() => _BottomNavbarControllerState();
}

class _BottomNavbarControllerState extends State<BottomNavbarController> {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  // Add CreatePage as index 2
  final List<Widget> _pages = const [
    Center(key: ValueKey("Home"), child: Text("Home")),
    Center(key: ValueKey("Library"), child: Text("Library")),
    CreatePage(key: ValueKey("Create")),  
    Center(key: ValueKey("Profile"), child: Text("Profile")),
    Center(key: ValueKey("Settings"), child: Text("Settings")),
  ];

  late FloatingActionButtonLocation _fabLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double offset = MediaQuery.of(context).size.height * 0.015;
    _fabLocation = CreateButtonLocation(offset: offset);
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransition(
        isForward: _selectedIndex > _previousIndex,
        index: _selectedIndex,
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: CreateButton(
        onPressed: () {
          print('FAB pressed');
          if (_selectedIndex != 2) {
            setState(() {
              _previousIndex = _selectedIndex;
              _selectedIndex = 2;
            });
          }
        },
      ),
      floatingActionButtonLocation: _fabLocation,
      bottomNavigationBar: _BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}

class _BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavbar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.65),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, -4),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.15), width: 0.8),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            shape: NavbarShape(),
            notchMargin: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _navIcon(Icons.dashboard_rounded, 0, 'Home'),
                  _navIcon(Icons.menu_book_rounded, 1, 'Library'),
                  const SizedBox(width: 40), // FAB space
                  _navIcon(Icons.person_rounded, 3, 'Profile'),
                  _navIcon(Icons.settings_rounded, 4, 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index, String tooltip) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (!isActive) onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppColors.accentBright.withOpacity(0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: isActive ? 1.0 : 0.9, end: isActive ? 1.25 : 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Tooltip(
                message: tooltip,
                child: Icon(
                  icon,
                  size: 28,
                  color:
                      isActive
                          ? AppColors.accentBright
                          : AppColors.iconInactive,
                  shadows:
                      isActive
                          ? [
                            const Shadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ]
                          : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
