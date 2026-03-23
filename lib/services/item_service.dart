import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ItemService {
  static const String _baseUrl = 'http://191.252.192.39/api/item';

  Future<List<Item>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Item.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar itens');
  }

  Future<void> create(Item item) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar item: ${response.statusCode}');
    }
  }

  Future<void> update(String id, Item item) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao atualizar item: ${response.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir item: ${response.statusCode}');
    }
  }
}
