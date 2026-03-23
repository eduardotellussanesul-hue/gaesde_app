import 'package:flutter/material.dart';
import '../services/estoque_service.dart';

class EstoqueMovimentacaoScreen extends StatefulWidget {
  final String tipo; // 'entrada' | 'saida' | 'transferencia'
  final Map<String, String> itemNomes;
  final Map<String, String> localNomes;

  const EstoqueMovimentacaoScreen({
    super.key,
    required this.tipo,
    required this.itemNomes,
    required this.localNomes,
  });

  @override
  State<EstoqueMovimentacaoScreen> createState() =>
      _EstoqueMovimentacaoScreenState();
}

class _EstoqueMovimentacaoScreenState
    extends State<EstoqueMovimentacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeCtrl = TextEditingController();
  final _observacaoCtrl = TextEditingController();
  final EstoqueService _service = EstoqueService();

  String? _itemId;
  String? _localOrigemId;
  String? _localDestinoId;
  bool _saving = false;

  bool get isTransferencia => widget.tipo == 'transferencia';
  bool get isEntrada => widget.tipo == 'entrada';

  String get titulo {
    switch (widget.tipo) {
      case 'entrada':
        return 'Registrar Entrada';
      case 'saida':
        return 'Registrar Saída';
      case 'transferencia':
        return 'Transferência';
      default:
        return 'Movimentação';
    }
  }

  Color get corTipo {
    switch (widget.tipo) {
      case 'entrada':
        return Colors.green;
      case 'saida':
        return Colors.red;
      case 'transferencia':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData get iconeTipo {
    switch (widget.tipo) {
      case 'entrada':
        return Icons.add_circle_outline;
      case 'saida':
        return Icons.remove_circle_outline;
      case 'transferencia':
        return Icons.swap_horiz;
      default:
        return Icons.edit;
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_itemId == null) {
      _showError('Selecione um item');
      return;
    }
    if (_localOrigemId == null) {
      _showError(isTransferencia ? 'Selecione o local de origem' : 'Selecione o local');
      return;
    }
    if (isTransferencia && _localDestinoId == null) {
      _showError('Selecione o local de destino');
      return;
    }
    if (isTransferencia && _localOrigemId == _localDestinoId) {
      _showError('Origem e destino não podem ser iguais');
      return;
    }

    setState(() => _saving = true);
    try {
      final qty = double.parse(_quantidadeCtrl.text.replaceAll(',', '.'));
      final obs = _observacaoCtrl.text.trim();
      bool ok;

      if (isEntrada) {
        ok = await _service.entrada(
          itemId: _itemId!,
          localId: _localOrigemId!,
          quantidade: qty,
          observacao: obs,
        );
      } else if (widget.tipo == 'saida') {
        ok = await _service.saida(
          itemId: _itemId!,
          localId: _localOrigemId!,
          quantidade: qty,
          observacao: obs,
        );
      } else {
        ok = await _service.transferencia(
          itemId: _itemId!,
          localOrigemId: _localOrigemId!,
          localDestinoId: _localDestinoId!,
          quantidade: qty,
          observacao: obs,
        );
      }

      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$titulo registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        _showError('Operação não foi concluída');
      }
    } catch (e) {
      _showError('Erro: $e');
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
  void dispose() {
    _quantidadeCtrl.dispose();
    _observacaoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final itens = widget.itemNomes.entries.toList();
    final locais = widget.localNomes.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
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
              // Cabeçalho do tipo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: corTipo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: corTipo.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(iconeTipo, color: corTipo, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: corTipo,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Item
              DropdownButtonFormField<String>(
                initialValue: _itemId,
                decoration: const InputDecoration(
                  labelText: 'Item *',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Selecione o item'),
                items: itens
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _itemId = v),
                validator: (v) => v == null ? 'Selecione um item' : null,
              ),
              const SizedBox(height: 16),

              // Local (origem para transferência)
              DropdownButtonFormField<String>(
                initialValue: _localOrigemId,
                decoration: InputDecoration(
                  labelText: isTransferencia ? 'Local de Origem *' : 'Local *',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: const OutlineInputBorder(),
                ),
                hint: Text(isTransferencia
                    ? 'Selecione a origem'
                    : 'Selecione o local'),
                items: locais
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _localOrigemId = v),
                validator: (v) => v == null ? 'Selecione o local' : null,
              ),

              // Local Destino (somente transferência)
              if (isTransferencia) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _localDestinoId,
                  decoration: const InputDecoration(
                    labelText: 'Local de Destino *',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Selecione o destino'),
                  items: locais
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _localDestinoId = v),
                  validator: (v) => v == null ? 'Selecione o destino' : null,
                ),
              ],
              const SizedBox(height: 16),

              // Quantidade
              TextFormField(
                controller: _quantidadeCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Quantidade *',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a quantidade';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Quantidade inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Observação
              TextFormField(
                controller: _observacaoCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observação',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Botão
              FilledButton.icon(
                onPressed: _saving ? null : _salvar,
                icon: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(iconeTipo),
                label: Text(
                  _saving ? 'Salvando...' : 'Confirmar $titulo',
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: corTipo,
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
