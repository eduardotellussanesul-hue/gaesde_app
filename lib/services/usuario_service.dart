import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {
  static const String _baseUrl = 'http://191.252.192.39/api/usuario';

  Future<List<Usuario>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Usuario.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar usuários: ${response.statusCode}');
  }

  Future<void> create(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar usuário: ${response.statusCode}');
    }
  }

  Future<void> update(String id, Usuario usuario) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario.toJson()),
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao atualizar usuário: ${response.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erro ao deletar usuário: ${response.statusCode}');
    }
  }
}
