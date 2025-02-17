import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/presentation/pages/home_page.dart';
part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page),
      ];
}
