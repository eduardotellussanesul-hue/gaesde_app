class Usuario {
  String? id;
  String nome;
  String senha;
  String email;
  String tipoDeUsuario;
  String? createdAt;

  Usuario({
    this.id,
    required this.nome,
    required this.senha,
    required this.email,
    required this.tipoDeUsuario,
    this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'] ?? '',
      senha: json['senha'] ?? '',
      email: json['email'] ?? '',
      tipoDeUsuario: json['tipoDeUsuario'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'senha': senha,
      'email': email,
      'tipoDeUsuario': tipoDeUsuario,
    };
  }
}
