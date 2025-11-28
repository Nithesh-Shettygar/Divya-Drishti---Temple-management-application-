import 'package:flutter/material.dart';
import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class ElderlyDisabledTicketBookingPage extends StatefulWidget {
  @override
  _ElderlyDisabledTicketBookingPageState createState() => _ElderlyDisabledTicketBookingPageState();
}

class _ElderlyDisabledTicketBookingPageState extends State<ElderlyDisabledTicketBookingPage> {
  DateTime? _selectedDate;
  int _numberOfPeople = 1;
  final List<ElderlyDisabledPersonDetail> _personDetails = [];
  final int _maxBookingPerDay = 50;
  final int _minBookingPerDay = 1;
  
  // Mock data for booked dates
  final List<DateTime> _bookedDates = [
    DateTime.now().add(Duration(days: 1)),
    DateTime.now().add(Duration(days: 3)),
  ];

  @override
  void initState() {
    super.initState();
    _initializePersonDetails();
  }

  void _initializePersonDetails() {
    _personDetails.clear();
    for (int i = 0; i < _numberOfPeople; i++) {
      _personDetails.add(ElderlyDisabledPersonDetail());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Elderly/Disabled Ticket Booking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Date Selection
            _buildDateSelectionStep(),
            
            SizedBox(height: 30),
            
            if (_selectedDate != null) _buildPeopleSelectionStep(),
            
            if (_numberOfPeople > 0 && _selectedDate != null) 
              _buildPersonDetailsStep(),
            
            if (_selectedDate != null && _personDetails.isNotEmpty && 
                _personDetails.every((p) => p.isValid())) 
              _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Select Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Maximum $_maxBookingPerDay bookings per day (Special quota)',
          style: TextStyle(
            color: AppColors.primary.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 15),
        Container(
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
          child: _buildCalendar(),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    DateTime now = DateTime.now();
    DateTime firstDate = now;
    DateTime lastDate = now.add(Duration(days: 30));

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.primary),
                onPressed: () {},
              ),
              Text(
                DateFormat('MMMM yyyy').format(now),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.primary),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 10),
          
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary.withOpacity(0.7),
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 10),
          
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              DateTime date = firstDate.add(Duration(days: index));
              bool isBooked = _bookedDates.any((bookedDate) =>
                  bookedDate.year == date.year &&
                  bookedDate.month == date.month &&
                  bookedDate.day == date.day);
              bool isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;
              bool isPast = date.isBefore(DateTime(now.year, now.month, now.day));

              return GestureDetector(
                onTap: isBooked || isPast ? null : () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isBooked
                        ? Colors.grey.withOpacity(0.3)
                        : isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isBooked || isPast
                              ? Colors.grey
                              : isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isBooked)
                        Icon(Icons.block, size: 12, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2: Number of People',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 15),
        Container(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Number of People',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: AppColors.primary),
                      onPressed: _numberOfPeople > 1 ? () {
                        setState(() {
                          _numberOfPeople--;
                          _initializePersonDetails();
                        });
                      } : null,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        _numberOfPeople.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: AppColors.primary),
                      onPressed: _numberOfPeople < 5 ? () {
                        setState(() {
                          _numberOfPeople++;
                          _initializePersonDetails();
                        });
                      } : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Text(
          'Step 3: Person Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 15),
        ...List.generate(_numberOfPeople, (index) {
          return _buildPersonDetailForm(index);
        }),
      ],
    );
  }

  Widget _buildPersonDetailForm(int index) {
    ElderlyDisabledPersonDetail person = _personDetails[index];
    
    return Container(
      margin: EdgeInsets.only(bottom: 20),
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
            Text(
              'Person ${index + 1}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 15),
            _buildTextField(
              label: 'Full Name',
              hintText: 'Enter full name',
              onChanged: (value) => person.name = value,
            ),
            SizedBox(height: 15),
            _buildGenderDropdown(person),
            SizedBox(height: 15),
            _buildTextField(
              label: 'Phone Number',
              hintText: 'Enter phone number',
              keyboardType: TextInputType.phone,
              onChanged: (value) => person.phone = value,
            ),
            SizedBox(height: 15),
            _buildPersonTypeSelection(person),
            SizedBox(height: 15),
            if (person.isElderly) _buildAgeField(person),
            SizedBox(height: 15),
            _buildWheelchairRequirement(person),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonTypeSelection(ElderlyDisabledPersonDetail person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Person Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Text('Elderly'),
                selected: person.isElderly,
                onSelected: (selected) {
                  setState(() {
                    person.isElderly = selected;
                    if (selected) person.isDisabled = false;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: person.isElderly ? Colors.white : AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: Text('Disabled'),
                selected: person.isDisabled,
                onSelected: (selected) {
                  setState(() {
                    person.isDisabled = selected;
                    if (selected) person.isElderly = false;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: person.isDisabled ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgeField(ElderlyDisabledPersonDetail person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Age',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter age',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (value) => person.age = int.tryParse(value),
          ),
        ),
      ],
    );
  }

  Widget _buildWheelchairRequirement(ElderlyDisabledPersonDetail person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wheelchair Requirement',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Text('Required'),
                selected: person.wheelchairRequired,
                onSelected: (selected) {
                  setState(() {
                    person.wheelchairRequired = selected;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: person.wheelchairRequired ? Colors.white : AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: Text('Not Required'),
                selected: !person.wheelchairRequired,
                onSelected: (selected) {
                  setState(() {
                    person.wheelchairRequired = !selected;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: !person.wheelchairRequired ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: TextField(
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(ElderlyDisabledPersonDetail person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: person.gender,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            items: ['Male', 'Female', 'Other']
                .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                person.gender = value;
              });
            },
            hint: Text('Select Gender'),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      height: 56,
      margin: EdgeInsets.only(top: 30, bottom: 20),
      child: ElevatedButton(
        onPressed: _proceedToPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Proceed to Payment - Free',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _proceedToPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Confirmation'),
        content: Text('Your elderly/disabled tickets have been booked successfully!\n\nSpecial assistance will be provided.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ElderlyDisabledPersonDetail {
  String? name;
  String? gender;
  String? phone;
  bool isElderly = false;
  bool isDisabled = false;
  int? age;
  bool wheelchairRequired = false;

  bool isValid() {
    bool basicInfo = name != null && name!.isNotEmpty && 
                    gender != null && gender!.isNotEmpty &&
                    phone != null && phone!.isNotEmpty;
    
    if (isElderly) {
      return basicInfo && age != null && age! >= 60;
    } else if (isDisabled) {
      return basicInfo;
    }
    
    return false;
  }
}