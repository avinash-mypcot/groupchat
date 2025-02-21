import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat/features/presentation/cubit/auth/auth_cubit.dart';
import 'package:group_chat/features/presentation/cubit/group/group_cubit.dart';
import 'package:group_chat/features/presentation/cubit/user/user_cubit.dart';
import 'package:group_chat/features/presentation/pages/all_users_page.dart';
import 'package:group_chat/features/presentation/pages/groups_page.dart';
import 'package:group_chat/features/presentation/widgets/customTabBar.dart';
import 'package:group_chat/features/presentation/widgets/theme/style.dart';
import '../../../core/constants/app_const.dart';
import '../../../core/services/network/bloc/network_bloc.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  final String uid;

  const HomePage({Key? key, required this.uid}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchTextController = TextEditingController();
  PageController _pageController = PageController(initialPage: 0);

  List<Widget> get pages => [
        GroupsPage(
          uid: widget.uid,
          query: _searchTextController.text,
        ),
        AllUsersPage(
          uid: widget.uid,
          query: _searchTextController.text,
        ),
        // ProfilePage(
        //   uid: widget.uid,
        // )
      ];

  int _currentPageIndex = 0;

  bool _isSearch = false;

  @override
  void dispose() {
    _searchTextController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<NetworkBloc>().add(NetworkObserve());

    BlocProvider.of<UserCubit>(context).getUsers();
    BlocProvider.of<GroupCubit>(context).getGroups(widget.uid);
    _searchTextController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: _isSearch == false ? primaryColor : Colors.transparent,
        title: _isSearch == false
            ? Text("${AppConst.appName}")
            : Container(
                height: 0.0,
                width: 0.0,
              ),
        actions: _isSearch == false
            ? [
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              BlocProvider.of<AuthCubit>(context).loggedOut();
                            },
                            child: Text("logout")),
                        enabled: true,
                      ),
                    ];
                  },
                ),
              ]
            : [],
      ),
      body: Container(
        child: Column(
          children: [
            _isSearch == false
                ? CustomTabBar(
                    index: _currentPageIndex,
                    tabClickListener: (index) {
                      print(index);
                      _currentPageIndex = index;
                      _pageController.jumpToPage(index);
                    },
                  )
                : Container(
                    width: 0.0,
                    height: 0.0,
                  ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (_, index) {
                  return pages[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
