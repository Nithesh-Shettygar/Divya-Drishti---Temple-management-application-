import 'package:location/location.dart';
import 'package:divya_drishti/screens/presentation/screens/SOS/firebase_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class SosService {
  static Future<void> sendLocationToFirebase() async {
    try {
      // Use the static location
      final staticLat =23.228096;
      final staticLon =72.508640;
      
     
      
      // Send to Firebase with static location
      await FirebaseHelper.sendLocationWithStatic(
        lat: staticLat,
        lon: staticLon,
      );
      
      // Send SMS
      await _sendSMS();
      
    } catch (e) {
   
      rethrow;
    }
  }
  
  static Future<void> _sendSMS() async {
    try {
      // Static phone number for emergency
      String emergencyPhone = "+916363269950";
      String message = "EMERGENCY SOS ALERT! Location: 23.224363, 72.507734. User needs immediate assistance!";
      
     
      
      // Create SMS URI
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: emergencyPhone,
        queryParameters: {'body': message},
      );
      
      // Try to launch SMS app
      try {
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
        
        } else {
         
          // Fallback: Show how to send manually
          _showSMSFallback(emergencyPhone, message);
        }
      } catch (e) {
       
        _showSMSFallback(emergencyPhone, message);
      }
      
    } catch (e) {
     
    }
  }
  
  static void _showSMSFallback(String phone, String message) {
   

  }
}