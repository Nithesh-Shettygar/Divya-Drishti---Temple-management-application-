import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedGender;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  // Base URL for Flask backend
  final String _baseUrl = kIsWeb ? 'http://127.0.0.1:5000' : 'http://10.0.2.2:5000';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userPhone = prefs.getString('user_phone');

      if (userPhone != null) {
        await _fetchUserProfile(userPhone);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserProfile(String phone) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/$phone'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userData = data['user'];
          _nameController.text = _userData?['name'] ?? '';
          _dobController.text = _userData?['dob'] != null
              ? _formatDateForDisplay(_userData!['dob'])
              : '';
          _selectedGender = _userData?['gender'] ?? '';
          _addressController.text = _userData?['address'] ?? '';
          _isLoading = false;
        });

        // Update shared prefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _userData?['name'] ?? '');
        await prefs.setString('user_phone', _userData?['phone'] ?? '');
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to load profile data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Network error: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _selectedGender == null ||
        _addressController.text.isEmpty) {
      _showErrorDialog('Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? userPhone = prefs.getString('user_phone');

      final dobForDb = _formatDateForDb(_dobController.text);

      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': userPhone,
          'name': _nameController.text,
          'dob': dobForDb,
          'gender': _selectedGender,
          'address': _addressController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userData = data['user'];
          _isEditing = false;
        });

        await prefs.setString('user_name', _userData?['name'] ?? '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        _showErrorDialog(errorData['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Network error: $e');
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performLogout();
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_userData?['dob'] ?? '') ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Convert "yyyy-mm-dd" -> "dd/mm/yyyy"
  String _formatDateForDisplay(String? dateString) {
    if (dateString == null) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Convert display "dd/mm/yyyy" -> "yyyy-mm-dd"
  String _formatDateForDb(String display) {
    try {
      final parts = display.split('/');
      if (parts.length == 3) {
        final dd = parts[0].padLeft(2, '0');
        final mm = parts[1].padLeft(2, '0');
        final yyyy = parts[2];
        return '$yyyy-$mm-$dd';
      }
    } catch (_) {}
    return display;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  SizedBox(height: 30),
                  _buildProfileCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF8A7BEC)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 15),
          Text(
            _userData?['name'] ?? 'User Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            _userData?['phone'] ?? 'Phone Number',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Member since ${_formatDate(_userData?['created_at'])}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                _isEditing
                    ? Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _nameController.text = _userData?['name'] ?? '';
                                _dobController.text = _formatDate(_userData?['dob']);
                                _selectedGender = _userData?['gender'] ?? '';
                                _addressController.text = _userData?['address'] ?? '';
                              });
                            },
                            child: Text('Cancel'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: Text('Save'),
                          ),
                        ],
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        icon: Icon(Icons.edit, color: AppColors.primary),
                      ),
              ],
            ),
            SizedBox(height: 20),
            _buildEditableField(
              label: 'Full Name',
              value: _nameController.text,
              isEditing: _isEditing,
              controller: _nameController,
              icon: Icons.person,
            ),
            SizedBox(height: 15),
            _buildReadOnlyField(
              label: 'Phone Number',
              value: _userData?['phone'] ?? '',
              icon: Icons.phone,
            ),
            SizedBox(height: 15),
            _buildDateField(),
            SizedBox(height: 15),
            _buildGenderField(),
            SizedBox(height: 15),
            _buildEditableField(
              label: 'Address',
              value: _addressController.text,
              isEditing: _isEditing,
              controller: _addressController,
              icon: Icons.home,
              maxLines: 3,
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required bool isEditing,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 5),
        isEditing
            ? TextField(
                controller: controller,
                maxLines: maxLines,
                decoration: InputDecoration(
                  prefixIcon: Icon(icon, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        value.isEmpty ? 'Not set' : value,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  value.isEmpty ? 'Not set' : value,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 5),
        _isEditing
            ? TextField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.date_range, color: AppColors.primary),
                    onPressed: _selectDate,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _dobController.text.isEmpty ? 'Not set' : _dobController.text,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 5),
        _isEditing
            ? DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
              )
            : Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedGender?.isEmpty ?? true ? 'Not set' : _selectedGender!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
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
