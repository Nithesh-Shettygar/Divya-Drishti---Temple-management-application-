import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:divya_drishti/screens/presentation/screens/profile_page.dart';
import 'package:divya_drishti/screens/presentation/screens/notification_page.dart';
import 'package:flutter/material.dart';

class CommonTopSection extends StatefulWidget {
  @override
  _CommonTopSectionState createState() => _CommonTopSectionState();
}

class _CommonTopSectionState extends State<CommonTopSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildBlinkingM({double size = 12, double top = 0, double left = 0}) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                // color: Colors.white.withOpacity(_animation.value * 0.3),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(_animation.value * 0.1),
                    blurRadius: 8 * _animation.value,
                    spreadRadius: 2 * _animation.value,
                  ),
                ],
              ),
              child: Text(
                'ॐ',
                style: TextStyle(
                  fontSize: size,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withOpacity(_animation.value),
                      blurRadius: 10 * _animation.value,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(),
              ),
              
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Divya Dristhi',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.notifications, color: AppColors.primary),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NotificationPage()),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.person, color: AppColors.primary),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProfilePage()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Adding 5 blinking M letters at different positions
          _buildBlinkingM(size: 14, top: 10, left: 60),
          _buildBlinkingM(size: 16, top: 80, left: 10),
          _buildBlinkingM(size: 12, top: 100, left: 70),
          _buildBlinkingM(size: 18, top: 60, left: MediaQuery.of(context).size.width - 100),
          _buildBlinkingM(size: 10, top: 100, left: MediaQuery.of(context).size.width - 60),
        ],
      ),
    );
  }
}