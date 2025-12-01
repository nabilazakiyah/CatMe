import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/model/cat_model.dart';

enum SortOption {
  nameAZ,
  nameZA,
  priceLowToHigh,
  priceHighToLow,
}

class CatViewController extends ChangeNotifier {
  List<CatModel> cats = [], filtered = [];
  String currency = 'IDR';
  bool isLoading = true;
  SortOption currentSort = SortOption.nameAZ;
  String searchQuery = '';

  Future<void> fetchCats() async {
    isLoading = true;
    notifyListeners();
    try {
      final res =
          await http.get(Uri.parse('https://api.thecatapi.com/v1/breeds'));
      if (res.statusCode == 200) {
        cats = (json.decode(res.body) as List)
            .map((j) => CatModel.fromJson(j))
            .toList();
      }
    } catch (e) {
      cats = _dummy();
    }
    filtered = List.from(cats);
    _applySorting();
    isLoading = false;
    notifyListeners();
  }

  List<CatModel> _dummy() => [
        CatModel(
            breed: 'Persia',
            origin: 'Iran',
            country: 'IR',
            coat: 'Long',
            pattern: 'Solid',
            adoptionFeeIDR: 1500000,
            description: 'Manja!'),
      ];

  void filter(String query, String currency) {
    this.currency = currency;
    searchQuery = query;
    filtered = cats
        .where((cat) => cat.breed.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _applySorting();
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    currentSort = option;
    _applySorting();
    notifyListeners();
  }

  void _applySorting() {
    switch (currentSort) {
      case SortOption.nameAZ:
        filtered.sort((a, b) => a.breed.compareTo(b.breed));
        break;
      case SortOption.nameZA:
        filtered.sort((a, b) => b.breed.compareTo(a.breed));
        break;
      case SortOption.priceLowToHigh:
        filtered.sort((a, b) => a.adoptionFeeIDR.compareTo(b.adoptionFeeIDR));
        break;
      case SortOption.priceHighToLow:
        filtered.sort((a, b) => b.adoptionFeeIDR.compareTo(a.adoptionFeeIDR));
        break;
    }
  }

  String getSortLabel() {
    switch (currentSort) {
      case SortOption.nameAZ:
        return 'A-Z';
      case SortOption.nameZA:
        return 'Z-A';
      case SortOption.priceLowToHigh:
        return 'Termurah';
      case SortOption.priceHighToLow:
        return 'Termahal';
    }
  }

  void goToDetail(BuildContext ctx, CatModel cat) {
    Navigator.pushNamed(ctx, '/detail', arguments: cat);
  }
}
