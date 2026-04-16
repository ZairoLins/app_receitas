// =============================================================
// lib/screens/cadastro_screen.dart
//
// TELA DE CADASTRO E EDIÇÃO — Tela 4
//
// Formulário para cadastrar ou editar receita.
// Usa image_picker para selecionar foto da GALERIA do celular.
// A imagem selecionada é salva como caminho local (imagemPath).
// =============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // Seleção da galeria
import '../models/receita.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class CadastroScreen extends StatefulWidget {
  final Receita? receitaParaEditar;

  const CadastroScreen({super.key, this.receitaParaEditar});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _db = DatabaseService.instancia;
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _modoPreparoCtrl = TextEditingController();
  final _tempoCtrl = TextEditingController();
  final List<TextEditingController> _ingredientesCtrl = [];

  String _categoriaSelecionada = 'Almoço';
  bool _destaque = false;
  bool _salvando = false;

  // Caminho da imagem selecionada da galeria
  String _imagemPath = '';

  // Instância do image_picker
  final ImagePicker _picker = ImagePicker();

  bool get _modoEdicao => widget.receitaParaEditar != null;

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
    if (_modoEdicao) {
      final r = widget.receitaParaEditar!;
      _nomeCtrl.text = r.nome;
      _modoPreparoCtrl.text = r.modoPreparo;
      _tempoCtrl.text = r.tempoPreparo.toString();
      _categoriaSelecionada = r.categoria;
      _destaque = r.isDestaque;
      _imagemPath = r.imagemPath;
      for (final ing in r.listaIngredientes) {
        _ingredientesCtrl.add(TextEditingController(text: ing));
      }
    } else {
      for (int i = 0; i < 3; i++) {
        _ingredientesCtrl.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _modoPreparoCtrl.dispose();
    _tempoCtrl.dispose();
    for (final c in _ingredientesCtrl) c.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------
  // _selecionarImagem: abre a galeria e salva o caminho local
  // image_picker retorna XFile com o path do arquivo no device
  // -----------------------------------------------------------
  Future<void> _selecionarImagem() async {
    // Mostra bottom sheet para escolher galeria ou câmera
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Adicionar Foto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Opção: Galeria
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppCores.primaria.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.photo_library,
                                size: 36, color: AppCores.primaria),
                            SizedBox(height: 8),
                            Text('Galeria',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppCores.primaria)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Opção: Câmera
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppCores.secundaria.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.camera_alt,
                                size: 36, color: AppCores.secundaria),
                            SizedBox(height: 8),
                            Text('Câmera',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppCores.secundaria)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (origem == null) return; // Usuário fechou sem escolher

    try {
      // Abre galeria ou câmera conforme escolha
      // imageQuality: comprime para 80% para não ocupar muito espaço
      final XFile? imagem = await _picker.pickImage(
        source: origem,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (imagem != null) {
        // Salva o caminho absoluto do arquivo no dispositivo
        setState(() => _imagemPath = imagem.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível acessar a galeria.'),
            backgroundColor: AppCores.erro,
          ),
        );
      }
    }
  }

  // -----------------------------------------------------------
  // _salvarReceita: valida o form e persiste no SQLite
  // -----------------------------------------------------------
  Future<void> _salvarReceita() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final ingredientesTexto = _ingredientesCtrl
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .join('|');

    if (ingredientesTexto.isEmpty) {
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um ingrediente.'),
          backgroundColor: AppCores.erro,
        ),
      );
      return;
    }

    final agora = DateTime.now().toIso8601String();
    Receita receita;

    if (_modoEdicao) {
      receita = widget.receitaParaEditar!.copyWith(
        nome: _nomeCtrl.text.trim(),
        ingredientes: ingredientesTexto,
        modoPreparo: _modoPreparoCtrl.text.trim(),
        categoria: _categoriaSelecionada,
        tempoPreparo: int.parse(_tempoCtrl.text.trim()),
        imagemPath: _imagemPath,
        destaque: _destaque ? 1 : 0,
      );
      await _db.atualizarReceita(receita);
    } else {
      receita = Receita(
        nome: _nomeCtrl.text.trim(),
        ingredientes: ingredientesTexto,
        modoPreparo: _modoPreparoCtrl.text.trim(),
        categoria: _categoriaSelecionada,
        tempoPreparo: int.parse(_tempoCtrl.text.trim()),
        imagemPath: _imagemPath,
        destaque: _destaque ? 1 : 0,
        dataCadastro: agora,
      );
      final novoId = await _db.inserirReceita(receita);
      receita = (await _db.buscarPorId(novoId)) ?? receita;
    }

    setState(() => _salvando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _modoEdicao ? 'Receita atualizada!' : 'Receita cadastrada!'),
          backgroundColor: AppCores.sucesso,
        ),
      );
      // COMUNICAÇÃO: retorna a receita salva para a tela anterior
      Navigator.pop(context, receita);
    }
  }

  void _adicionarIngrediente() {
    setState(() => _ingredientesCtrl.add(TextEditingController()));
  }

  void _removerIngrediente(int index) {
    if (_ingredientesCtrl.length > 1) {
      _ingredientesCtrl[index].dispose();
      setState(() => _ingredientesCtrl.removeAt(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modoEdicao ? 'Editar Receita' : 'Nova Receita'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ---- SELETOR DE IMAGEM DA GALERIA ----
            _buildSeletorImagem(),
            const SizedBox(height: 20),

            // ---- NOME ----
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome da Receita *',
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o nome';
                if (v.trim().length < 3) return 'Nome muito curto';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ---- CATEGORIA + TEMPO ----
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _categoriaSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categorias
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _categoriaSelecionada = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _tempoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tempo (min)',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obrigatório';
                      if ((int.tryParse(v) ?? 0) <= 0) return 'Inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---- SWITCH DESTAQUE ----
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SwitchListTile(
                title: const Text('Colocar em Destaque',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Aparece no carrossel da tela inicial',
                    style: TextStyle(fontSize: 12)),
                value: _destaque,
                onChanged: (v) => setState(() => _destaque = v),
                activeColor: AppCores.primaria,
              ),
            ),
            const SizedBox(height: 24),

            // ---- INGREDIENTES ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ingredientes',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppCores.textoEscuro)),
                TextButton.icon(
                  onPressed: _adicionarIngrediente,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar'),
                  style:
                      TextButton.styleFrom(foregroundColor: AppCores.primaria),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...List.generate(_ingredientesCtrl.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppCores.primaria.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${index + 1}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppCores.primaria,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _ingredientesCtrl[index],
                        decoration: InputDecoration(
                          hintText: 'Ex: 2 xícaras de farinha',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    if (_ingredientesCtrl.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: AppCores.erro, size: 20),
                        onPressed: () => _removerIngrediente(index),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // ---- MODO DE PREPARO ----
            const Text('Modo de Preparo',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppCores.textoEscuro)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _modoPreparoCtrl,
              decoration: const InputDecoration(
                hintText: 'Descreva o passo a passo...',
              ),
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Informe o modo de preparo';
                if (v.trim().length < 10) return 'Descrição muito curta';
                return null;
              },
            ),

            const SizedBox(height: 32),

            // ---- BOTÃO SALVAR ----
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvarReceita,
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _modoEdicao
                            ? 'Salvar Alterações'
                            : 'Cadastrar Receita',
                        style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // _buildSeletorImagem: área de preview + botão para abrir galeria
  // Implementa o requisito de "inclusão de imagem"
  // -----------------------------------------------------------
  Widget _buildSeletorImagem() {
    return GestureDetector(
      onTap: _selecionarImagem,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppCores.fundo,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _imagemPath.isNotEmpty
                ? AppCores.primaria
                : Colors.grey.shade300,
            width: _imagemPath.isNotEmpty ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _imagemPath.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Preview da imagem selecionada
                  Image.file(
                    File(_imagemPath),
                    fit: BoxFit.cover,
                  ),
                  // Botão de trocar a foto
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Trocar foto',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 52, color: AppCores.primaria),
                  SizedBox(height: 10),
                  Text(
                    'Toque para adicionar uma foto',
                    style: TextStyle(
                      color: AppCores.primaria,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Galeria ou câmera',
                    style:
                        TextStyle(color: AppCores.textoClaro, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}
