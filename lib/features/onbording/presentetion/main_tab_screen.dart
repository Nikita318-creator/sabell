import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_sabel/core/di/injection_container.dart';
import 'package:flutter_sabel/features/catalog/data/repositories/server_product_repository.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_bloc.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_event.dart';
import 'package:flutter_sabel/features/catalog/presentation/catalog_screen.dart';
import 'package:flutter_sabel/features/home/presentation/home_screen.dart';
import 'package:flutter_sabel/features/search/presentation/search_screen.dart';
import 'package:flutter_sabel/features/settings/presentation/settings_screen.dart';

import 'package:flutter_sabel/features/onbording/logic/bloc/main_tab_bloc.dart';
import 'package:flutter_sabel/features/onbording/logic/bloc/main_tab_event.dart';
import 'package:flutter_sabel/features/onbording/logic/bloc/main_tab_state.dart';

class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    CatalogScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CartBloc(
            repository:
                sl<ServerProductRepository>(), // 👈 Пробросили репозиторий
          ),
        ),
        BlocProvider(create: (context) => MainTabBloc()),
      ],
      child: BlocBuilder<MainTabBloc, MainTabState>(
        builder: (context, state) {
          final tabBloc = context.read<MainTabBloc>();

          return CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              currentIndex: state.currentTabIndex,
              onTap: (index) {
                tabBloc.add(ChangeTabEvent(index));
              },
              activeColor: CupertinoColors.black,
              inactiveColor: CupertinoColors.systemGrey2,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.sparkles),
                  activeIcon: Icon(CupertinoIcons.sparkles),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.rectangle_grid_2x2),
                  activeIcon: Icon(CupertinoIcons.rectangle_grid_2x2_fill),
                  label: 'Catalog',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.search),
                  activeIcon: Icon(CupertinoIcons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.slider_horizontal_3),
                  activeIcon: Icon(CupertinoIcons.slider_horizontal_3),
                  label: 'Settings',
                ),
              ],
            ),
            tabBuilder: (context, index) {
              return CupertinoTabView(builder: (context) => _screens[index]);
            },
          );
        },
      ),
    );
  }
}
