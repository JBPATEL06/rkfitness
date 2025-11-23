import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rkfitness/AdminMaster/admin_Dashboard.dart';
import 'package:rkfitness/forget_password.dart';
import 'package:rkfitness/Pages/user_dashboard.dart';
import 'package:rkfitness/providers/auth_provider.dart';
import 'package:rkfitness/widgets/loading_overlay.dart';
import 'package:rkfitness/widgets/connection_status.dart';
import 'package:rkfitness/widgets/error_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userTypeKey = 'userType';

  Future<void> _login(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    try {
      final userEmail = _emailController.text.trim();
      final password = _passwordController.text;

      await authProvider.login(userEmail, password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Login successful!"),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      final userType = authProvider.currentUser?.userType ?? 'user';
      // SAVE LOGIN STATE AND USER TYPE
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userTypeKey, userType);

      if (authProvider.currentUser?.userType == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserDashBoard()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _login(context),
          ),
        ),
      );
    }
  }

  Future<void> _createAndProvisionNewUser(String userEmail) async {
    return;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return LoadingOverlay(
      isLoading: authProvider.isLoading,
      message: 'Logging in...',
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            body: SingleChildScrollView(
              child: Container(
                // FIX: Use MediaQuery.of(context).size.height instead of 1.sh
                // This reliably sets the height without depending on the ScreenUtil context field that was causing the crash.
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/login_background.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 100.h),
                        Text(
                          "RKU Fitness",
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 36.sp,
                          ),
                        ),
                        SizedBox(height: 50.h),
                        _buildDarkTextField(_emailController, "Email", Icons.email),
                        SizedBox(height: 20.h),
                        _buildDarkTextField(_passwordController, "Password", Icons.lock, true),
                        SizedBox(height: 20.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 50.w,
                              vertical: 15.h,
                            ),
                          ),
                          onPressed: () => _login(context),
                          child: Text(
                            "Login",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 50.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 50.w,
                              vertical: 15.h,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Forgetpassword()),
                            );
                          },
                          child: Text(
                            "forget Password",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (authProvider.error != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16.h,
              left: 16.w,
              right: 16.w,
              child: ErrorMessage(
                message: authProvider.error!,
                compact: true,
                onRetry: () => _login(context),
              ),
            ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ConnectionStatus(),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkTextField(TextEditingController controller, String labelText, IconData icon, [bool obscureText = false]) {
    return Card(
      elevation: 4,
      color: Colors.white12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 5.h,
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.white),
            hintText: labelText == "Email" ? "example@gmail.com" : null,
            hintStyle: TextStyle(color: Colors.white54, fontSize: 14.sp),
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.white, fontSize: 16.sp),
            border: InputBorder.none,
            fillColor: Colors.transparent,
          ),
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ),
    );
  }
}