import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _progressAnimation;

  bool _isInitialized = false;
  String _initializationStatus = 'Poytug GTK yuklanmoqda...';
  bool _hasError = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation controller
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Progress animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start logo animation
    _logoAnimationController.forward();
  }

  Future<void> _startInitialization() async {
    try {
      // Start progress animation
      _progressAnimationController.forward();

      // Update status and perform initialization tasks
      await _performInitializationTasks();

      if (!_hasError) {
        _setState('Tayyor!');
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToNextScreen();
      }
    } catch (e) {
      _handleInitializationError();
    }
  }

  Future<void> _performInitializationTasks() async {
    final tasks = [
      {
        'status': 'Foydalanuvchi ma\'lumotlari tekshirilmoqda...',
        'duration': 800,
      },
      {'status': 'Mahsulot katalogi yuklanmoqda...', 'duration': 600},
      {'status': 'Yetkazib berish hududlari yangilanmoqda...', 'duration': 700},
      {'status': 'Sozlamalar tayyorlanmoqda...', 'duration': 500},
    ];

    for (int i = 0; i < tasks.length; i++) {
      if (_hasError) break;

      _setState(tasks[i]['status'] as String);

      // Simulate network timeout for demonstration
      if (_retryCount == 0 && i == 1) {
        await Future.delayed(
          Duration(milliseconds: (tasks[i]['duration'] as int)),
        );
        // Simulate occasional network delay
        if (DateTime.now().millisecond % 7 == 0) {
          throw Exception('Network timeout');
        }
      } else {
        await Future.delayed(
          Duration(milliseconds: (tasks[i]['duration'] as int)),
        );
      }
    }
  }

  void _setState(String status) {
    if (mounted) {
      setState(() {
        _initializationStatus = status;
      });
    }
  }

  void _handleInitializationError() {
    if (mounted) {
      setState(() {
        _hasError = true;
        _initializationStatus = 'Xatolik yuz berdi. Qayta urinish...';
      });
    }

    // Auto retry after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _retryCount < _maxRetries) {
        _retryInitialization();
      } else if (mounted) {
        setState(() {
          _initializationStatus =
              'Internetni tekshiring va qayta urinib ko\'ring';
        });
      }
    });
  }

  void _retryInitialization() {
    if (mounted) {
      setState(() {
        _retryCount++;
        _hasError = false;
        _initializationStatus = 'Qayta urinilmoqda...';
      });

      // Reset and restart progress animation
      _progressAnimationController.reset();
      _startInitialization();
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Check authentication status and navigate accordingly
    final bool isAuthenticated = _checkAuthenticationStatus();
    final bool isFirstTime = _checkFirstTimeUser();

    // Always go to home; registration will be required lazily when ordering
    String targetRoute = '/home-dashboard';

    // Smooth fade transition
    Navigator.of(context).pushReplacementNamed(targetRoute);
  }

  bool _checkAuthenticationStatus() {
    // Simulate checking stored authentication token
    // In real implementation, check SharedPreferences or secure storage
    return false; // For demo, always return false
  }

  bool _checkFirstTimeUser() {
    // Simulate checking if user has opened app before
    // In real implementation, check SharedPreferences
    return true; // For demo, always return true
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
              AppTheme.lightTheme.colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Status bar spacing
              SizedBox(height: 8.h),

              // Logo section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Opacity(
                          opacity: _logoOpacityAnimation.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Company Logo
                              Container(
                                width: 25.w,
                                height: 25.w,
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  borderRadius: BorderRadius.circular(4.w),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.w),
                                    child: Image.asset(
                                      'assets/images/lpg_logo.png',
                                      width: 25.w,
                                      height: 25.w,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback to original icon if image fails to load
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconWidget(
                                              iconName: 'local_gas_station',
                                              color: AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .primary,
                                              size: 8.w,
                                            ),
                                            SizedBox(height: 1.h),
                                            Text(
                                              'GTK',
                                              style: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color: AppTheme
                                                        .lightTheme
                                                        .colorScheme
                                                        .primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.sp,
                                                  ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 3.h),

                              // Company Name
                              Text(
                                'Poytug GTK',
                                style: AppTheme
                                    .lightTheme
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.sp,
                                    ),
                              ),

                              SizedBox(height: 1.h),

                              // Tagline
                              Text(
                                'Ishonchli gaz yetkazib berish xizmati',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.9),
                                      fontSize: 12.sp,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        _initializationStatus,
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary
                                  .withValues(alpha: 0.8),
                              fontSize: 11.sp,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Progress indicator
                    if (!_hasError) ...[
                      Container(
                        width: 60.w,
                        height: 0.5.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.onPrimary
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(1.h),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 60.w * _progressAnimation.value,
                                height: 0.5.h,
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  borderRadius: BorderRadius.circular(1.h),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      // Error state - retry button
                      if (_retryCount >= _maxRetries)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _retryCount = 0;
                              _hasError = false;
                            });
                            _progressAnimationController.reset();
                            _startInitialization();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.lightTheme.colorScheme.onPrimary,
                            foregroundColor:
                                AppTheme.lightTheme.colorScheme.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                          ),
                          child: Text(
                            'Qayta urinish',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              // Bottom spacing
              SizedBox(height: 4.h),

              // Version info
              Text(
                'Versiya 1.0.0',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary.withValues(
                    alpha: 0.6,
                  ),
                  fontSize: 9.sp,
                ),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
