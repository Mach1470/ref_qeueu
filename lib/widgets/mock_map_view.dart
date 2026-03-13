import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MockMapView extends StatelessWidget {
  final String title;
  final List<MockMarker>? markers;
  final bool showRoute;
  final Color primaryColor;

  const MockMapView({
    super.key,
    this.title = 'Map View',
    this.markers,
    this.showRoute = false,
    this.primaryColor = const Color(0xFF386BB8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF1F5F9), // Light grey background
      child: Stack(
        children: [
          // Background Grid Lines (Uber-style)
          CustomPaint(
            painter: _GridPainter(),
            size: Size.infinite,
          ),

          // Central Pulse for "My Location"
          const Center(
            child: _PulseIndicator(),
          ),

          // Render Markers
          if (markers != null)
            ...markers!.map((m) => Positioned(
                  left: m.x,
                  top: m.y,
                  child: _MockMarkerWidget(marker: m),
                )),

          // Optional Simulated Route
          if (showRoute)
            Center(
              child: CustomPaint(
                painter: _RoutePainter(color: primaryColor),
                size: const Size(200, 200),
              ),
            ),

          // Map Control Buttons (Mock)
          Positioned(
            right: 16,
            bottom: 300, // Above bottom sheets
            child: Column(
              children: [
                _MapButton(icon: Icons.add),
                const SizedBox(height: 8),
                _MapButton(icon: Icons.remove),
                const SizedBox(height: 16),
                _MapButton(icon: Icons.my_location, color: primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MockMarker {
  final double x;
  final double y;
  final IconData icon;
  final Color color;
  final String? label;

  const MockMarker({
    required this.x,
    required this.y,
    this.icon = Icons.location_on,
    this.color = Colors.red,
    this.label,
  });
}

class _MockMarkerWidget extends StatelessWidget {
  final MockMarker marker;

  const _MockMarkerWidget({required this.marker});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (marker.label != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                )
              ],
            ),
            child: Text(
              marker.label!,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Icon(marker.icon, color: marker.color, size: 32),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const _MapButton({required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Icon(icon, color: color ?? Colors.grey[700], size: 20),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  final Color color;
  _RoutePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.2,
      size.width,
      0,
    );

    canvas.drawPath(path, paint);

    // Draw dots at endpoints

    canvas.drawCircle(Offset(0, size.height), 6, Paint()..color = color);
    canvas.drawCircle(const Offset(200, 0), 6, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _PulseIndicator extends StatefulWidget {
  const _PulseIndicator();

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
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
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 20 + (80 * _controller.value),
              height: 20 + (80 * _controller.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF386BB8)
                    .withOpacity(0.3 * (1 - _controller.value)),
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF386BB8),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
