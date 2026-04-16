// =============================================================
// lib/screens/listagem_screen.dart
//
// TELA DE LISTAGEM — Tela 2
//
// Lista todas as receitas do banco com opções de:
//   - Pesquisa por nome ou categoria
//   - Filtro por categoria (chips clicáveis)
//   - Exclusão de receita com confirmação
//   - Navegação para detalhes ao tocar no card
// =============================================================

import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../widgets/receita_card.dart';
import 'detalhe_screen.dart';

class ListagemScreen extends StatefulWidget {
  const ListagemScreen({super.key});

  @override
  State<ListagemScreen> createState() => _ListagemScreenState();
}

class _ListagemScreenState extends State<ListagemScreen> {
  final _db = DatabaseService.instancia;

  // Controller do campo de pesquisa
  final _pesquisaController = TextEditingController();

  // Todas as receitas do banco (sem filtro)
  List<Receita> _todasReceitas = [];

  // Receitas exibidas (após filtro de categoria e pesquisa)
  List<Receita> _receitasFiltradas = [];

  // Categoria selecionada no filtro (null = todas)
  String? _categoriaSelecionada;

  bool _carregando = true;

  // Categorias disponíveis para filtro
  static const List<String> _categorias = [
    'Café da Manhã',
    'Almoço',
    'Jantar',
    'Sobremesa',
    'Bebida',
    'Lanche',
  ];

  @override
  void initState() {
    super.initState();
    _carregarReceitas();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _carregarReceitas() async {
    setState(() => _carregando = true);
    final receitas = await _db.buscarTodas();
    setState(() {
      _todasReceitas = receitas;
      _aplicarFiltros();
      _carregando = false;
    });
  }

  // -----------------------------------------------------------
  // _aplicarFiltros: filtra a lista combinando texto + categoria
  // -----------------------------------------------------------
  void _aplicarFiltros() {
    var resultado = List<Receita>.from(_todasReceitas);

    // Filtro por categoria
    if (_categoriaSelecionada != null) {
      resultado = resultado
          .where((r) => r.categoria == _categoriaSelecionada)
          .toList();
    }

    // Filtro por texto de pesquisa
    final texto = _pesquisaController.text.trim().toLowerCase();
    if (texto.isNotEmpty) {
      resultado = resultado.where((r) {
        return r.nome.toLowerCase().contains(texto) ||
            r.categoria.toLowerCase().contains(texto);
      }).toList();
    }

    setState(() => _receitasFiltradas = resultado);
  }

  // -----------------------------------------------------------
  // _confirmarDelecao: exibe diálogo antes de deletar
  // -----------------------------------------------------------
  Future<void> _confirmarDelecao(Receita receita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Receita'),
        content: Text(
          'Tem certeza que deseja excluir "${receita.nome}"?\nEssa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppCores.erro),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true && receita.id != null) {
      await _db.deletarReceita(receita.id!);
      _carregarReceitas(); // Recarrega a lista após deletar

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${receita.nome}" excluída com sucesso.'),
            backgroundColor: AppCores.sucesso,
          ),
        );
      }
    }
  }

  // -----------------------------------------------------------
  // _irParaDetalhe: navega para a tela de detalhes
  // -----------------------------------------------------------
  Future<void> _irParaDetalhe(Receita receita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalheScreen(receita: receita)),
    );
    _carregarReceitas(); // Atualiza caso tenha editado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
        actions: [
          // Badge com contagem de receitas
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_receitasFiltradas.length} receita(s)',
                style: const TextStyle(
                  color: AppCores.textoMedio,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ---- CAMPO DE PESQUISA ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _pesquisaController,
              onChanged: (_) => _aplicarFiltros(), // Filtra em tempo real
              decoration: const InputDecoration(
                hintText: 'Pesquisar receita...',
                prefixIcon: Icon(Icons.search, color: AppCores.textoMedio),
                suffixIcon: null,
              ),
            ),
          ),

          // ---- CHIPS DE FILTRO POR CATEGORIA ----
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Chip "Todas" para remover o filtro
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todas'),
                    selected: _categoriaSelecionada == null,
                    onSelected: (_) {
                      setState(() => _categoriaSelecionada = null);
                      _aplicarFiltros();
                    },
                    selectedColor: AppCores.primaria.withOpacity(0.2),
                    checkmarkColor: AppCores.primaria,
                    labelStyle: TextStyle(
                      color: _categoriaSelecionada == null
                          ? AppCores.primaria
                          : AppCores.textoMedio,
                      fontWeight: _categoriaSelecionada == null
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ),

                // Chips de cada categoria
                ..._categorias.map((cat) {
                  final selecionado = _categoriaSelecionada == cat;
                  final cor = AppCores.corDaCategoria(cat);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: selecionado,
                      onSelected: (_) {
                        setState(() {
                          _categoriaSelecionada = selecionado ? null : cat;
                        });
                        _aplicarFiltros();
                      },
                      selectedColor: cor.withOpacity(0.2),
                      checkmarkColor: cor,
                      labelStyle: TextStyle(
                        color: selecionado ? cor : AppCores.textoMedio,
                        fontWeight: selecionado
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1),

          // ---- LISTA DE RECEITAS ----
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _receitasFiltradas.isEmpty
                    ? _buildEstadoVazio()
                    : RefreshIndicator(
                        onRefresh: _carregarReceitas,
                        child: ListView.builder(
                          itemCount: _receitasFiltradas.length,
                          itemBuilder: (context, index) {
                            final receita = _receitasFiltradas[index];
                            return ReceitaCard(
                              receita: receita,
                              onTap: () => _irParaDetalhe(receita),
                              // Passa callback de deletar para o card
                              onDeletar: () => _confirmarDelecao(receita),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // _buildEstadoVazio: exibido quando não há resultados
  // -----------------------------------------------------------
  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppCores.textoClaro),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma receita encontrada.',
            style: TextStyle(
              color: AppCores.textoMedio,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente outro termo ou categoria.',
            style: TextStyle(color: AppCores.textoClaro, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
