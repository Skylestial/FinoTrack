import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app/app_bloc.dart';
import '../blocs/app/app_event.dart';
import '../blocs/app/app_state.dart';
import '../utils/formatters.dart';
import '../utils/theme_colors.dart';
import 'budget_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'spend_summary_screen.dart';
import 'transactions_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _screens = <Widget>[
    _SpendSummaryWrapper(),
    TransactionsScreen(),
    BudgetScreen(),
    InsightsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final brightness = Theme.of(context).brightness;
        return Scaffold(
          key: _scaffoldKey,
          drawer: _AppDrawer(
            onClose: () => _scaffoldKey.currentState?.closeDrawer(),
          ),
          body: _screens[state.selectedTab],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: ThemeColors.surfaceFor(brightness),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: state.selectedTab,
              onTap: (index) {
                context.read<AppBloc>().add(TabSelected(index));
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: ThemeColors.primary,
              unselectedItemColor: ThemeColors.textSecondaryFor(brightness),
              backgroundColor: ThemeColors.surfaceFor(brightness),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Transactions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet_rounded),
                  label: 'Budget',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.insights_outlined),
                  activeIcon: Icon(Icons.insights_rounded),
                  label: 'Insights',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Spend Summary Wrapper — exposes the scaffold key for drawer
// ---------------------------------------------------------------------------

class _SpendSummaryWrapper extends StatelessWidget {
  const _SpendSummaryWrapper();

  @override
  Widget build(BuildContext context) {
    return SpendSummaryScreen(
      onMenuPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );
  }
}

// ---------------------------------------------------------------------------
// App Drawer
// ---------------------------------------------------------------------------

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    const menuItems = [
      _DrawerItem(Icons.home_rounded, 'Dashboard', true),
      _DrawerItem(Icons.receipt_long_rounded, 'Transactions', false),
      _DrawerItem(Icons.account_balance_wallet_rounded, 'Budget', false),
      _DrawerItem(Icons.insights_rounded, 'Insights', false),
      _DrawerItem(Icons.auto_awesome_rounded, 'AI Assistant', false),
    ];

    const secondaryItems = [
      _DrawerItem(Icons.notifications_outlined, 'Notifications', false),
      _DrawerItem(Icons.settings_outlined, 'Settings', false),
      _DrawerItem(Icons.help_outline_rounded, 'Help & Support', false),
    ];

    return Drawer(
      backgroundColor: ThemeColors.surfaceFor(brightness),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Color(0xFF7C3AED), size: 30),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onClose,
                        child: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Ankit Sharma',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ankit.sharma@email.com',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  // Quick stats row
                  Row(
                    children: [
                      _QuickStat(
                        label: 'Spent',
                        value: formatCurrency(24680),
                        brightness: brightness,
                      ),
                      const SizedBox(width: 20),
                      _QuickStat(
                        label: 'Saved',
                        value: formatCurrency(20320),
                        brightness: brightness,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                children: [
                  ...menuItems.map((item) => _DrawerTile(item: item)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Divider(height: 1),
                  ),
                  ...secondaryItems.map((item) => _DrawerTile(item: item)),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: _DrawerTile(
                item: const _DrawerItem(
                  Icons.logout_rounded,
                  'Logout',
                  false,
                  isDestructive: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.brightness,
  });

  final String label;
  final String value;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _DrawerItem {
  const _DrawerItem(
    this.icon,
    this.label,
    this.isSelected, {
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDestructive;
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.item});

  final _DrawerItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.isDestructive
        ? Colors.red
        : item.isSelected
            ? ThemeColors.primary
            : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: item.isSelected
            ? ThemeColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(item.icon, color: color, size: 22),
        title: Text(
          item.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: item.isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
        ),
        trailing: item.isSelected
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: ThemeColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
