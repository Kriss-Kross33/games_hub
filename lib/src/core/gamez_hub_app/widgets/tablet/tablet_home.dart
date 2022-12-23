import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamez_hub/src/core/constants/app_color.dart';
import 'package:gamez_hub/src/core/gamez_hub_app/cubit/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:gamez_hub/src/core/gamez_hub_app/gamez_hub_app.dart';
import 'package:gamez_hub/src/features/home/presentation/pages/home_screen.dart';

class TabletHome extends StatefulWidget {
  const TabletHome({Key? key}) : super(key: key);

  @override
  _TabletHomeState createState() => _TabletHomeState();
}

class _TabletHomeState extends State<TabletHome> {
  late BottomNavCubit _bottomNavCubit;

  @override
  void initState() {
    super.initState();
    _bottomNavCubit = new BottomNavCubit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BottomNavCubit>(
      create: (context) => _bottomNavCubit,
      child: BlocBuilder<BottomNavCubit, BottomNavState>(
          builder: (context, state) {
        return Scaffold(
          bottomNavigationBar: FractionallySizedBox(
            widthFactor: 0.6,
            // heightFactor: 0.06,
            child: BottomNavyBar(
              backgroundColor: Theme.of(context).primaryColor,
              onItemSelected: _onItemSelected,
              selectedIndex: state.index,
              items: <BottomNavyBarItem>[
                BottomNavyBarItem(
                  title: Text(''),
                  icon: Icon(Icons.home),
                  activeColor: AppColor.darkSecondaryColor,
                  inactiveColor: AppColor.buttonDisabledColor,
                ),
                BottomNavyBarItem(
                  title: Text(''),
                  icon: Icon(Icons.chat),
                  activeColor: AppColor.darkSecondaryColor,
                  inactiveColor: AppColor.buttonDisabledColor,
                ),
                BottomNavyBarItem(
                  title: Text(''),
                  icon: Icon(Icons.notifications),
                  activeColor: AppColor.darkSecondaryColor,
                  inactiveColor: AppColor.buttonDisabledColor,
                ),
                BottomNavyBarItem(
                  title: Text(''),
                  icon: Icon(Icons.settings),
                  activeColor: AppColor.darkSecondaryColor,
                  inactiveColor: AppColor.buttonDisabledColor,
                ),
              ],
            ),
          ),
          body: IndexedStack(
            index: state.index,
            children: <Widget>[
              HomeScreen(),
              Home2(),
              Home3(),
              Home4(),
            ],
          ),
          //),
        );
      }),
    );
  }

  void _onItemSelected(int index) {
    _bottomNavCubit.onItemSelected(index);
  }
}
