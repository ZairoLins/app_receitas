// =============================================================
// lib/screens/home_screen.dart
//
// TELA INICIAL (HOME) — Tela 1
//
// Exibe:
//   - Saudação personalizada
//   - Carrossel das receitas em destaque
//   - Últimas receitas cadastradas
//
// COMUNICAÇÃO ENTRE TELAS:
//   Navigator.push() leva para a TelaDetalhe passando o objeto
//   Receita como argumento. Isso é a comunicação entre telas
//   exigida pelo trabalho.
// =============================================================

import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../widgets/carrossel_destaques.dart';
import '../widgets/receita_card.dart';
import 'detalhe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instância única do serviço de banco (Singleton)
  final _db = DatabaseService.instancia;

  // Listas carregadas do SQLite
  List<Receita> _destaques = [];
  List<Receita> _recentes = [];

  // Controla o estado de carregamento (exibe loading enquanto aguarda)
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    // Carrega os dados assim que a tela é criada
    _carregarDados();
  }

  // -----------------------------------------------------------
  // _carregarDados: busca destaques e receitas recentes do SQLite
  // -----------------------------------------------------------
  Future<void> _carregarDados() async {
    setState(() => _carregando = true);

    // Executa as duas queries em paralelo para performance
    final resultados = await Future.wait([
      _db.buscarDestaques(),
      _db.buscarTodas(),
    ]);

    setState(() {
      _destaques = resultados[0];
      // Pega só as 5 mais recentes para a seção "Últimas Receitas"
      _recentes = resultados[1].take(5).toList();
      _carregando = false;
    });
  }

  // -----------------------------------------------------------
  // _irParaDetalhe: COMUNICAÇÃO ENTRE TELAS
  // Navega para TelaDetalhe passando a receita selecionada.
  // O await aguarda o retorno (caso o usuário edite a receita).
  // -----------------------------------------------------------
  Future<void> _irParaDetalhe(Receita receita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalheScreen(receita: receita),
      ),
    );
    // Recarrega os dados ao voltar, caso haja mudanças
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // Arrastar para baixo recarrega os dados
              onRefresh: _carregarDados,
              child: CustomScrollView(
                slivers: [
                  // ---- APP BAR EXPANSÍVEL ----
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: true,
                    snap: true,
                    backgroundColor: AppCores.fundo,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Receitas Rápidas 🍽️',
                            style: TextStyle(
                              color: AppCores.textoEscuro,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'O que vamos cozinhar hoje?',
                            style: TextStyle(
                              color: AppCores.textoMedio,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ---- CONTEÚDO PRINCIPAL ----
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---- SEÇÃO: DESTAQUES (CARROSSEL) ----
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Text(
                            '⭐ Em Destaque',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppCores.textoEscuro,
                            ),
                          ),
                        ),

                        // Widget de carrossel (arquivo separado)
                        CarrosselDestaques(
                          receitas: _destaques,
                          // COMUNICAÇÃO: passa receita selecionada para cá
                          onTap: _irParaDetalhe,
                        ),

                        const SizedBox(height: 24),

                        // ---- SEÇÃO: ÚLTIMAS RECEITAS ----
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                          child: Text(
                            '🕐 Últimas Adicionadas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppCores.textoEscuro,
                            ),
                          ),
                        ),

                        // Lista de cards das receitas recentes
                        if (_recentes.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Nenhuma receita cadastrada ainda.\nUse o botão + para adicionar!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppCores.textoMedio),
                            ),
                          )
                        else
                          ListView.builder(
                            // ListView dentro de CustomScrollView precisa de shrinkWrap
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recentes.length,
                            itemBuilder: (context, index) {
                              final receita = _recentes[index];
                              return ReceitaCard(
                                receita: receita,
                                // COMUNICAÇÃO ENTRE TELAS via callback
                                onTap: () => _irParaDetalhe(receita),
                              );
                            },
                          ),

                        const SizedBox(height: 100), // Espaço para FAB
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
