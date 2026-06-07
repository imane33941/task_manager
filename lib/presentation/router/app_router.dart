import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: MainLayoutRoute.page,
          children: [
            AutoRoute(
                path: 'dashboard', page: DashboardRoute.page, initial: true),
            AutoRoute(path: 'all', page: AllTasksRoute.page),
            AutoRoute(path: 'projects', page: ProjectsRoute.page),
            AutoRoute(path: 'today', page: TodayRoute.page),
            AutoRoute(path: 'week', page: WeekRoute.page),
            AutoRoute(path: 'settings', page: SettingsRoute.page),
          ],
        ),
      ];
}
