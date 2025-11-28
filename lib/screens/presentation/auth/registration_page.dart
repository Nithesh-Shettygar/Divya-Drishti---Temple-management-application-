import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:divya_drishti/screens/presentation/auth/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (index) => FocusNode());
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isSendingOtp = false;

  String? _dummyOtp; // store dev OTP returned by backend

  final List<String> _genders = ['Male', 'Female', 'Other'];

  // Base URL for Flask backend
  final String _baseUrl = kIsWeb ? 'http://127.0.0.1:5000' : 'http://10.0.2.2:5000';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _otpFocusNodes.length; i++) {
      _otpFocusNodes[i].addListener(() {
        if (!_otpFocusNodes[i].hasFocus && _otpControllers[i].text.isEmpty) {
          if (i > 0) {
            _otpFocusNodes[i - 1].requestFocus();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _phoneController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Convert displayed DOB ("dd/mm/yyyy") to "yyyy-mm-dd" for DB
  String _formatDobForDb(String displayedDob) {
    try {
      final parts = displayedDob.split('/');
      if (parts.length == 3) {
        final dd = parts[0].padLeft(2, '0');
        final mm = parts[1].padLeft(2, '0');
        final yyyy = parts[2];
        return '$yyyy-$mm-$dd';
      }
    } catch (_) {}
    return displayedDob; // fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Divya Drishti',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _getPageSubtitle(),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 400),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / 4,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Text(
                          _getPageTitle(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildCurrentPage(),
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

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _buildPhonePage();
      case 1:
        return _buildOtpPage();
      case 2:
        return _buildPersonalDetailsPage();
      case 3:
        return _buildPasswordPage();
      default:
        return _buildPhonePage();
    }
  }

  Widget _buildPhonePage() {
    return Column(
      children: [
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hintText: 'Enter your 10-digit phone number',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 25),
        Container(
          width: double.infinity,
          height: 56,
          child: _isSendingOtp
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : ElevatedButton(
                  onPressed: () async {
                    if (_phoneController.text.length == 10) {
                      await _sendOtp();
                    } else {
                      _showErrorDialog('Please enter a valid 10-digit phone number');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Send OTP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildOtpPage() {
    return Column(
      children: [
        Text(
          'Enter the 4-digit code sent to ${_phoneController.text}',
          style: TextStyle(
            color: AppColors.primary.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        if (_dummyOtp != null) ...[
          Text(
            '📲 Dummy OTP: $_dummyOtp',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
        ],
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  if (value.length == 1 && index < 3) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                  if (_isOtpComplete() && index == 3) {
                    _verifyOtp();
                  }
                },
              ),
            );
          }),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive code? ",
              style: TextStyle(color: AppColors.primary.withOpacity(0.7)),
            ),
            TextButton(
              onPressed: _isSendingOtp ? null : _resendOtp,
              child: _isSendingOtp
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
        SizedBox(height: 25),
        Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isOtpComplete() ? _verifyOtp : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Verify OTP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        TextButton(
          onPressed: () {
            setState(() {
              _currentPage = 0;
              _clearOtpFields();
            });
          },
          child: Text(
            'Change Phone Number',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDetailsPage() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hintText: 'Enter your full name',
          prefixIcon: Icons.person,
        ),
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date of Birth',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: TextField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select your date of birth',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.date_range, color: AppColors.primary),
                    onPressed: _selectDate,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                ),
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                hint: Text('Select Gender'),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          hintText: 'Enter your complete address',
          prefixIcon: Icons.home,
          maxLines: 3,
        ),
        SizedBox(height: 25),
        Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_validatePersonalDetails()) {
                setState(() {
                  _currentPage = 3;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        TextButton(
          onPressed: () {
            setState(() {
              _currentPage = 1;
            });
          },
          child: Text(
            'Back to OTP',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordPage() {
    return Column(
      children: [
        _buildPasswordField(
          controller: _passwordController,
          label: 'Password',
          hintText: 'Enter your password',
          isPasswordVisible: _isPasswordVisible,
          onTogglePassword: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        SizedBox(height: 20),
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hintText: 'Re-enter your password',
          isPasswordVisible: _isConfirmPasswordVisible,
          onTogglePassword: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password must contain:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• At least 6 characters',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
              Text(
                '• One uppercase letter',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
              Text(
                '• One number',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 25),
        Container(
          width: double.infinity,
          height: 56,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    if (_validatePassword()) {
                      _completeRegistration();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        SizedBox(height: 15),
        TextButton(
          onPressed: () {
            setState(() {
              _currentPage = 2;
            });
          },
          child: Text(
            'Back to Details',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(prefixIcon, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback onTogglePassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.lock, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.primary,
                ),
                onPressed: onTogglePassword,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isOtpComplete() {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showErrorDialog('Please enter phone number');
      return;
    }

    setState(() => _isSendingOtp = true);
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      setState(() => _isSendingOtp = false);

      if (resp.statusCode == 200) {
        // Parse response for dummy OTP (development mode)
        try {
          final body = jsonDecode(resp.body);
          if (body != null && body['otp'] != null) {
            _dummyOtp = body['otp'].toString();
            // Optional: autofill OTP controllers for convenience in dev
            if (_dummyOtp!.length == 4) {
              for (int i = 0; i < 4; i++) {
                _otpControllers[i].text = _dummyOtp![i];
              }
            }
          } else {
            _dummyOtp = null;
          }
        } catch (e) {
          _dummyOtp = null;
        }

        // Move to OTP page (same registration view — shows inline OTP)
        setState(() => _currentPage = 1);
      } else {
        final body = jsonDecode(resp.body);
        _showErrorDialog(body['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      setState(() => _isSendingOtp = false);
      _showErrorDialog('Network error: $e');
    }
  }

  Future<void> _resendOtp() async {
    await _sendOtp();
  }

  Future<void> _verifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      _showErrorDialog('Enter 4-digit OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );
      setState(() => _isLoading = false);

      if (resp.statusCode == 200) {
        setState(() {
          _dummyOtp = null;
          _currentPage = 2;
          _clearOtpFields();
        });
      } else {
        final body = jsonDecode(resp.body);
        _showErrorDialog(body['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Network error: $e');
    }
  }

  Future<void> _completeRegistration() async {
    if (!_validatePersonalDetails()) return;
    if (!_validatePassword()) return;

    setState(() => _isLoading = true);
    try {
      final dobForDb = _formatDobForDb(_dobController.text.trim());
      final resp = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': _phoneController.text.trim(),
          'name': _nameController.text.trim(),
          'dob': dobForDb, // send yyyy-mm-dd
          'gender': _selectedGender,
          'address': _addressController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );
      setState(() => _isLoading = false);

      if (resp.statusCode == 201) {
        // Go to login after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      } else {
        final body = jsonDecode(resp.body);
        _showErrorDialog(body['message'] ?? 'Registration failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Network error: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  bool _validatePersonalDetails() {
    if (_nameController.text.isEmpty) {
      _showErrorDialog('Please enter your name');
      return false;
    }
    if (_dobController.text.isEmpty) {
      _showErrorDialog('Please select your date of birth');
      return false;
    }
    if (_selectedGender == null) {
      _showErrorDialog('Please select your gender');
      return false;
    }
    if (_addressController.text.isEmpty) {
      _showErrorDialog('Please enter your address');
      return false;
    }
    return true;
  }

  bool _validatePassword() {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showErrorDialog('Please enter both password fields');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showErrorDialog('Password must be at least 6 characters long');
      return false;
    }
    return true;
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case 0:
        return 'Phone Verification';
      case 1:
        return 'OTP Verification';
      case 2:
        return 'Personal Details';
      case 3:
        return 'Set Password';
      default:
        return 'Registration';
    }
  }

  String _getPageSubtitle() {
    switch (_currentPage) {
      case 0:
        return 'Enter your phone number to get started';
      case 1:
        return 'Verify your phone number with OTP';
      case 2:
        return 'Tell us a bit about yourself';
      case 3:
        return 'Create a secure password';
      default:
        return 'Create your account';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
