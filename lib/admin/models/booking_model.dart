class Person {
  final String? name;
  final String? phone;
  final String? gender;
  final String? age;
  final bool isElderDisabled;
  final String? elderAge;
  final bool? wheelchairRequired;

  Person({
    this.name,
    this.phone,
    this.gender,
    this.age,
    this.isElderDisabled = false,
    this.elderAge,
    this.wheelchairRequired,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      phone: json['phone'],
      gender: json['gender'],
      age: json['age'],
      isElderDisabled: json['is_elder_disabled'] ?? false,
      elderAge: json['elder_age'],
      wheelchairRequired: json['wheelchair_required'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'gender': gender,
      'age': age,
      'is_elder_disabled': isElderDisabled,
      'elder_age': elderAge,
      'wheelchair_required': wheelchairRequired,
    };
  }
}

class Booking {
  final int id;
  final String bookingRef;
  final String title;
  final DateTime bookingDate;
  final String timeSlot;
  final int persons;
  final int amount;
  final bool paid;
  final String? paymentRef;
  final DateTime createdAt;
  final List<Person> personDetails;

  Booking({
    required this.id,
    required this.bookingRef,
    required this.title,
    required this.bookingDate,
    required this.timeSlot,
    required this.persons,
    required this.amount,
    required this.paid,
    this.paymentRef,
    required this.createdAt,
    required this.personDetails,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      bookingRef: json['booking_ref'] ?? '',
      title: json['title'] ?? '',
      bookingDate: DateTime.parse(json['booking_date'] ?? DateTime.now().toString()),
      timeSlot: json['time_slot'] ?? '',
      persons: json['persons'] ?? 0,
      amount: json['amount'] ?? 0,
      paid: json['paid'] ?? false,
      paymentRef: json['payment_ref'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      personDetails: (json['person_details'] as List<dynamic>?)
          ?.map((p) => Person.fromJson(p))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_ref': bookingRef,
      'title': title,
      'booking_date': bookingDate.toIso8601String(),
      'time_slot': timeSlot,
      'persons': persons,
      'amount': amount,
      'paid': paid,
      'payment_ref': paymentRef,
      'created_at': createdAt.toIso8601String(),
      'person_details': personDetails.map((p) => p.toJson()).toList(),
    };
  }
}