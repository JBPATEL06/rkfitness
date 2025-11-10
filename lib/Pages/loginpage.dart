import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkfitness/AdminMaster/admin_Dashboard.dart';
import 'package:rkfitness/forget_password.dart';
import 'package:rkfitness/Pages/user_dashboard.dart';
import 'package:rkfitness/providers/auth_provider.dart';
import 'package:rkfitness/utils/responsive.dart';
import 'package:rkfitness/widgets/loading_overlay.dart';
import 'package:rkfitness/widgets/connection_status.dart';
import 'package:rkfitness/widgets/error_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    // Deprecated: user provisioning is now handled in AuthProvider.
    // Removed to reduce duplicate provisioning logic.
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
                height: Responsive.screenHeight(context),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/login_background.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.getProportionateScreenWidth(context, 20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: Responsive.getProportionateScreenHeight(context, 100)),
                        Text(
                          "RKU Fitness",
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.getProportionateScreenWidth(context, 36),
                          ),
                        ),
                        SizedBox(height: Responsive.getProportionateScreenHeight(context, 50)),
                        _buildDarkTextField(_emailController, "Email", Icons.email),
                        SizedBox(height: Responsive.getProportionateScreenHeight(context, 20)),
                        _buildDarkTextField(_passwordController, "Password", Icons.lock, true),
                        SizedBox(height: Responsive.getProportionateScreenHeight(context, 20)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Responsive.getProportionateScreenWidth(context, 12)),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.getProportionateScreenWidth(context, 50),
                              vertical: Responsive.getProportionateScreenHeight(context, 15),
                            ),
                          ),
                          onPressed: () => _login(context),
                          child: Text(
                            "Login",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontSize: Responsive.getProportionateScreenWidth(context, 18),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.getProportionateScreenHeight(context, 50)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Responsive.getProportionateScreenWidth(context, 12)),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.getProportionateScreenWidth(context, 50),
                              vertical: Responsive.getProportionateScreenHeight(context, 15),
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
                              fontSize: Responsive.getProportionateScreenWidth(context, 18),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.getProportionateScreenHeight(context, 30)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (authProvider.error != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
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
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.getProportionateScreenWidth(context, 15),
          vertical: Responsive.getProportionateScreenHeight(context, 5),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.white),
            hintText: labelText == "Email" ? "example@gmail.com" : null,
            hintStyle: TextStyle(color: Colors.white54, fontSize: Responsive.getProportionateScreenWidth(context, 14)),
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.white, fontSize: Responsive.getProportionateScreenWidth(context, 16)),
            border: InputBorder.none,
            fillColor: Colors.transparent,
          ),
          style: TextStyle(color: Colors.white, fontSize: Responsive.getProportionateScreenWidth(context, 16)),
        ),
      ),
    );
  }
}