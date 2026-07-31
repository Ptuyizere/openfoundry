import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/core/theme/colors.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/presentation/backer/browse_screen.dart';
import 'package:openfoundry/presentation/backer/my_funding_screen.dart';
import 'package:openfoundry/presentation/common/profile_screen.dart';
import 'package:openfoundry/presentation/entrepreneur/funders_screen.dart';
import 'package:openfoundry/presentation/entrepreneur/my_pitches_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.initialTab = 0});


  final int initialTab;


  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final role = user?.role ?? UserRole.backer;


    return _HomeShell(role: role, initialTab: initialTab);
  }
}


class _HomeShell extends StatefulWidget {
  const _HomeShell({required this.role, this.initialTab = 0});
  final UserRole role;
  final int initialTab;


  @override
  State<_HomeShell> createState() => _HomeShellState();
}


class _HomeShellState extends State<_HomeShell> {
  late int _index = widget.initialTab;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _tabs(widget.role),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.surfaceMuted,
        destinations: _destinations(widget.role),
      ),
    );
  }


  List<Widget> _tabs(UserRole role) {
    if (role == UserRole.entrepreneur) {
      return const [MyPitchesScreen(), FundersScreen(), ProfileScreen()];
    }
    return const [BrowseScreen(), MyFundingScreen(), ProfileScreen()];
  }


  List<NavigationDestination> _destinations(UserRole role) {
    if (role == UserRole.entrepreneur) {
      return const [
        NavigationDestination(
          icon: Icon(Icons.lightbulb_outline),
          selectedIcon: Icon(Icons.lightbulb),
          label: 'Pitches',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Funders',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
    return const [
      NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: 'Browse',
      ),
      NavigationDestination(
        icon: Icon(Icons.handshake_outlined),
        selectedIcon: Icon(Icons.handshake),
        label: 'My funding',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }
}
