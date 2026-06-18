// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
import '../../../../di/injection_container.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _exitController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  void _initParticles(Size size) {
    if (_particles.isNotEmpty) return;
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _particles.add(_Particle(
        x: random.nextDouble() * size.width,
        y: random.nextDouble() * size.height,
        vx: (random.nextDouble() - 0.5) * 0.3,
        vy: -0.3 - (random.nextDouble() * 0.5),
        size: 2.0 + random.nextDouble() * 3.0,
        opacity: 0.1 + random.nextDouble() * 0.3,
      ));
    }
  }

  void _updateParticles(Size size) {
    for (var p in _particles) {
      p.y += p.vy;
      p.x += p.vx;

      if (p.y < -10) {
        p.y = size.height + 10;
        p.x = math.Random().nextDouble() * size.width;
      }
      if (p.x < -10) {
        p.x = size.width + 10;
      } else if (p.x > size.width + 10) {
        p.x = -10;
      }
    }
  }

  void _animateExitAndGo(String route) {
    _exitController.forward().then((_) {
      if (mounted) {
        context.go(route);
      }
    });
  }

  Widget _buildBlob({
    required double top,
    required double left,
    required double size,
    required Color color,
    required double pulseValue,
  }) {
    final scale = 1.0 + (pulseValue * 0.15);
    final opacity = 0.04 + (pulseValue * 0.04);

    return Positioned(
      top: top,
      left: left,
      width: size * scale,
      height: size * scale,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(opacity),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );
    final exitScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );

    return BlocProvider(
      create: (_) => sl<SplashBloc>()..add(CheckAppInitialization()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToOnboarding) {
            _animateExitAndGo('/onboarding');
          } else if (state is SplashNavigateToLogin) {
            _animateExitAndGo('/login');
          } else if (state is SplashNavigateToHome) {
            _animateExitAndGo('/home');
          } else if (state is SplashNavigateToAdminDashboard) {
            _animateExitAndGo('/admin/dashboard');
          } else if (state is SplashError) {
            context.showErrorToast(
              title: 'Initialization Error',
              message: state.message,
            );
            _animateExitAndGo('/login');
          }
        },
        child: AnimatedBuilder(
          animation: _exitController,
          builder: (context, child) {
            return FadeTransition(
              opacity: exitOpacity,
              child: ScaleTransition(
                scale: exitScale,
                child: child,
              ),
            );
          },
          child: Scaffold(
            body: Stack(
              children: [
                // 1. Premium dark gradient background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.splashBgStart,
                        AppColors.splashBgCenter,
                        AppColors.splashBgEnd,
                      ],
                    ),
                  ),
                ),

                // 2. Blurred background blobs (glowing circles)
                AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    final pulse = math.sin(_backgroundController.value * 2 * math.pi);
                    final pulseNormalized = (pulse + 1.0) / 2.0; // 0.0 to 1.0
                    return Stack(
                      children: [
                        _buildBlob(
                          top: -50,
                          left: -50,
                          size: 320,
                          color: AppColors.primary,
                          pulseValue: pulseNormalized,
                        ),
                        _buildBlob(
                          top: MediaQuery.of(context).size.height - 350,
                          left: MediaQuery.of(context).size.width - 280,
                          size: 350,
                          color: Colors.blueAccent,
                          pulseValue: 1.0 - pulseNormalized,
                        ),
                      ],
                    );
                  },
                ),

                // 3. Floating particles system
                LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    _initParticles(size);
                    return AnimatedBuilder(
                      animation: _backgroundController,
                      builder: (context, child) {
                        _updateParticles(size);
                        return CustomPaint(
                          painter: _ParticlesPainter(particles: _particles),
                          size: Size.infinite,
                        );
                      },
                    );
                  },
                ),

                // 4. Center Branded Content & Reveal Animations
                Center(
                  child: AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Soft glowing logo container
                        AnimatedBuilder(
                          animation: _backgroundController,
                          builder: (context, child) {
                            final pulse = math.sin(_backgroundController.value * 2 * math.pi);
                            final pulseNormalized = (pulse + 1.0) / 2.0;
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.15 + (pulseNormalized * 0.08)),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: const Icon(
                            Icons.delivery_dining_rounded,
                            size: 70,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Sleek Brand Text
                        const Text(
                          'Delivry',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Plus Jakarta Sans',
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Sweeping Brand Progress Line (No generic spinners)
                        const _AnimatedBrandLine(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlesPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      paint.color = Colors.white.withOpacity(p.opacity);
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AnimatedBrandLine extends StatefulWidget {
  const _AnimatedBrandLine();

  @override
  State<_AnimatedBrandLine> createState() => _AnimatedBrandLineState();
}

class _AnimatedBrandLineState extends State<_AnimatedBrandLine> with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sweepController,
      builder: (context, child) {
        return Container(
          width: 140,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1.5),
            child: FractionallySizedBox(
              alignment: Alignment(-1.0 + (_sweepController.value * 2.0), 0.0),
              widthFactor: 0.35,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
