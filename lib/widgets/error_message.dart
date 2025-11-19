import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ADDED

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  const ErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
         color: theme.colorScheme.error.withAlpha(26), // 0.1 * 255 = 26
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
          color: theme.colorScheme.error.withAlpha(77), // 0.3 * 255 = 77
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 16.w,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontSize: 12.sp,
                ),
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(width: 8.w),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  minimumSize: Size(0, 28.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: TextStyle(fontSize: 14.sp),
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 48.w,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
                fontSize: 16.sp,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: 20.w),
                label: Text('Try Again', style: TextStyle(fontSize: 16.sp)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}