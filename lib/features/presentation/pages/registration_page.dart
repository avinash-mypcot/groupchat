import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat/injection_container.dart';
import 'package:intl/intl.dart';
import 'package:group_chat/features/data/models/user_entity.dart';
import 'package:group_chat/features/presentation/cubit/auth/auth_cubit.dart';
import 'package:group_chat/features/presentation/cubit/credential/credential_cubit.dart';
import 'package:group_chat/features/presentation/widgets/common.dart';
import 'package:group_chat/features/presentation/widgets/textfield_container.dart';
import '../../../core/routes/page_const.dart';
import '../widgets/theme/style.dart';
import 'home_page.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Controllers
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _examTypeController = TextEditingController();
  TextEditingController _passwordAgainController = TextEditingController();
  TextEditingController _numberController = TextEditingController();

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  int _selectGender = -1;
  // int _selectExamType = -1;
  bool _isShowPassword = true;

  File? _image;
  String? _profileUrl;

  // Define darker color scheme variables
  Color? darkGreen; // Dark green
  final Color darkBackground =
      Color(0xFF121212); // Dark background (almost black)
  final Color darkGrey = Color(0xFF424242); // Dark grey for containers
  final Color darkText = Colors.black; // White text for contrast
  final Color darkDivider = Colors.grey; // Divider color
  final Color selectionColor =
      Colors.deepOrange; // Color for selection indicators

  @override
  void dispose() {
    _examTypeController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _passwordAgainController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;
    darkGreen = colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldState,
      body: BlocConsumer<CredentialCubit, CredentialState>(
        listener: (context, credentialState) {
          if (credentialState is CredentialSuccess) {
            BlocProvider.of<AuthCubit>(context).loggedIn();
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomePage(uid: authState.uid)));
                  return HomePage(
                    uid: authState.uid,
                  );
                } else {
                  return _bodyWidget();
                }
              },
            );
          }
          if (credentialState is CredentialFailure) {
            snackBarNetwork(msg: "Wrong email, please check", context: context);
          }
        },
        builder: (context, credentialState) {
          if (credentialState is CredentialLoading) {
            return Scaffold(
              backgroundColor: darkBackground,
              body: loadingIndicatorProgressBar(),
            );
          }

          return _bodyWidget();
        },
      ),
    );
  }

  Widget _bodyWidget() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 35),
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                'Registration',
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    color: primaryColor),
              ),
            ),
            SizedBox(height: 10),
            Divider(thickness: 1, color: darkDivider),
            SizedBox(height: 10),
            SizedBox(height: 17),
            TextFieldContainer(
              controller: _usernameController,
              keyboardType: TextInputType.text,
              hintText: 'Username',
              prefixIcon: Icons.person,
              // If needed, update TextFieldContainer to support dark colors.
            ),
            SizedBox(height: 10),
            TextFieldContainer(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'Email',
              prefixIcon: Icons.mail,
            ),
            SizedBox(height: 17),
            Divider(
                thickness: 2, indent: 120, endIndent: 120, color: darkDivider),
            SizedBox(height: 17),
            Container(
              height: 44,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: darkGrey.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: TextField(
                style: TextStyle(color: darkText),
                obscureText: _isShowPassword,
                controller: _passwordController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: darkText),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: darkText.withOpacity(0.7)),
                    border: InputBorder.none,
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isShowPassword = !_isShowPassword;
                          });
                        },
                        child: Icon(
                            _isShowPassword
                                ? Icons.remove_red_eye_outlined
                                : Icons.remove_red_eye,
                            color: darkText))),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 44,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: darkGrey.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: TextField(
                style: TextStyle(color: darkText),
                obscureText: _isShowPassword,
                controller: _passwordAgainController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: darkText),
                    hintText: 'Password (Again)',
                    hintStyle: TextStyle(color: darkText.withOpacity(0.7)),
                    border: InputBorder.none,
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isShowPassword = !_isShowPassword;
                          });
                        },
                        child: Icon(
                            _isShowPassword
                                ? Icons.remove_red_eye_outlined
                                : Icons.remove_red_eye,
                            color: darkText))),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _modalBottomSheetDate,
              child: Container(
                height: 45,
                padding: EdgeInsets.only(left: 15),
                decoration: BoxDecoration(
                    color: darkGrey.withOpacity(0.2),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: AbsorbPointer(
                  child: TextField(
                    style: TextStyle(color: darkText),
                    controller: _dobController,
                    decoration: InputDecoration(
                      hintText: 'Date of birth',
                      hintStyle: TextStyle(color: darkText.withOpacity(0.7)),
                      suffixIcon: Icon(Icons.keyboard_arrow_down_sharp,
                          color: darkText),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _genderModalBottomSheetMenu,
              child: Container(
                height: 45,
                padding: EdgeInsets.only(left: 15),
                decoration: BoxDecoration(
                    color: darkGrey.withOpacity(0.2),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: AbsorbPointer(
                  child: TextField(
                    style: TextStyle(color: darkText),
                    controller: _genderController,
                    decoration: InputDecoration(
                      hintText: 'Gender',
                      hintStyle: TextStyle(color: darkText.withOpacity(0.7)),
                      suffixIcon: Icon(Icons.keyboard_arrow_down_sharp,
                          color: darkText),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            InkWell(
              onTap: () {
                _submitSignUp();
              },
              child: Container(
                alignment: Alignment.center,
                height: 44,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: primaryColor,
                ),
                child: Text(
                  'Register',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Do you have already an account?',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: darkGrey),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, PageConst.loginPage, (route) => false);
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _genderModalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        backgroundColor: textIconColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        builder: (builder) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                decoration: BoxDecoration(
                    color: textIconColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.close, color: darkText)),
                          Text(
                            'Gender',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: darkText),
                          ),
                          // An empty widget to balance the layout
                          SizedBox(width: 24),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(thickness: 1, color: darkDivider),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectGender = 0;
                          _genderController.value =
                              TextEditingValue(text: "Woman");
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Woman',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: darkText,
                                )),
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                color: _selectGender == 0
                                    ? selectionColor
                                    : Colors.transparent,
                                border: Border.all(color: darkText),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Divider(thickness: 1, color: darkDivider),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectGender = 1;
                          _genderController.value =
                              TextEditingValue(text: "Man");
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Man',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: darkText,
                                )),
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                color: _selectGender == 1
                                    ? selectionColor
                                    : Colors.transparent,
                                border: Border.all(color: darkText),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Divider(thickness: 1, color: darkDivider),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectGender = 2;
                          _genderController.value =
                              TextEditingValue(text: "I don't want to specify");
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('I don\'t want to specify',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: darkText,
                                )),
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                color: _selectGender == 2
                                    ? selectionColor
                                    : Colors.transparent,
                                border: Border.all(color: darkText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(thickness: 1, color: darkDivider),
                    SizedBox(height: 18),
                  ],
                ),
              );
            },
          );
        });
  }

  void _modalBottomSheetDate() {
    showModalBottomSheet(
        context: context,
        backgroundColor: textIconColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        builder: (builder) {
          return Container(
              height: 300.0,
              decoration: BoxDecoration(
                  color: textIconColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.close, color: darkText)),
                        Text(
                          'Date of birth',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: darkText),
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.done, color: darkText)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: CupertinoDatePicker(
                      use24hFormat: false,
                      mode: CupertinoDatePickerMode.date,
                      maximumDate: DateTime(DateTime.now().year + 1, 1, 1),
                      minimumDate: DateTime(1950, 1, 1),
                      onDateTimeChanged: (dateTime) {
                        print(dateTime);
                        setState(() {
                          _dobController.value = TextEditingValue(
                              text: DateFormat.yMMMMEEEEd().format(dateTime));
                        });
                      },
                    ),
                  ),
                ],
              ));
        });
  }

  _submitSignUp() async {
    if (_usernameController.text.isEmpty) {
      toast('Enter your username');
      return;
    }
    if (_emailController.text.isEmpty) {
      toast('Enter your email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      toast('Enter your password');
      return;
    }
    if (_passwordAgainController.text.isEmpty) {
      toast('Enter your password again');
      return;
    }

    if (_passwordController.text != _passwordAgainController.text) {
      toast("Both passwords must be the same");
      return;
    }
    final token = await FirebaseMessaging.instance.getToken() ?? '';
    BlocProvider.of<CredentialCubit>(context).signUpSubmit(
      user: UserEntity(
        fcmToken: token,
        email: _emailController.text,
        phoneNumber: _numberController.text,
        name: _usernameController.text,
        profileUrl: _profileUrl ?? '',
        gender: _genderController.text,
        dob: _dobController.text,
        password: _passwordController.text,
        isOnline: false,
        status: "Hi! There, I'm using this app",
      ),
    );
  }
}
