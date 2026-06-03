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
                path: 'projects', page: ProjectsRoute.page, initial: true),
            AutoRoute(path: 'today', page: TodayRoute.page),
            AutoRoute(path: 'week', page: WeekRoute.page),
            AutoRoute(path: 'settings', page: SettingsRoute.page),
          ],
        ),
      ];
}
