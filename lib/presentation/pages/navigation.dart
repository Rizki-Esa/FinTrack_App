import 'package:flutter/material.dart';
import 'package:frontend_fintrack/presentation/pages/setting/setting_profile_screen.dart';
import 'package:frontend_fintrack/presentation/widgets/button/language_button.dart';
import 'package:provider/provider.dart';
import '../../responsive_helper.dart';
import '../controllers/auth_controller.dart';
import '../controllers/financial_controller.dart';
import '../controllers/setting_profile_controller.dart';
import '../widgets/pop_up/custom_dialog_button.dart';
import 'Dashboard/dashboard_screen.dart';
import 'authentikasi/auth_guard.dart';
import 'authentikasi/auth_screen.dart';
import 'financial/financial_screen.dart';
import 'history/history_screen.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

late AnimationController _pressController;

class _NavigationState extends State<Navigation> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _pages = [
    'Dashboard',
    'Financial',
    'History',
    'Settings',
  ];

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    // Load profile langsung di Navigation
    final ctrl = context.read<SettingProfileController>();
    final authCtrl = context.read<AuthController>();
    final userId = authCtrl.user?['id'] ?? 0;
    ctrl.loadProfile(userId);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final ctrl = context.watch<SettingProfileController>();

    return Theme(
      data: ctrl.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        key: _scaffoldKey,
        body: Row(
          children: [
            if (!responsive.isMobile)
              Container(
                width: responsive.value(mobile: 60, tablet: 80, desktop: 260),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: ctrl.isDarkMode
                        ? [Colors.grey[900]!, Colors.grey[850]!]
                        : [Colors.blue[900]!, Colors.blue[700]!],
                  ),
                ),
                child: _buildSideNavigation(responsive),
              ),
            Expanded(
              child: Column(
                children: [
                  _buildAppBar(responsive),
                  Expanded(
                    child: Scaffold(
                      backgroundColor: ctrl.isDarkMode ? Colors.grey[850] : Colors.grey[100],
                      body: SafeArea(
                        child: Padding(
                          padding: responsive.paddingSymmetric(
                            horizontalMobile: 12,
                            verticalMobile: 0,
                            horizontalTablet: 20,
                            verticalTablet: 8,
                            horizontalDesktop: 20,
                            verticalDesktop: 12,
                          ),
                          child: _buildPageContent(responsive),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: responsive.isMobile
            ? BottomNavigationBar(
          currentIndex: _selectedIndex.clamp(0, 3),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.attach_money), label: 'Financial'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        )
            : SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSideNavigation(Responsive responsive) {
    final ctrl = context.watch<SettingProfileController>();
    return Column(
      children: [
        SizedBox(height: responsive.size(mobile: 15, tablet: 20, desktop: 25)),
        Container(
          padding: responsive.padding(mobile: 5, tablet: 8, desktop: 10),
          child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: CircleAvatar(
                radius: responsive.value(mobile: 18, tablet: 25, desktop: 40),
                backgroundColor: Colors.blue,
                backgroundImage: ctrl.imageBytes != null
                    ? MemoryImage(ctrl.imageBytes!)
                    : null,
                child: ctrl.imageBytes == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              )
          ),
        ),
        if (responsive.isDesktop) ...[
          SizedBox(height: 5),
          Text(
            ctrl.name.isNotEmpty ? ctrl.name : 'User',
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.fontSize(mobile: 14, tablet: 16, desktop: 18),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        SizedBox(height: responsive.size(mobile: 10, tablet: 12, desktop: 15)),
        Expanded(
          child: ListView.builder(
            itemCount: _pages.length,
            itemBuilder: (context, index) => _buildNavItem(
              icon: _getIcon(index),
              label: _pages[index],
              isSelected: _selectedIndex == index,
              responsive: responsive,
              onTap: () => setState(() => _selectedIndex = index),
            ),
          ),
        ),
        Divider(color: Colors.white24),
        _buildNavItem(
          icon: Icons.logout,
          label: 'Logout',
          isSelected: false,
          responsive: responsive,
          onTap: () {

            CustomDialogButton.show(
              context: context,
              title: "Logout",
              message: "Are you sure want to logout?",
              confirmText: "Confirm",
              cancelText: "Cancel",
              isWarning: true,
              isDarkMode: ctrl.isDarkMode,

              onConfirm: () async {
                /// 🔐 Hapus token + reset auth state
                await context.read<AuthController>().logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthGuard()),
                        (route) => false,
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    required Responsive responsive,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: responsive.size(mobile: 4, tablet: 6, desktop: 8),
            horizontal: responsive.size(mobile: 8, tablet: 10, desktop: 12)),
        padding: EdgeInsets.symmetric(
            vertical: responsive.size(mobile: 8, tablet: 12, desktop: 16),
            horizontal: responsive.size(mobile: 8, tablet: 10, desktop: 12)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: responsive.size(mobile: 20, tablet: 22, desktop: 24)),
            if (responsive.isDesktop) ...[
              SizedBox(width: responsive.size(mobile: 5, tablet: 8, desktop: 10)),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.fontSize(mobile: 12, tablet: 14, desktop: 16),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Responsive responsive) {
    final ctrl = context.watch<SettingProfileController>();
    return Container(
      margin: responsive.isMobile
          ? const EdgeInsets.only(top: 20)
          : EdgeInsets.zero,
      height: responsive.size(mobile: 65, tablet: 80, desktop: 80),
      padding: responsive.paddingSymmetric(
        horizontalMobile: 12, verticalMobile: 6,
        horizontalTablet: 16, verticalTablet: 8,
        horizontalDesktop: 20, verticalDesktop: 10,
      ),
      decoration: BoxDecoration(
        color: ctrl.isDarkMode ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (responsive.isMobile)
            Container(
              padding: EdgeInsets.all(1),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
              child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: CircleAvatar(
                    radius: responsive.value(mobile: 18, tablet: 25, desktop: 40),
                    backgroundColor: Colors.blue,
                    backgroundImage: ctrl.imageBytes != null
                        ? MemoryImage(ctrl.imageBytes!)
                        : null,
                    child: ctrl.imageBytes == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  )
              ),
            ),
          SizedBox(width: responsive.size(mobile: 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    _pages[_selectedIndex],
                    style: TextStyle(
                        fontSize: responsive.fontSize(mobile: 20, tablet: 22, desktop: 24),
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    ctrl.name.isNotEmpty ? ctrl.name : 'User',
                    style: TextStyle(
                      fontSize: responsive.fontSize(mobile: 12, tablet: 13, desktop: 14),
                      color: Colors.grey[600],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!responsive.isMobile) ...[
            LanguageToggleButton(
              isEnglish: ctrl.isEnglish,
              onChanged: (value) => ctrl.setLanguage(value, 8),
            ),
            SizedBox(width: responsive.size(mobile: 12, tablet: 14, desktop: 16)),
          ],
          IconButton(
            onPressed: () => ctrl.setDarkMode(!ctrl.isDarkMode, 8),
            icon: Icon(ctrl.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
          SizedBox(width: responsive.size(mobile: 12, tablet: 14, desktop: 20)),
          if (responsive.isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  CustomDialogButton.show(
                    context: context,
                    title: "Logout",
                    message: "Are you sure want to logout?",
                    confirmText: "Confirm",
                    cancelText: "Cancel",
                    isWarning: true,
                    isDarkMode: ctrl.isDarkMode,
                    onConfirm: () async {
                      /// 🔐 Hapus token + reset auth state
                      await context.read<AuthController>().logout();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AuthGuard()),
                              (route) => false,
                        );
                      }
                    },
                  );
                },
                icon: const Icon(Icons.logout),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageContent(Responsive responsive) {
    final ctrl = context.watch<SettingProfileController>();
    final authCtrl = context.watch<AuthController>();
    final userId = authCtrl.user?['id'] ?? 0;
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          isDarkMode: ctrl.isDarkMode,
          isMobile: responsive.isMobile,
          isTablet: responsive.isTablet,
          isDesktop: responsive.isDesktop,
          onSeeAllActivities: () {
            setState(() {
              _selectedIndex = 1;
            });
          },
        );

      case 1:
        return FinancialScreen(
          isDarkMode: ctrl.isDarkMode,
          isMobile: responsive.isMobile,
          isTablet: responsive.isTablet,
          isDesktop: responsive.isDesktop,
          userId: userId,
        );

      case 2:
        return HistoryScreen(
          isDarkMode: ctrl.isDarkMode,
          isMobile: responsive.isMobile,
          isTablet: responsive.isTablet,
          isDesktop: responsive.isDesktop,
        );

      case 3:
        return SettingProfileScreen(
          userId: userId,
        );

      default:
        return _buildDefaultScreen(responsive);
    }
  }

  Widget _buildDefaultScreen(Responsive responsive) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction,
                size: responsive.size(mobile: 80, tablet: 90, desktop: 100),
                color: Theme.of(context).primaryColor),
            SizedBox(height: responsive.size(mobile: 15, tablet: 18, desktop: 20)),
            Text(
              'Page Under Construction',
              style: TextStyle(
                  fontSize: responsive.fontSize(mobile: 20, tablet: 22, desktop: 24),
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  IconData _getIcon(int index) {
    final icons = [
      Icons.dashboard,
      Icons.attach_money,
      Icons.history,
      Icons.settings,
    ];
    return icons[index];
  }
}