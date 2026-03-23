import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria.dart';

class CategoriaService {
  static const String _baseUrl = 'http://191.252.192.39/api/categoria';

  Future<List<Categoria>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Categoria.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar categorias');
  }

  Future<void> create(Categoria categoria) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(categoria.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar categoria: ${response.statusCode}');
    }
  }

  Future<void> update(String id, Categoria categoria) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(categoria.toJson()),
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao atualizar categoria: ${response.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir categoria: ${response.statusCode}');
    }
  }
}