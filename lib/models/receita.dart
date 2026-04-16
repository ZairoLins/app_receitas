// =============================================================
// lib/models/receita.dart
// =============================================================

class Receita {
  final int? id;
  final String nome;
  // Ingredientes separados por '|' (SQLite não suporta listas nativas)
  final String ingredientes;
  final String modoPreparo;
  final String categoria;
  final int tempoPreparo;
  // Caminho local da imagem selecionada da galeria
  final String imagemPath;
  // 1 = destaque no carrossel, 0 = normal
  final int destaque;
  final String dataCadastro;

  const Receita({
    this.id,
    required this.nome,
    required this.ingredientes,
    required this.modoPreparo,
    required this.categoria,
    required this.tempoPreparo,
    this.imagemPath = '',
    this.destaque = 0,
    required this.dataCadastro,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nome': nome,
      'ingredientes': ingredientes,
      'modoPreparo': modoPreparo,
      'categoria': categoria,
      'tempoPreparo': tempoPreparo,
      'imagemPath': imagemPath,
      'destaque': destaque,
      'dataCadastro': dataCadastro,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      ingredientes: map['ingredientes'] as String,
      modoPreparo: map['modoPreparo'] as String,
      categoria: map['categoria'] as String,
      tempoPreparo: map['tempoPreparo'] as int,
      imagemPath: map['imagemPath'] as String? ?? '',
      destaque: map['destaque'] as int,
      dataCadastro: map['dataCadastro'] as String,
    );
  }

  Receita copyWith({
    int? id,
    String? nome,
    String? ingredientes,
    String? modoPreparo,
    String? categoria,
    int? tempoPreparo,
    String? imagemPath,
    int? destaque,
    String? dataCadastro,
  }) {
    return Receita(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      ingredientes: ingredientes ?? this.ingredientes,
      modoPreparo: modoPreparo ?? this.modoPreparo,
      categoria: categoria ?? this.categoria,
      tempoPreparo: tempoPreparo ?? this.tempoPreparo,
      imagemPath: imagemPath ?? this.imagemPath,
      destaque: destaque ?? this.destaque,
      dataCadastro: dataCadastro ?? this.dataCadastro,
    );
  }

  List<String> get listaIngredientes =>
      ingredientes.split('|').where((s) => s.isNotEmpty).toList();

  bool get isDestaque => destaque == 1;
  bool get temImagem => imagemPath.isNotEmpty;
}
