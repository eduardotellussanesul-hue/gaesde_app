import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/local.dart';

class LocalService {
  static const String _baseUrl = 'http://191.252.192.39/api/local';

  Future<List<Local>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Local.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar locais');
  }

  Future<void> create(Local local) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(local.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar local: ${response.statusCode}');
    }
  }

  Future<void> update(String id, Local local) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(local.toJson()),
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao atualizar local: ${response.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir local: ${response.statusCode}');
    }
  }
}
