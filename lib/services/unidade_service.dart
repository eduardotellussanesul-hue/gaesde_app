import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unidade.dart';

class UnidadeService {
  static const String _baseUrl = 'http://191.252.192.39/api/unidade';

  Future<List<Unidade>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Unidade.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar unidades');
  }

  Future<void> create(Unidade unidade) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(unidade.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar unidade: ${response.statusCode}');
    }
  }

  Future<void> update(String id, Unidade unidade) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(unidade.toJson()),
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao atualizar unidade: ${response.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir unidade: ${response.statusCode}');
    }
  }
}