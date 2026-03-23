class Unidade {
  String? id;
  String nome;

  Unidade({this.id, required this.nome});

  factory Unidade.fromJson(Map<String, dynamic> json) {
    return Unidade(
      id: json['id'],
      nome: json['nome'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'nome': nome};

  @override
  String toString() => nome;
}