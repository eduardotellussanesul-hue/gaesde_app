import 'package:flutter/material.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import 'local_form_screen.dart';

class LocalListScreen extends StatefulWidget {
  const LocalListScreen({super.key});

  @override
  State<LocalListScreen> createState() => _LocalListScreenState();
}

class _LocalListScreenState extends State<LocalListScreen> {
  final LocalService _service = LocalService();
  List<Local> _locais = [];
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
      setState(() => _locais = lista);
    } catch (e) {
      _showError('Erro ao carregar locais');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(Local local) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir o local "${local.nome}"?'),
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
        await _service.delete(local.id!);
        _load();
      } catch (e) {
        _showError('Erro ao excluir local');
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _openForm([Local? local]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LocalFormScreen(local: local)),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locais'),
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
          : _locais.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off_outlined,
                          size: 64, color: cs.outline),
                      const SizedBox(height: 12),
                      Text('Nenhum local cadastrado',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                  itemCount: _locais.length,
                  itemBuilder: (_, i) {
                    final local = _locais[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cs.secondaryContainer,
                          child: Icon(Icons.location_on,
                              color: cs.onSecondaryContainer),
                        ),
                        title: Text(local.nome,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openForm(local),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _delete(local),
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
