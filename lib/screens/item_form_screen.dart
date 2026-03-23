import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../models/item.dart';
import '../models/unidade.dart';
import '../services/categoria_service.dart';
import '../services/item_service.dart';
import '../services/unidade_service.dart';

class ItemFormScreen extends StatefulWidget {
  final Item? item;

  const ItemFormScreen({super.key, this.item});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final ItemService _service = ItemService();
  final CategoriaService _categoriaService = CategoriaService();
  final UnidadeService _unidadeService = UnidadeService();
  List<Categoria> _categorias = [];
  List<Unidade> _unidades = [];
  String? _categoriaId;
  String? _unidadeId;
  bool _saving = false;
  bool _loadingCategorias = true;
  bool _loadingUnidades = true;

  bool get isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nomeCtrl.text = widget.item!.nome;
      _descricaoCtrl.text = widget.item!.descricao;
      _categoriaId = widget.item!.categoriaId;
      _unidadeId = widget.item!.unidadeId;
    }
    _loadCategorias();
    _loadUnidades();
  }

  Future<void> _loadCategorias() async {
    try {
      final categorias = await _categoriaService.getAll();
      if (!mounted) return;
      setState(() {
        _categorias = categorias;
        _loadingCategorias = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCategorias = false);
    }
  }

  Future<void> _loadUnidades() async {
    try {
      final unidades = await _unidadeService.getAll();
      if (!mounted) return;
      setState(() {
        _unidades = unidades;
        _loadingUnidades = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingUnidades = false);
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = Item(
      nome: _nomeCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      categoriaId: _categoriaId,
      unidadeId: _unidadeId,
    );

    try {
      if (isEdit) {
        await _service.update(widget.item!.id!, item);
      } else {
        await _service.create(item);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Item' : 'Novo Item'),
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
              TextFormField(
                controller: _nomeCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categoriaId,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.tune),
                  border: OutlineInputBorder(),
                ),
                hint: _loadingCategorias
                    ? const Text('Carregando categorias...')
                    : const Text('Selecione a categoria'),
                items: _categorias
                    .where((categoria) => categoria.id != null)
                    .map(
                      (categoria) => DropdownMenuItem(
                        value: categoria.id!,
                        child: Text(categoria.nome),
                      ),
                    )
                    .toList(),
                onChanged: _loadingCategorias
                    ? null
                    : (value) => setState(() => _categoriaId = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _unidadeId,
                decoration: const InputDecoration(
                  labelText: 'Unidade *',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(),
                ),
                hint: _loadingUnidades
                    ? const Text('Carregando unidades...')
                    : const Text('Selecione a unidade'),
                items: _unidades
                    .where((unidade) => unidade.id != null)
                    .map(
                      (unidade) => DropdownMenuItem(
                        value: unidade.id!,
                        child: Text(unidade.nome),
                      ),
                    )
                    .toList(),
                onChanged: _loadingUnidades
                    ? null
                    : (value) => setState(() => _unidadeId = value),
                validator: (value) =>
                    value == null ? 'Selecione a unidade' : null,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _saving ? 'Salvando...' : isEdit ? 'Salvar' : 'Criar Item',
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
