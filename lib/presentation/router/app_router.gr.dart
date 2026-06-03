// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:task_manager/presentation/pages/main_layout_page.dart' as _i1;
import 'package:task_manager/presentation/pages/projects_page.dart' as _i2;
import 'package:task_manager/presentation/pages/settings_page.dart' as _i3;
import 'package:task_manager/presentation/pages/today_page.dart' as _i4;
import 'package:task_manager/presentation/pages/week_page.dart' as _i5;

/// generated route for
/// [_i1.MainLayoutPage]
class MainLayoutRoute extends _i6.PageRouteInfo<void> {
  const MainLayoutRoute({List<_i6.PageRouteInfo>? children})
    : super(MainLayoutRoute.name, initialChildren: children);

  static const String name = 'MainLayoutRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.MainLayoutPage();
    },
  );
}

/// generated route for
/// [_i2.ProjectsPage]
class ProjectsRoute extends _i6.PageRouteInfo<void> {
  const ProjectsRoute({List<_i6.PageRouteInfo>? children})
    : super(ProjectsRoute.name, initialChildren: children);

  static const String name = 'ProjectsRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.ProjectsPage();
    },
  );
}

/// generated route for
/// [_i3.SettingsPage]
class SettingsRoute extends _i6.PageRouteInfo<void> {
  const SettingsRoute({List<_i6.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i3.SettingsPage();
    },
  );
}

/// generated route for
/// [_i4.TodayPage]
class TodayRoute extends _i6.PageRouteInfo<void> {
  const TodayRoute({List<_i6.PageRouteInfo>? children})
    : super(TodayRoute.name, initialChildren: children);

  static const String name = 'TodayRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.TodayPage();
    },
  );
}

/// generated route for
/// [_i5.WeekPage]
class WeekRoute extends _i6.PageRouteInfo<void> {
  const WeekRoute({List<_i6.PageRouteInfo>? children})
    : super(WeekRoute.name, initialChildren: children);

  static const String name = 'WeekRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.WeekPage();
    },
  );
}
