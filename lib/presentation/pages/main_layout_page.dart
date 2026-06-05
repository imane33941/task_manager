import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/presentation/widgets/task_dialog.dart';

import '../../application/theme_provider.dart';
import '../router/app_router.gr.dart';

@RoutePage()
class MainLayoutPage extends ConsumerWidget {
  const MainLayoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsRouter(
      routes: const [
        ProjectsRoute(),
        TodayRoute(),
        WeekRoute(),
        SettingsRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyD, control: true): () {
              ref.read(themeModeProvider.notifier).toggle();
            },
            const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
              showTaskDialog(context, ref);
            },
            const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
              tabsRouter.setActiveIndex(1); // index 1 = Aujourd'hui
            },
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
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
            ),
          ),
        );
      },
    );
  }
}
