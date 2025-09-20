import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/app_export.dart';

class TermsCheckboxWidget extends StatefulWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const TermsCheckboxWidget({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  State<TermsCheckboxWidget> createState() => _TermsCheckboxWidgetState();
}

class _TermsCheckboxWidgetState extends State<TermsCheckboxWidget> {
  void _showTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsWebViewScreen(
          title: 'Foydalanish shartlari',
          url: 'https://example.com/terms',
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsWebViewScreen(
          title: 'Maxfiylik siyosati',
          url: 'https://example.com/privacy',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: widget.isChecked,
            onChanged: (value) => widget.onChanged(value ?? false),
            activeColor: AppTheme.lightTheme.colorScheme.primary,
            checkColor: AppTheme.lightTheme.colorScheme.onPrimary,
            side: BorderSide(
              color: widget.isChecked
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: RichText(
              text: TextSpan(
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Men '),
                  TextSpan(
                    text: 'foydalanish shartlari',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = _showTermsAndConditions,
                  ),
                  const TextSpan(text: ' va '),
                  TextSpan(
                    text: 'maxfiylik siyosati',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = _showPrivacyPolicy,
                  ),
                  const TextSpan(text: ' bilan tanishib chiqdim va roziman.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TermsWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const TermsWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<TermsWebViewScreen> createState() => _TermsWebViewScreenState();
}

class _TermsWebViewScreenState extends State<TermsWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xatolik',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Sahifani yuklashda xatolik yuz berdi. Internetga ulanishingizni tekshiring.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Qayta urinish',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Yopish',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: AppTheme.lightTheme.scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Yuklanmoqda...',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
