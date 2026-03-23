import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../models/estoque.dart';
import '../models/item.dart';
import '../models/local.dart';
import '../services/categoria_service.dart';
import '../services/estoque_service.dart';
import '../services/item_service.dart';
import '../services/local_service.dart';
import 'estoque_form_screen.dart';
import 'estoque_movimentacao_screen.dart';

class EstoqueListScreen extends StatefulWidget {
  const EstoqueListScreen({super.key});

  @override
  State<EstoqueListScreen> createState() => _EstoqueListScreenState();
}

class _EstoqueListScreenState extends State<EstoqueListScreen> {
  final TextEditingController _buscaCtrl = TextEditingController();
  final CategoriaService _categoriaService = CategoriaService();
  final EstoqueService _estoqueService = EstoqueService();
  final ItemService _itemService = ItemService();
  final LocalService _localService = LocalService();

  List<Estoque> _estoques = [];
  List<Categoria> _categorias = [];
  Map<String, Item> _itensPorId = {};
  Map<String, String> _itemNomes = {};
  Map<String, String> _localNomes = {};
  bool _loading = true;
  bool _filtroBaixo = false;
  String _busca = '';
  String? _categoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _buscaCtrl.addListener(() {
      setState(() => _busca = _buscaCtrl.text.trim().toLowerCase());
    });
    _load();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _estoqueService.getAll(),
        _itemService.getAll(),
        _localService.getAll(),
        _categoriaService.getAll(),
      ]);

      final estoques = results[0] as List<Estoque>;
      final itens = results[1] as List<Item>;
      final locais = results[2] as List<Local>;
      final categorias = results[3] as List<Categoria>;

      setState(() {
        _estoques = estoques;
        _categorias = categorias;
        _itensPorId = {
          for (final item in itens)
            if (item.id != null) item.id!: item,
        };
        _itemNomes = {for (final i in itens) i.id!: i.nome};
        _localNomes = {for (final l in locais) l.id!: l.nome};
      });
    } catch (e) {
      _showError('Erro ao carregar estoque: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _abrirMovimentacao(String tipo) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EstoqueMovimentacaoScreen(
          tipo: tipo,
          itemNomes: _itemNomes,
          localNomes: _localNomes,
        ),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _abrirNovoEstoque() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EstoqueFormScreen(
          itemNomes: _itemNomes,
          localNomes: _localNomes,
        ),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _deleteEstoque(Estoque estoque) async {
    final itemNome = _itemNomes[estoque.itemId] ?? estoque.itemId;
    final localNome = _localNomes[estoque.localId] ?? estoque.localId;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir estoque'),
        content: Text(
          'Deseja excluir o estoque de "$itemNome" em "$localNome"?',
        ),
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
        await _estoqueService.delete(estoque.id!);
        _load();
      } catch (e) {
        _showError('Erro ao excluir estoque: $e');
      }
    }
  }

  void _mostrarOpcoes() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'O que deseja registrar?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _opcaoTile(
              icon: Icons.add_box_outlined,
              color: Colors.indigo,
              titulo: 'Novo estoque',
              subtitulo: 'Criar registro direto no estoque',
              onTap: () {
                Navigator.pop(context);
                _abrirNovoEstoque();
              },
            ),
            _opcaoTile(
              icon: Icons.add_circle_outline,
              color: Colors.green,
              titulo: 'Entrada',
              subtitulo: 'Adicionar itens ao estoque',
              onTap: () {
                Navigator.pop(context);
                _abrirMovimentacao('entrada');
              },
            ),
            _opcaoTile(
              icon: Icons.remove_circle_outline,
              color: Colors.red,
              titulo: 'Saída',
              subtitulo: 'Retirar itens do estoque',
              onTap: () {
                Navigator.pop(context);
                _abrirMovimentacao('saida');
              },
            ),
            _opcaoTile(
              icon: Icons.swap_horiz,
              color: Colors.blue,
              titulo: 'Transferência',
              subtitulo: 'Mover entre locais',
              onTap: () {
                Navigator.pop(context);
                _abrirMovimentacao('transferencia');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _opcaoTile({
    required IconData icon,
    required Color color,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitulo),
      onTap: onTap,
    );
  }

  List<Estoque> get _estoquesFiltrados {
    return _estoques.where((estoque) {
      final item = _itensPorId[estoque.itemId];
      final itemNome = (_itemNomes[estoque.itemId] ?? '').toLowerCase();
      final localNome = (_localNomes[estoque.localId] ?? '').toLowerCase();
      final atendeBusca = _busca.isEmpty ||
          itemNome.contains(_busca) ||
          localNome.contains(_busca) ||
          estoque.itemId.toLowerCase().contains(_busca);
      final atendeCategoria = _categoriaSelecionada == null ||
          item?.categoriaId == _categoriaSelecionada;
      final atendeBaixo = !_filtroBaixo || estoque.quantidade <= 5;

      return atendeBusca && atendeCategoria && atendeBaixo;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtrados = _estoquesFiltrados;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque'),
        centerTitle: true,
        backgroundColor: cs.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarOpcoes,
        icon: const Icon(Icons.add),
        label: const Text('Movimentação'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFiltro(cs),
                if (filtrados.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: cs.outline),
                          const SizedBox(height: 12),
                          Text(
                            _filtroBaixo
                                ? 'Nenhum item com estoque baixo'
                                : 'Nenhum estoque registrado',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                      itemCount: filtrados.length,
                      itemBuilder: (_, i) => _buildCard(filtrados[i], cs),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildFiltro(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _buscaCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar item ou local no estoque',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _busca.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => _buscaCtrl.clear(),
                      icon: const Icon(Icons.close),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Estoque baixo'),
                  selected: _filtroBaixo,
                  avatar: Icon(
                    Icons.warning_amber_outlined,
                    size: 18,
                    color:
                        _filtroBaixo ? cs.onSecondaryContainer : cs.outline,
                  ),
                  onSelected: (v) => setState(() => _filtroBaixo = v),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Todas categorias'),
                  selected: _categoriaSelecionada == null,
                  onSelected: (_) => setState(() => _categoriaSelecionada = null),
                ),
                for (final categoria in _categorias)
                  if (categoria.id != null) ...[
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(categoria.nome),
                      selected: _categoriaSelecionada == categoria.id,
                      onSelected: (_) => setState(
                        () => _categoriaSelecionada = categoria.id,
                      ),
                    ),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_estoquesFiltrados.length} registro(s)',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Estoque e, ColorScheme cs) {
    final itemNome = _itemNomes[e.itemId] ?? e.itemId;
    final localNome = _localNomes[e.localId] ?? e.localId;
    final categoriaNome = _categorias
        .firstWhere(
          (categoria) => categoria.id == _itensPorId[e.itemId]?.categoriaId,
          orElse: () => Categoria(nome: 'Sem categoria'),
        )
        .nome;
    final baixo = e.quantidade <= 5;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: baixo
              ? Colors.red.withValues(alpha: 0.15)
              : Colors.green.withValues(alpha: 0.15),
          radius: 24,
          child: Icon(
            Icons.inventory_2_rounded,
            color: baixo ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          itemNome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localNome, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    categoriaNome,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  e.quantidade.toStringAsFixed(
                    e.quantidade == e.quantidade.truncateToDouble() ? 0 : 2,
                  ),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: baixo ? Colors.red : cs.primary,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'delete' && e.id != null) {
                      _deleteEstoque(e);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir estoque'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (baixo)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'baixo',
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
