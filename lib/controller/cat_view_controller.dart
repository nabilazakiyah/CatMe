
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/cat_model.dart';

class CatViewController extends ChangeNotifier {
  List<CatModel> cats = [], filtered = [];
  String currency = 'IDR';
  bool isLoading = true;

  Future<void> fetchCats() async {
    isLoading = true; notifyListeners();
    try {
      final res = await http.get(Uri.parse('https://api.thecatapi.com/v1/breeds'));
      if (res.statusCode == 200) {
        cats = (json.decode(res.body) as List).map((j) => CatModel.fromJson(j)).toList();
      }
    } catch (e) {
      cats = _dummy();
    }
    filtered = List.from(cats);
    isLoading = false; notifyListeners();
  }

  List<CatModel> _dummy() => [
    CatModel(breed: 'Persia', origin: 'Iran', country: 'IR', coat: 'Long', pattern: 'Solid', adoptionFeeIDR: 1500000, description: 'Manja!'),
  ];

  void filter(String query, String currency) {
  this.currency = currency; 
  filtered = cats.where((cat) => cat.breed.toLowerCase().contains(query.toLowerCase())).toList();
  notifyListeners();
}

  void goToDetail(BuildContext ctx, CatModel cat) {
    Navigator.pushNamed(ctx, '/detail', arguments: cat);
  }
}