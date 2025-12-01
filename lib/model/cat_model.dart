import 'package:intl/intl.dart';

class CatModel {
  final int? id;
  final String breed;
  final String origin;
  final String country;
  final String coat;
  final String pattern;
  final String description;
  final double adoptionFeeIDR;
  final String? date;

  
  CatModel({
    this.id,
    required this.breed,
    required this.origin,
    required this.country,
    required this.coat,
    required this.pattern,
    required this.adoptionFeeIDR,
    required this.description,
    this.date,
  });

  CatModel.forHistory({
    required this.breed,
    required this.date,
  })  : id = null,
        origin = '',
        country = '',
        coat = '',
        pattern = '',
        description = '',
        adoptionFeeIDR = 0;

  factory CatModel.fromJson(Map<String, dynamic> json) {
    final fee = 500000 + (json['id']?.hashCode ?? 0).abs() % 4500000;
    return CatModel(
      id: json['id']?.hashCode,
      breed: json['name'] ?? 'Unknown',
      origin: json['origin'] ?? 'Unknown',
      country: json['country_code'] ?? 'XX',
      coat: json['hairless'] == 1 ? 'Hairless' : 'Fur',
      pattern: 'Various',
      adoptionFeeIDR: fee.toDouble(),
      description: json['description'] ?? 'Kucing lucu!',
    );
  }

  factory CatModel.fromMap(Map<String, dynamic> map) {
    return CatModel.forHistory(
      breed: map['breed'] as String,
      date: map['date'] as String,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'breed': breed,
      'origin': origin,
      'country': country,
      'coat': coat,
      'pattern': pattern,
      'adoptionFeeIDR': adoptionFeeIDR,
      'description': description,
      'date': date,
    };
  }
  static String formatCurrency(double amount, String currency) {
    switch (currency) {
      case 'USD':
        return '\$${ (amount / 15800).toStringAsFixed(2) }'; 
      case 'KRW':
        return '₩${ (amount / 11.5).toStringAsFixed(0) }'; 
      case 'GBP':
        return '£${ (amount / 20000).toStringAsFixed(2) }'; 
      case 'SAR':
        return 'ر.س ${(amount / 4200).toStringAsFixed(2)}'; 
      default:
        return NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(amount);
    }
  }


  String get formattedDate {
  if (date == null || date!.isEmpty) return 'Tidak tersedia';
  try {
    final dt = DateTime.parse(date!);
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  } catch (e) {
    return date!;
  }
}

  CatModel copyWith({
    int? id,
    String? breed,
    String? origin,
    String? country,
    String? coat,
    String? pattern,
    String? description,
    double? adoptionFeeIDR,
    String? date,
  }) {
    return CatModel(
      id: id ?? this.id,
      breed: breed ?? this.breed,
      origin: origin ?? this.origin,
      country: country ?? this.country,
      coat: coat ?? this.coat,
      pattern: pattern ?? this.pattern,
      description: description ?? this.description,
      adoptionFeeIDR: adoptionFeeIDR ?? this.adoptionFeeIDR,
      date: date ?? this.date,
    );
  }
}