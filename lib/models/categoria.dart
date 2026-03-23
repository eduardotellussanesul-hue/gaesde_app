class Categoria {
  String? id;
  String nome;

  Categoria({this.id, required this.nome});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nome: json['nome'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'nome': nome};

  @override
  String toString() => nome;
}