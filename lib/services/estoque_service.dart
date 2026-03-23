import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estoque.dart';

class EstoqueService {
  static const String _baseUrl = 'http://191.252.192.39/api/estoque';

  Future<void> create({
    required String itemId,
    required String localId,
    required double quantidade,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'item_id': itemId,
        'local_id': localId,
        'quantidade': quantidade,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar estoque: ${response.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir estoque: ${response.statusCode}');
    }
  }

  Future<List<Estoque>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Estoque.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar estoque');
  }

  Future<double> getSaldo(String itemId) async {
    final response = await http.get(Uri.parse('$_baseUrl/saldo/$itemId'));
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as num).toDouble();
    }
    throw Exception('Erro ao buscar saldo');
  }

  Future<List<Estoque>> getBaixoEstoque(double limite) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/baixo?limite=$limite'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Estoque.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar baixo estoque');
  }

  Future<bool> entrada({
    required String itemId,
    required String localId,
    required double quantidade,
    String observacao = '',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/entrada'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'itemId': itemId,
        'localId': localId,
        'quantidade': quantidade,
        'observacao': observacao,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    }
    throw Exception('Erro ao registrar entrada');
  }

  Future<bool> saida({
    required String itemId,
    required String localId,
    required double quantidade,
    String observacao = '',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/saida'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'itemId': itemId,
        'localId': localId,
        'quantidade': quantidade,
        'observacao': observacao,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    }
    throw Exception('Erro ao registrar saída');
  }

  Future<bool> transferencia({
    required String itemId,
    required String localOrigemId,
    required String localDestinoId,
    required double quantidade,
    String observacao = '',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/transferencia'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'itemId': itemId,
        'localOrigemId': localOrigemId,
        'localDestinoId': localDestinoId,
        'quantidade': quantidade,
        'observacao': observacao,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    }
    throw Exception('Erro ao registrar transferência');
  }
}
