import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat/features/presentation/cubit/auth/auth_cubit.dart';
import 'package:group_chat/features/presentation/cubit/credential/credential_cubit.dart';
import 'package:group_chat/features/presentation/widgets/common.dart';
import 'package:group_chat/features/presentation/widgets/theme/style.dart';
import '../../../core/routes/page_const.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isShowPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<CredentialCubit, CredentialState>(
        listener: (context, credentialState) {
          if (credentialState is CredentialSuccess) {
            BlocProvider.of<AuthCubit>(context).loggedIn();
          } else if (credentialState is CredentialFailure) {
            snackBarNetwork(msg: "Wrong email, please check", context: context);
          }
        },
        builder: (context, credentialState) {
          if (credentialState is CredentialLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (credentialState is CredentialSuccess) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  return HomePage(uid: authState.uid);
                } else {
                  return _bodyWidget(colorScheme);
                }
              },
            );
          }
          return _bodyWidget(colorScheme);
        },
      ),
    );
  }

  Widget _bodyWidget(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 32),
      child: Column(
        children: <Widget>[
          SizedBox(height: 50),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
          SizedBox(height: 40),
          _buildTextField(_emailController, "Email", Icons.email, colorScheme),
          SizedBox(height: 20),
          _buildTextField(
              _passwordController, "Password", Icons.lock, colorScheme,
              isPassword: true),
          SizedBox(height: 50),
          InkWell(
            onTap: _submitLogin,
            child: Container(
              alignment: Alignment.center,
              height: 44,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textIconColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Don't have an account?",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface)),
              SizedBox(width: 5),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, PageConst.registrationPage);
                },
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      IconData icon, ColorScheme colorScheme,
      {bool isPassword = false}) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF424242).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isShowPassword : false,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 13),
          prefixIcon: Icon(icon, color: colorScheme.onSurface),
          hintText: hint,
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      _isShowPassword ? Icons.visibility_off : Icons.visibility,
                      color: colorScheme.onSurface),
                  onPressed: () {
                    setState(() {
                      _isShowPassword = !_isShowPassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  void _submitLogin() {
    if (_emailController.text.isEmpty) {
      toast('Enter your email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      toast('Enter your password');
      return;
    }
    BlocProvider.of<CredentialCubit>(context).signInSubmit(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }
}
