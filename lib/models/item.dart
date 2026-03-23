class Item {
  String? id;
  String nome;
  String descricao;
  String? categoriaId;
  String? unidadeId;

  Item({
    this.id,
    required this.nome,
    this.descricao = '',
    this.categoriaId,
    this.unidadeId,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      categoriaId: json['categoria_id'] ?? json['categoriaId'],
      unidadeId: json['unidade_id'] ?? json['unidadeId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'descricao': descricao,
        'categoria_id': categoriaId,
        'unidade_id': unidadeId,
      };

  @override
  String toString() => nome;
}
