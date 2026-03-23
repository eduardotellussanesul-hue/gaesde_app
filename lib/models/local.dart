class Local {
  String? id;
  String nome;

  Local({this.id, required this.nome});

  factory Local.fromJson(Map<String, dynamic> json) {
    return Local(
      id: json['id'],
      nome: json['nome'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'nome': nome};

  @override
  String toString() => nome;
}
