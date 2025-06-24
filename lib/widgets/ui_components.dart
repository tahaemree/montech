import 'package:flutter/material.dart';

// Sayfalar arası geçiş animasyonlarını yöneten sınıf
class PageTransition extends PageRouteBuilder {
  final Widget page;
  final TransitionType type;
  final Curve curve;
  final Duration duration;
  final Alignment alignment;

  PageTransition({
    required this.page,
    this.type = TransitionType.rightToLeft,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 300),
    this.alignment = Alignment.center,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (type) {
              case TransitionType.fade:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              case TransitionType.rightToLeft:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: child,
                );
              case TransitionType.leftToRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: child,
                );
              case TransitionType.topToBottom:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: child,
                );
              case TransitionType.bottomToTop:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: child,
                );
              case TransitionType.scale:
                return ScaleTransition(
                  alignment: alignment,
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Interval(0.00, 0.50, curve: curve),
                  ),
                  child: child,
                );
              case TransitionType.rotate:
                return RotationTransition(
                  turns: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                );
              case TransitionType.size:
                return Align(
                  alignment: alignment,
                  child: SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                    child: child,
                  ),
                );
              case TransitionType.fadeAndScale:
                return ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.85,
                    end: 1.0,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: FadeTransition(
                    opacity: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(CurvedAnimation(parent: animation, curve: curve)),
                    child: child,
                  ),
                );
            }
          },
        );
}

// Geçiş tipleri
enum TransitionType {
  fade,
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
  scale,
  rotate,
  size,
  fadeAndScale,
}

// Yükleme indikatörleri
class CustomLoading extends StatelessWidget {
  final Color color;
  final double size;
  final LoadingType type;

  const CustomLoading({
    super.key,
    required this.color,
    this.size = 32.0,
    this.type = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: size / 10,
          ),
        );
      case LoadingType.linear:
        return SizedBox(
          width: size * 3,
          height: size / 3,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      case LoadingType.pulsating:
        return PulsatingDot(size: size, color: color);
    }
  }
}

enum LoadingType {
  circular,
  linear,
  pulsating,
}

// Nabız gibi atan yükleme noktası
class PulsatingDot extends StatefulWidget {
  final double size;
  final Color color;

  const PulsatingDot({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  State<PulsatingDot> createState() => _PulsatingDotState();
}

class _PulsatingDotState extends State<PulsatingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(_animation.value),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

// Yükseltilmiş buton
class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color primaryColor;
  final Color? splashColor;
  final EdgeInsets padding;
  final double borderRadius;
  final double elevation;
  final double animationScale;
  final Duration animationDuration;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.primaryColor,
    this.splashColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.borderRadius = 12,
    this.elevation = 3,
    this.animationScale = 0.95,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.animationScale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        _controller.reverse();
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: widget.animationDuration,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.primaryColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.3),
                    blurRadius: _isPressed ? 4.0 : 8.0,
                    spreadRadius: _isPressed ? 0.0 : 2.0,
                    offset: _isPressed
                        ? const Offset(0.0, 1.0)
                        : const Offset(0.0, 3.0),
                  ),
                ],
              ),
              child: Center(child: widget.child),
            ),
          );
        },
      ),
    );
  }
}

// Özel bir tasarım eklemek isteyenler için temel kart bileşeni
class CustomCard extends StatefulWidget {
  final Widget child;
  final Color? color;
  final double borderRadius;
  final EdgeInsets padding;
  final double elevation;
  final VoidCallback? onTap;
  final bool isHoverable;

  const CustomCard({
    super.key,
    required this.child,
    this.color,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.elevation = 4.0,
    this.onTap,
    this.isHoverable = false,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final cardColor = widget.color ?? theme.cardColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(_isHovered && widget.isHoverable ? 0.1 : 0.05),
                spreadRadius: _isHovered && widget.isHoverable ? 0.0 : 0.0,
                blurRadius: _isHovered && widget.isHoverable ? 8.0 : 5.0,
                offset: _isHovered && widget.isHoverable
                    ? const Offset(0, 5)
                    : const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: _isHovered && widget.isHoverable && widget.onTap != null
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          transform: _isHovered && widget.isHoverable && widget.onTap != null
              ? Matrix4.translationValues(0, -3, 0)
              : Matrix4.translationValues(0, 0, 0),
          child: widget.child,
        ),
      ),
    );
  }
}
