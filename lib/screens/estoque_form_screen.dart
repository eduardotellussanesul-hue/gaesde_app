import 'package:flutter/material.dart';
import '../services/estoque_service.dart';

class EstoqueFormScreen extends StatefulWidget {
  final Map<String, String> itemNomes;
  final Map<String, String> localNomes;

  const EstoqueFormScreen({
    super.key,
    required this.itemNomes,
    required this.localNomes,
  });

  @override
  State<EstoqueFormScreen> createState() => _EstoqueFormScreenState();
}

class _EstoqueFormScreenState extends State<EstoqueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeCtrl = TextEditingController();
  final EstoqueService _service = EstoqueService();
  String? _itemId;
  String? _localId;
  bool _saving = false;

  @override
  void dispose() {
    _quantidadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_itemId == null) {
      _showError('Selecione um item');
      return;
    }
    if (_localId == null) {
      _showError('Selecione um local');
      return;
    }

    setState(() => _saving = true);
    try {
      final quantidade = double.parse(_quantidadeCtrl.text.replaceAll(',', '.'));
      await _service.create(
        itemId: _itemId!,
        localId: _localId!,
        quantidade: quantidade,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Erro ao criar estoque: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final itens = widget.itemNomes.entries.toList();
    final locais = widget.localNomes.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Estoque'),
        centerTitle: true,
        backgroundColor: cs.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _itemId,
                decoration: const InputDecoration(
                  labelText: 'Item *',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Selecione o item'),
                items: itens
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _itemId = v),
                validator: (v) => v == null ? 'Selecione um item' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _localId,
                decoration: const InputDecoration(
                  labelText: 'Local *',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Selecione o local'),
                items: locais
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _localId = v),
                validator: (v) => v == null ? 'Selecione um local' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Quantidade Inicial *',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a quantidade';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n < 0) return 'Quantidade inválida';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _saving ? 'Salvando...' : 'Criar Estoque',
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}