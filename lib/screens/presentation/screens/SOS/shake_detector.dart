import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeManager {
  static int shakeCount = 0;
  static const double threshold = 15.0; // Increased threshold
  static int lastShakeTime = 0;
  static bool isShakeActive = true;

  static void startShakeListener({required Function onSOS}) {
   
    
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (!isShakeActive) return;
      
      double gX = event.x / 9.81;
      double gY = event.y / 9.81;
      double gZ = event.z / 9.81;

      double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > threshold) {
        int now = DateTime.now().millisecondsSinceEpoch;

        // Reset shake count if it's been more than 3 seconds
        if (now - lastShakeTime > 3000) {
          shakeCount = 0;
         
        }

        if (now - lastShakeTime > 500) { // Increased to 500ms
          shakeCount++;
          lastShakeTime = now;
          
          
        }

        if (shakeCount >= 5) {
         
          isShakeActive = false; // Prevent multiple triggers
          shakeCount = 0;
          
          // Add a small delay to ensure UI updates
          Future.delayed(Duration(milliseconds: 100), () {
            onSOS();
          });
          
          // Re-enable shake detection after 5 seconds
          Future.delayed(Duration(seconds: 5), () {
            isShakeActive = true;
           
          });
        }
      }
    });
  }

  // Method to manually trigger SOS
  static void triggerSOSManually(Function onSOS) {
   
    isShakeActive = false;
    onSOS();
    
    Future.delayed(Duration(seconds: 5), () {
      isShakeActive = true;
    });
  }
}