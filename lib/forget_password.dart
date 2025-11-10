import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkfitness/providers/auth_provider.dart';
import 'package:rkfitness/widgets/loading_overlay.dart';
import 'package:rkfitness/widgets/connection_status.dart';
import 'package:rkfitness/widgets/error_message.dart';
import 'package:rkfitness/utils/responsive.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

// ForgetPasswordScreen is a StatelessWidget that handles the static UI of the screen.
class _ForgetpasswordState extends State<Forgetpassword> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _resetPassword(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    try {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        throw Exception('Please enter your email address');
      }

      await authProvider.resetPassword(email);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Password reset instructions have been sent to your email'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _resetPassword(context),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return LoadingOverlay(
      isLoading: authProvider.isLoading,
      message: 'Sending reset instructions...',
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Forget Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getProportionateScreenWidth(context, 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: const Color(0xFF1A1A1A),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.getProportionateScreenWidth(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.getProportionateScreenHeight(context, 20)),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.getProportionateScreenWidth(context, 16),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: Responsive.getProportionateScreenWidth(context, 14),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.surface),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.error),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.error),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.getProportionateScreenHeight(context, 20)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getProportionateScreenWidth(context, 50),
                          vertical: Responsive.getProportionateScreenHeight(context, 15),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _resetPassword(context),
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: Responsive.getProportionateScreenWidth(context, 18),
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter your email address',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        debugPrint('Submit button pressed!');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password reset link sent to your email (simulated).')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
                onRetry: () => _resetPassword(context),
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
}