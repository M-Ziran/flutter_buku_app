import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/item.dart';

class ApiService {
  Future<List<Item>> fetchItemsFromJson() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = json.decode(response) as List;
    return data.map((json) => Item.fromJson(json)).toList();
  }
}
