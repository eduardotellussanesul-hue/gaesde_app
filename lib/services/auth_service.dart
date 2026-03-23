import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://191.252.192.39/api/usuario';

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    if (response.statusCode == 200) {
      final ok = jsonDecode(response.body) as bool;
      if (!ok) throw Exception('Credenciais inválidas');
      // Busca os dados do usuário pelo email
      final listResp = await http.get(Uri.parse(_baseUrl));
      if (listResp.statusCode == 200) {
        final List<dynamic> usuarios = jsonDecode(listResp.body);
        final usuario = usuarios.firstWhere(
          (u) => u['email'] == email,
          orElse: () => <String, dynamic>{'nome': email},
        );
        return usuario as Map<String, dynamic>;
      }
      return {'nome': email};
    }
    throw Exception('Credenciais inválidas');
  }
}
