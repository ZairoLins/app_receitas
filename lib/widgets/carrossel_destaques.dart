// =============================================================
// lib/widgets/carrossel_destaques.dart
//
// WIDGET: CarrosselDestaques
//
// Carrossel com auto-play das receitas em destaque.
// Usa ImagemReceita (File local) em vez de Image.network.
// =============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/receita.dart';
import '../utils/app_theme.dart';

class CarrosselDestaques extends StatefulWidget {
  final List<Receita> receitas;
  // Callback de comunicação entre telas: envia receita selecionada
  final void Function(Receita receita) onTap;

  const CarrosselDestaques({
    super.key,
    required this.receitas,
    required this.onTap,
  });

  @override
  State<CarrosselDestaques> createState() => _CarrosselDestaquesState();
}

class _CarrosselDestaquesState extends State<CarrosselDestaques> {
  int _indexAtual = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.receitas.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Nenhuma receita em destaque ainda.',
            style: TextStyle(color: AppCores.textoMedio),
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.receitas.length,
          itemBuilder: (context, index, _) =>
              _buildItem(widget.receitas[index]),
          options: CarouselOptions(
            height: 220,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            onPageChanged: (index, _) =>
                setState(() => _indexAtual = index),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSmoothIndicator(
          activeIndex: _indexAtual,
          count: widget.receitas.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            expansionFactor: 3,
            activeDotColor: AppCores.primaria,
            dotColor: AppCores.primaria.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(Receita receita) {
    return GestureDetector(
      // COMUNICAÇÃO ENTRE TELAS: envia a receita para HomeScreen
      onTap: () => widget.onTap(receita),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagem local ou fundo colorido se não houver foto
              receita.temImagem
                  ? Image.file(
                      File(receita.imagemPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fundoPadrao(),
                    )
                  : _fundoPadrao(),

              // Gradiente para legibilidade do texto
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),

              // Textos sobre a imagem
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receita.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${receita.tempoPreparo} min • ${receita.categoria}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge destaque
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppCores.primaria,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 12),
                      SizedBox(width: 3),
                      Text(
                        'Destaque',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fundoPadrao() {
    return Container(
      color: AppCores.primaria.withOpacity(0.2),
      child: const Center(
        child: Icon(Icons.restaurant, size: 60, color: AppCores.textoClaro),
      ),
    );
  }
}
