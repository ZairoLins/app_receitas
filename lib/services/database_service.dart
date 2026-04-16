// =============================================================
// lib/services/database_service.dart
//
// SERVIÇO DE BANCO DE DADOS SQLite
//
// Singleton que gerencia toda a comunicação com o SQLite.
// Usa sqflite.
// A tabela usa 'imagemPath' para armazenar o caminho local
// da foto selecionada da galeria pelo usuário.
// =============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/receita.dart';

class DatabaseService {
  // Padrão Singleton: garante uma única instância durante o app
  static final DatabaseService instancia = DatabaseService._interno();
  DatabaseService._interno();

  static Database? _banco;

  static const String _nomeBanco = 'receitas.db';
  static const int _versaoBanco = 1;
  static const String _tabela = 'receitas';

  // Getter com lazy initialization: abre o banco só quando necessário
  Future<Database> get banco async {
    if (_banco != null) return _banco!;
    _banco = await _inicializarBanco();
    return _banco!;
  }

  Future<Database> _inicializarBanco() async {
    final diretorio = await getDatabasesPath();
    final caminho = join(diretorio, _nomeBanco);

    return await openDatabase(
      caminho,
      version: _versaoBanco,
      onCreate: _criarTabela,
    );
  }

  // -----------------------------------------------------------
  // _criarTabela: DDL executado apenas na primeira abertura
  // Usa 'imagemPath' TEXT para armazenar caminho local da foto
  // -----------------------------------------------------------
  Future<void> _criarTabela(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE $_tabela (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        nome         TEXT    NOT NULL,
        ingredientes TEXT    NOT NULL,
        modoPreparo  TEXT    NOT NULL,
        categoria    TEXT    NOT NULL,
        tempoPreparo INTEGER NOT NULL,
        imagemPath   TEXT    NOT NULL DEFAULT '',
        destaque     INTEGER NOT NULL DEFAULT 0,
        dataCadastro TEXT    NOT NULL
      )
    ''');

    // Insere receitas de exemplo para o app não abrir vazio
    await _inserirDadosIniciais(db);
  }

  // -----------------------------------------------------------
  // Dados iniciais sem imagem (imagemPath vazio)
  // O usuário pode editar e adicionar fotos depois
  // -----------------------------------------------------------
  Future<void> _inserirDadosIniciais(Database db) async {
    final agora = DateTime.now().toIso8601String();

    final receitas = [
      {
        'nome': 'Macarrão ao Alho e Óleo',
        'ingredientes':
            '500g de macarrão espaguete|6 dentes de alho picados|5 colheres de azeite|Salsinha picada a gosto|Sal e pimenta-do-reino|Queijo parmesão ralado',
        'modoPreparo':
            '1. Cozinhe o macarrão em água salgada conforme o pacote.\n2. Aqueça o azeite e doure o alho em fogo baixo.\n3. Escorra o macarrão e misture com o alho.\n4. Finalize com salsinha e parmesão.',
        'categoria': 'Almoço',
        'tempoPreparo': 20,
        'imagemPath': '/assets/images/macarraoalhoeoleo.jpg',
        'destaque': 1,
        'dataCadastro': agora,
      },
      {
        'nome': 'Omelete de Queijo',
        'ingredientes':
            '3 ovos|2 fatias de presunto picado|2 col. queijo mussarela|1 col. manteiga|Sal e pimenta|Cebolinha picada',
        'modoPreparo':
            '1. Bata os ovos com sal e pimenta.\n2. Aqueça a frigideira com manteiga.\n3. Despeje os ovos e deixe firmar.\n4. Adicione presunto e queijo em metade.\n5. Dobre e tampe por 1 minuto.',
        'categoria': 'Café da Manhã',
        'tempoPreparo': 10,
        'imagemPath': '/assets/images/omeletedeovo.jpg',
        'destaque': 1,
        'dataCadastro': agora,
      },
      {
        'nome': 'Bolo de Caneca',
        'ingredientes':
            '4 col. farinha de trigo|4 col. açúcar|2 col. cacau em pó|1 ovo|3 col. leite|3 col. óleo|1 pitada de fermento',
        'modoPreparo':
            '1. Misture todos os ingredientes secos na caneca.\n2. Adicione ovo, leite e óleo e misture bem.\n3. Micro-ondas por 2 a 3 minutos na potência alta.\n4. Espere 1 minuto antes de comer.',
        'categoria': 'Sobremesa',
        'tempoPreparo': 5,
        'imagemPath': '/assets/images/bolodecaneca.jpg',
        'destaque': 1,
        'dataCadastro': agora,
      },
      {
        'nome': 'Arroz com Frango Simples',
        'ingredientes':
            '2 xícaras de arroz|500g de frango em cubos|1 cebola picada|3 dentes de alho|Sal, pimenta e colorau|Azeite a gosto',
        'modoPreparo':
            '1. Tempere o frango com sal, pimenta e alho.\n2. Frite no azeite até dourar.\n3. Retire e refogue cebola e alho na mesma panela.\n4. Adicione arroz, frite 2 min e adicione água quente.\n5. Devolva o frango e cozinhe até o arroz secar.',
        'categoria': 'Almoço',
        'tempoPreparo': 35,
        'imagemPath': '/assets/images/arrozcomfrango.jpg',
        'destaque': 0,
        'dataCadastro': agora,
      },
      {
        'nome': 'Vitamina de Banana',
        'ingredientes':
            '2 bananas maduras|200ml de leite|2 col. mel|1 col. aveia|Canela a gosto|Gelo a gosto',
        'modoPreparo':
            '1. Coloque todos os ingredientes no liquidificador.\n2. Bata por 1 a 2 minutos até ficar homogêneo.\n3. Sirva gelado imediatamente.',
        'categoria': 'Bebida',
        'tempoPreparo': 5,
        'imagemPath': '/assets/images/vitaminadebanana.jpg',
        'destaque': 0,
        'dataCadastro': agora,
      },
    ];

    final batch = db.batch();
    for (final r in receitas) {
      batch.insert(_tabela, r);
    }
    await batch.commit(noResult: true);
  }

  // ===========================================================
  // CRUD
  // ===========================================================

  // INSERT — retorna o ID gerado pelo auto-increment
  Future<int> inserirReceita(Receita receita) async {
    final db = await banco;
    return await db.insert(
      _tabela,
      receita.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // SELECT ALL — ordenado do mais recente para o mais antigo
  Future<List<Receita>> buscarTodas() async {
    final db = await banco;
    final resultado = await db.query(_tabela, orderBy: 'id DESC');
    return resultado.map((m) => Receita.fromMap(m)).toList();
  }

  // SELECT WHERE destaque = 1 — usado no carrossel da Home
  Future<List<Receita>> buscarDestaques() async {
    final db = await banco;
    final resultado = await db.query(
      _tabela,
      where: 'destaque = ?',
      whereArgs: [1],
    );
    return resultado.map((m) => Receita.fromMap(m)).toList();
  }

  // SELECT WHERE id = ?
  Future<Receita?> buscarPorId(int id) async {
    final db = await banco;
    final resultado = await db.query(
      _tabela,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (resultado.isEmpty) return null;
    return Receita.fromMap(resultado.first);
  }

  // SELECT WHERE nome LIKE ? OR categoria LIKE ?
  Future<List<Receita>> pesquisar(String termo) async {
    final db = await banco;
    final resultado = await db.query(
      _tabela,
      where: 'nome LIKE ? OR categoria LIKE ?',
      whereArgs: ['%$termo%', '%$termo%'],
      orderBy: 'nome ASC',
    );
    return resultado.map((m) => Receita.fromMap(m)).toList();
  }

  // UPDATE — retorna número de linhas afetadas
  Future<int> atualizarReceita(Receita receita) async {
    final db = await banco;
    return await db.update(
      _tabela,
      receita.toMap(),
      where: 'id = ?',
      whereArgs: [receita.id],
    );
  }

  // DELETE WHERE id = ?
  Future<int> deletarReceita(int id) async {
    final db = await banco;
    return await db.delete(_tabela, where: 'id = ?', whereArgs: [id]);
  }
}
