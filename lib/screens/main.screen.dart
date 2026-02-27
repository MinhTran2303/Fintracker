import 'package:SpendingMonitor/bloc/cubit/app_cubit.dart';
import 'package:SpendingMonitor/screens/accounts/accounts.screen.dart';
import 'package:SpendingMonitor/screens/categories/categories.screen.dart';
import 'package:SpendingMonitor/screens/home/home.screen.dart';
import 'package:SpendingMonitor/screens/onboard/onboard_screen.dart';
import 'package:SpendingMonitor/screens/settings/settings.screen.dart';
import 'package:SpendingMonitor/l10n/app_text.dart';
import 'package:SpendingMonitor/widgets/app/app_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _controller = PageController(keepPage: true);
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        AppCubit cubit = context.read<AppCubit>();
        if (cubit.state.currency == null || cubit.state.username == null) {
          return OnboardScreen();
        }
        return Scaffold(
          body: PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomeScreen(),
              AccountsScreen(),
              CategoriesScreen(),
              SettingsScreen(),
            ],
            onPageChanged: (int index) {
              setState(() {
                _selected = index;
              });
            },
          ),
          bottomNavigationBar: AppBottomNavigation(
            selectedIndex: _selected,
            destinations: [
              NavigationDestination(icon: const Icon(Symbols.home, fill: 1), label: tr(context, 'Trang chủ', 'Home')),
              NavigationDestination(icon: const Icon(Symbols.wallet, fill: 1), label: tr(context, 'Tài khoản', 'Accounts')),
              NavigationDestination(icon: const Icon(Symbols.category, fill: 1), label: tr(context, 'Danh mục', 'Categories')),
              NavigationDestination(icon: const Icon(Symbols.settings, fill: 1), label: tr(context, 'Cài đặt', 'Settings')),
            ],
            onDestinationSelected: (int selected) {
              _controller.jumpToPage(selected);
            },
          ),
        );
      },
    );
  }
}
