import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ADDED
import 'package:provider/provider.dart';
import 'package:rkfitness/providers/auth_provider.dart';
import 'package:rkfitness/widgets/loading_overlay.dart';
import 'package:rkfitness/widgets/connection_status.dart';
import 'package:rkfitness/widgets/error_message.dart';
// REMOVED: import 'package:rkfitness/utils/responsive.dart';

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
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              color: const Color(0xFF1A1A1A),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.sp,
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.surface),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.error),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.error),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 50.w,
                          vertical: 15.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: () => _resetPassword(context),
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // NOTE: There were two identical blocks for email and button below. I've simplified and made the second button responsive too.
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
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
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 5,
                        textStyle: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
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