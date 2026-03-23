class Estoque {
  String? id;
  String itemId;
  String localId;
  double quantidade;
  String? atualizadoEm;

  Estoque({
    this.id,
    required this.itemId,
    required this.localId,
    required this.quantidade,
    this.atualizadoEm,
  });

  factory Estoque.fromJson(Map<String, dynamic> json) {
    return Estoque(
      id: json['id'],
      itemId: json['item_id'] ?? json['itemId'] ?? '',
      localId: json['local_id'] ?? json['localId'] ?? '',
      quantidade: (json['quantidade'] ?? 0).toDouble(),
      atualizadoEm: json['atualizado_em'] ?? json['atualizadoEm'],
    );
  }
}
