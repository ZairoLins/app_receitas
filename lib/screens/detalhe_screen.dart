// =============================================================
// lib/screens/detalhe_screen.dart
//
// TELA DE DETALHES — Tela 3
//
// Exibe todos os dados de uma receita:
//   - Imagem em destaque (hero animation)
//   - Nome, categoria e tempo
//   - Lista de ingredientes
//   - Modo de preparo
//   - Botões de editar e excluir
//
// COMUNICAÇÃO ENTRE TELAS:
//   Recebe um objeto Receita via construtor (argumento passado
//   pela tela anterior). Ao editar, navega para CadastroScreen
//   passando a receita existente como argumento.
// =============================================================

import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../services/database_service.dart';
import 'dart:io';
import '../utils/app_theme.dart';
import 'cadastro_screen.dart';

class DetalheScreen extends StatefulWidget {
  // COMUNICAÇÃO: receita recebida da tela anterior como argumento
  final Receita receita;

  const DetalheScreen({super.key, required this.receita});

  @override
  State<DetalheScreen> createState() => _DetalheScreenState();
}

class _DetalheScreenState extends State<DetalheScreen> {
  final _db = DatabaseService.instancia;

  // Cópia local que pode ser atualizada após edição
  late Receita _receita;

  @override
  void initState() {
    super.initState();
    _receita = widget.receita;
  }

  // -----------------------------------------------------------
  // _editarReceita: navega para CadastroScreen em modo de edição
  // Passa a receita atual como argumento para pré-preencher o form
  // -----------------------------------------------------------
  Future<void> _editarReceita() async {
    final receitaEditada = await Navigator.push<Receita>(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroScreen(receitaParaEditar: _receita),
      ),
    );

    // Se voltou com uma receita editada, atualiza a tela
    if (receitaEditada != null) {
      setState(() => _receita = receitaEditada);
    }
  }

  // -----------------------------------------------------------
  // _excluirReceita: deleta do banco e volta para a tela anterior
  // -----------------------------------------------------------
  Future<void> _excluirReceita() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Receita'),
        content: Text('Deseja excluir "${_receita.nome}"?'),
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

    if (confirmar == true && _receita.id != null) {
      await _db.deletarReceita(_receita.id!);
      if (mounted) Navigator.pop(context); // Volta para a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ---- APP BAR COM IMAGEM EXPANSÍVEL ----
          SliverAppBar(
            expandedHeight: 280,
            pinned: true, // AppBar fica visível ao rolar
            backgroundColor: AppCores.textoEscuro,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Botão de editar
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: _editarReceita,
                tooltip: 'Editar receita',
              ),
              // Botão de excluir
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: _excluirReceita,
                tooltip: 'Excluir receita',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ---- IMAGEM PRINCIPAL DA RECEITA (arquivo local) ----
                  _receita.temImagem
                      ? Image.file(
                          File(_receita.imagemPath),
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _semImagem(),
                        )
                      : _semImagem(),
                  // Gradiente para escurecer base da imagem
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- CONTEÚDO PRINCIPAL ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- NOME DA RECEITA ----
                  Text(
                    _receita.nome,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppCores.textoEscuro,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- BADGES: CATEGORIA, TEMPO E DESTAQUE ----
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge(
                        Icons.category_outlined,
                        _receita.categoria,
                        AppCores.corDaCategoria(_receita.categoria),
                      ),
                      _buildBadge(
                        Icons.timer_outlined,
                        '${_receita.tempoPreparo} minutos',
                        AppCores.secundaria,
                      ),
                      if (_receita.isDestaque)
                        _buildBadge(
                          Icons.star,
                          'Em Destaque',
                          AppCores.primaria,
                        ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ---- SEÇÃO: INGREDIENTES ----
                  _buildTituloSecao('🛒 Ingredientes'),
                  const SizedBox(height: 12),
                  // Itera sobre a lista de ingredientes da receita
                  ..._receita.listaIngredientes.map((ingrediente) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bolinha colorida como marcador
                          Container(
                            margin: const EdgeInsets.only(top: 6, right: 10),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppCores.primaria,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ingrediente,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppCores.textoEscuro,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 28),

                  // ---- SEÇÃO: MODO DE PREPARO ----
                  _buildTituloSecao('👨‍🍳 Modo de Preparo'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppCores.fundo,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      _receita.modoPreparo,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppCores.textoEscuro,
                        height: 1.7, // Espaçamento entre linhas para legibilidade
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ---- DATA DE CADASTRO ----
                  Text(
                    'Cadastrada em: ${_formatarData(_receita.dataCadastro)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppCores.textoClaro,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // _buildBadge: widget auxiliar para os chips de informação
  // -----------------------------------------------------------
  Widget _buildBadge(IconData icone, String texto, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: cor),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              color: cor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // _buildTituloSecao: título estilizado para cada seção
  // -----------------------------------------------------------
  Widget _buildTituloSecao(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppCores.textoEscuro,
      ),
    );
  }

  // -----------------------------------------------------------
  // _formatarData: converte ISO 8601 para formato legível
  // -----------------------------------------------------------
  String _formatarData(String isoString) {
    try {
      final data = DateTime.parse(isoString);
      return '${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}/'
          '${data.year}';
    } catch (_) {
      return isoString;
    }
  }

  Widget _semImagem() {
    return Container(
      color: AppCores.fundo,
      child: const Center(
        child: Icon(Icons.restaurant, size: 80, color: AppCores.textoClaro),
      ),
    );
  }
}
