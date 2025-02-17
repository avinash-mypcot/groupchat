// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<HomeRouteArgs> {
  HomeRoute({Key? key, required String uid, List<PageRouteInfo>? children})
    : super(
        HomeRoute.name,
        args: HomeRouteArgs(key: key, uid: uid),
        initialChildren: children,
      );

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HomeRouteArgs>();
      return HomePage(key: args.key, uid: args.uid);
    },
  );
}

class HomeRouteArgs {
  const HomeRouteArgs({this.key, required this.uid});

  final Key? key;

  final String uid;

  @override
  String toString() {
    return 'HomeRouteArgs{key: $key, uid: $uid}';
  }
}
