import 'package:flutter/material.dart';
import '../models/unidade.dart';
import '../services/unidade_service.dart';
import 'unidade_form_screen.dart';

class UnidadeListScreen extends StatefulWidget {
  const UnidadeListScreen({super.key});

  @override
  State<UnidadeListScreen> createState() => _UnidadeListScreenState();
}

class _UnidadeListScreenState extends State<UnidadeListScreen> {
  final UnidadeService _service = UnidadeService();
  List<Unidade> _unidades = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final lista = await _service.getAll();
      setState(() => _unidades = lista);
    } catch (_) {
      _showError('Erro ao carregar unidades');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(Unidade unidade) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir a unidade "${unidade.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _service.delete(unidade.id!);
        _load();
      } catch (_) {
        _showError('Erro ao excluir unidade');
      }
    }
  }

  Future<void> _openForm([Unidade? unidade]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UnidadeFormScreen(unidade: unidade),
      ),
    );
    if (result == true) _load();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unidades'),
        centerTitle: true,
        backgroundColor: cs.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _unidades.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.straighten_outlined, size: 64, color: cs.outline),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma unidade cadastrada',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                  itemCount: _unidades.length,
                  itemBuilder: (_, index) {
                    final unidade = _unidades[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cs.secondaryContainer,
                          child: Icon(Icons.straighten, color: cs.onSecondaryContainer),
                        ),
                        title: Text(
                          unidade.nome,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openForm(unidade),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _delete(unidade),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}