import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Add these missing classes and enums
enum LostFoundAction { reportLost, uploadFound, viewLost }

class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color bg = Color(0xFFF5F5F5);
}

class LostFoundPage extends StatefulWidget {
  final LostFoundAction initialAction;

  const LostFoundPage({Key? key, this.initialAction = LostFoundAction.reportLost}) : super(key: key);

  @override
  _LostFoundPageState createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  List<XFile> _selectedImages = [];
  LostFoundAction _currentAction = LostFoundAction.reportLost;

  // Sample data for lost items
  final List<LostItem> _lostItems = [
    LostItem(
      id: '1',
      itemName: 'Black Wallet',
      description: 'Black leather wallet containing ID cards and credit cards',
      location: 'Main Temple Hall',
      date: '2024-01-15',
      contact: '9876543210',
      imagePaths: [],
      status: 'Lost',
      reportedBy: 'John Doe',
    ),
    LostItem(
      id: '2',
      itemName: 'Gold Earrings',
      description: 'Small gold jhumka earrings',
      location: 'Prayer Area',
      date: '2024-01-14',
      contact: '9876543211',
      imagePaths: [],
      status: 'Lost',
      reportedBy: 'Jane Smith',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentAction = widget.initialAction;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _getInitialTabIndex(),
    );
  }

  int _getInitialTabIndex() {
    switch (_currentAction) {
      case LostFoundAction.reportLost:
        return 0;
      case LostFoundAction.uploadFound:
        return 1;
      case LostFoundAction.viewLost:
        return 2;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _itemNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Lost & Found',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Report Lost'),
                Tab(text: 'Upload Found'),
                Tab(text: 'View Lost Items'),
              ],
              onTap: (index) {
                setState(() {
                  _currentAction = LostFoundAction.values[index];
                });
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportLostTab(),
                _buildUploadFoundTab(),
                _buildViewLostItemsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportLostTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFormSection(),
          SizedBox(height: 20),
          _buildImageUploadSection(),
          SizedBox(height: 30),
          _buildSubmitButton('Report Lost Item', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildUploadFoundTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFormSection(),
          SizedBox(height: 20),
          _buildImageUploadSection(),
          SizedBox(height: 30),
          _buildSubmitButton('Upload Found Item', Colors.green),
        ],
      ),
    );
  }

  Widget _buildViewLostItemsTab() {
    return _lostItems.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No lost items reported',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _lostItems.length,
            itemBuilder: (context, index) {
              return _buildLostItemCard(_lostItems[index]);
            },
          );
  }

  Widget _buildFormSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_itemNameController, 'Item Name', Icons.card_giftcard),
            SizedBox(height: 15),
            _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3),
            SizedBox(height: 15),
            _buildTextField(_locationController, 'Location where lost/found', Icons.location_on),
            SizedBox(height: 15),
            _buildTextField(_contactController, 'Contact Number', Icons.phone),
            SizedBox(height: 15),
            _buildDateField(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Date (YYYY-MM-DD)',
        prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _dateController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          });
        }
      },
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Add photos of the item (max 3 images)',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 15),
            _buildImageGrid(),
            SizedBox(height: 15),
            _buildImageUploadButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          return _buildAddImageButton();
        }
        return _buildImagePreview(_selectedImages[index]);
      },
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _selectImages,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Icon(
          Icons.add_photo_alternate,
          color: AppColors.primary,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildImagePreview(XFile imageFile) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(File(imageFile.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(imageFile),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _selectImages,
            icon: Icon(Icons.photo_library, color: AppColors.primary),
            label: Text('Gallery', style: TextStyle(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _takePhoto,
            icon: Icon(Icons.camera_alt, color: AppColors.primary),
            label: Text('Camera', style: TextStyle(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLostItemCard(LostItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.itemName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 12),
            _buildDetailRow(Icons.location_on, item.location),
            _buildDetailRow(Icons.calendar_today, item.date),
            _buildDetailRow(Icons.phone, item.contact),
            _buildDetailRow(Icons.person, 'Reported by: ${item.reportedBy}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Future<void> _selectImages() async {
    try {
      final List<XFile>? selectedImages = await _imagePicker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (selectedImages != null && selectedImages.isNotEmpty) {
        setState(() {
          if (_selectedImages.length + selectedImages.length <= 3) {
            _selectedImages.addAll(selectedImages);
          } else {
            final int remainingSlots = 3 - _selectedImages.length;
            _selectedImages.addAll(selectedImages.take(remainingSlots));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Maximum 3 images allowed')),
            );
          }
        });
      }
    } catch (e) {
      print('Error selecting images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting images: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          if (_selectedImages.length < 3) {
            _selectedImages.add(photo);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Maximum 3 images allowed')),
            );
          }
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  void _removeImage(XFile imageFile) {
    setState(() {
      _selectedImages.remove(imageFile);
    });
  }

  void _submitForm() {
    if (_itemNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    switch (_currentAction) {
      case LostFoundAction.reportLost:
        _handleReportLost();
        break;
      case LostFoundAction.uploadFound:
        _handleUploadFound();
        break;
      case LostFoundAction.viewLost:
        break;
    }
  }

  void _handleReportLost() {
    final newItem = LostItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: _itemNameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      date: _dateController.text.isEmpty 
          ? "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}"
          : _dateController.text,
      contact: _contactController.text,
      imagePaths: _selectedImages.map((xfile) => xfile.path).toList(),
      status: 'Lost',
      reportedBy: 'Current User',
    );

    setState(() {
      _lostItems.add(newItem);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lost item reported successfully')),
    );
    _clearForm();
  }

  void _handleUploadFound() {
    final newItem = LostItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: _itemNameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      date: _dateController.text.isEmpty 
          ? "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}"
          : _dateController.text,
      contact: _contactController.text,
      imagePaths: _selectedImages.map((xfile) => xfile.path).toList(),
      status: 'Found',
      reportedBy: 'Current User',
    );

    setState(() {
      _lostItems.add(newItem);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Found item uploaded successfully')),
    );
    _clearForm();
  }

  void _clearForm() {
    _itemNameController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _contactController.clear();
    _dateController.clear();
    setState(() {
      _selectedImages.clear();
    });
  }
}

class LostItem {
  final String id;
  final String itemName;
  final String description;
  final String location;
  final String date;
  final String contact;
  final List<String> imagePaths;
  final String status;
  final String reportedBy;

  LostItem({
    required this.id,
    required this.itemName,
    required this.description,
    required this.location,
    required this.date,
    required this.contact,
    required this.imagePaths,
    required this.status,
    required this.reportedBy,
  });
}