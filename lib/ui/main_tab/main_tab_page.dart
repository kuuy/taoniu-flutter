import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/tables/tradingview_table_theme.dart';
import 'main_tab_controller.dart';
import '../home/home_page.dart';
import '../markets/markets_page.dart';
import '../plans/plans_page.dart';
import '../account/account_page.dart';

class MainTabPage extends GetView<MainTabController> {
  const MainTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomePage(),
          MarketsPage(),
          PlansPage(),
          AccountPage(),
        ],
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            color: TvTableTheme.tvHeaderBg,
            border: Border(
              top: BorderSide(
                color: TvTableTheme.tvBorderColor,
                width: 1.0,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            type: BottomNavigationBarType.fixed,
            backgroundColor: TvTableTheme.tvHeaderBg,
            elevation: 0,
            selectedItemColor: TvTableTheme.tvBlue,
            unselectedItemColor: TvTableTheme.tvTextSecondary,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3.0),
                  child: Icon(Icons.grid_view_outlined, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3.0),
                  child: Icon(Icons.grid_view, size: 22),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3.0),
                  child: Icon(Icons.show_chart_outlined, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3.0),
                  child: Icon(Icons.show_chart, size: 22),
                ),
                label: 'Markets',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3.0),
                  child: Icon(Icons.next_plan_outlined, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3.0),
                  child: Icon(Icons.next_plan, size: 22),
                ),
                label: 'Plans',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3.0),
                  child: Icon(Icons.person_outline, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3.0),
                  child: Icon(Icons.person, size: 22),
                ),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
