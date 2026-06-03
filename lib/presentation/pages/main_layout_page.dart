import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../router/app_router.gr.dart';

@RoutePage()
class MainLayoutPage extends StatelessWidget {
  const MainLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        ProjectsRoute(),
        TodayRoute(),
        WeekRoute(),
        SettingsRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: tabsRouter.activeIndex,
                onDestinationSelected: tabsRouter.setActiveIndex,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.folder),
                    label: Text('Projets'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.today),
                    label: Text('Aujourd\'hui'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.date_range),
                    label: Text('Cette semaine'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('Paramètres'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
