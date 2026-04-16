// =============================================================
// lib/widgets/imagem_receita.dart
//
// WIDGET: ImagemReceita
//
// Widget reutilizável que exibe a imagem de uma receita.
// Se imagemPath estiver preenchido, carrega o arquivo local
// com File(). Caso contrário, exibe um ícone placeholder.
// Usado no card, no carrossel e na tela de detalhes.
// =============================================================

import 'dart:io'; // Necessário para File (acesso ao sistema de arquivos)
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ImagemReceita extends StatelessWidget {
  final String imagemPath; // Caminho local retornado pelo image_picker
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ImagemReceita({
    super.key,
    required this.imagemPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imagem;

    if (imagemPath.isNotEmpty) {
      // Carrega imagem do armazenamento local do dispositivo
      imagem = Image.file(
        File(imagemPath),
        width: width,
        height: height,
        fit: fit,
        // Se o arquivo não existir mais (ex: foi movido), mostra placeholder
        errorBuilder: (ctx, err, stack) => _placeholder(),
      );
    } else {
      // Sem imagem selecionada: exibe ícone centralizado
      imagem = _placeholder();
    }

    // Aplica borda arredondada se fornecida
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imagem);
    }
    return imagem;
  }

  // Placeholder exibido quando não há imagem ou ao carregar
  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppCores.fundo,
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 40,
          color: AppCores.textoClaro,
        ),
      ),
    );
  }
}
