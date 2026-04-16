// =============================================================
// lib/screens/main_screen.dart
//
// TELA PRINCIPAL (SHELL) — Navegação por abas
//
// Controla a NavigationBar inferior e qual tela está visível.
// As 3 abas correspondem às telas: Home, Listagem e Cadastro.
// O FAB (Floating Action Button) está aqui para ficar sempre
// visível independentemente da aba selecionada.
// =============================================================

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'listagem_screen.dart';
import 'cadastro_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Índice da aba atualmente selecionada (0 = Home)
  int _abaSelecionada = 0;

  // Lista das telas — cada índice corresponde a uma aba
  // Usar lista fixa mantém o estado das telas ao trocar de aba
  static const List<Widget> _telas = [
    HomeScreen(),     // índice 0
    ListagemScreen(), // índice 1
  ];

  // -----------------------------------------------------------
  // _abrirCadastro: abre a tela de cadastro como nova página
  // Ao voltar, pode atualizar a aba atual se necessário
  // -----------------------------------------------------------
  Future<void> _abrirCadastro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroScreen()),
    );
    // Força rebuild das telas para refletir nova receita
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Exibe a tela correspondente à aba selecionada
      body: IndexedStack(
        // IndexedStack mantém o estado de cada tela (não reconstrói ao trocar)
        index: _abaSelecionada,
        children: _telas,
      ),

      // ---- BARRA DE NAVEGAÇÃO INFERIOR ----
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaSelecionada,
        onDestinationSelected: (index) {
          setState(() => _abaSelecionada = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Receitas',
          ),
        ],
      ),

      // ---- BOTÃO FLUTUANTE PARA NOVA RECEITA ----
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        backgroundColor: AppCores.primaria,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nova Receita',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 4,
      ),
    );
  }
}
