// =============================================================
// lib/utils/app_theme.dart
//
// TEMA E CONSTANTES VISUAIS DO APLICATIVO
//
// Centraliza cores, estilos de texto e o ThemeData do app.
// Manter tudo aqui facilita manutenção e garante consistência
// visual em todas as telas.
// =============================================================

import 'package:flutter/material.dart';

// ---- PALETA DE CORES ----------------------------------------
class AppCores {
  AppCores._(); // Impede instanciação (classe utilitária)

  static const Color primaria = Color(0xFFE07B39);   // Laranja quente (principal)
  static const Color secundaria = Color(0xFF2D6A4F); // Verde folha (contraste)
  static const Color fundo = Color(0xFFFFF8F0);       // Creme suave (background)
  static const Color superficie = Color(0xFFFFFFFF);  // Branco (cards)
  static const Color textoEscuro = Color(0xFF1A1A2E); // Quase preto
  static const Color textoMedio = Color(0xFF6B6B80);  // Cinza médio
  static const Color textoClaro = Color(0xFFAAAAAA);  // Cinza claro
  static const Color erro = Color(0xFFD62828);        // Vermelho erro
  static const Color sucesso = Color(0xFF2D6A4F);     // Verde sucesso

  // Cores por categoria de receita
  static const Map<String, Color> coresCategorias = {
    'Café da Manhã': Color(0xFFFFC300),
    'Almoço': Color(0xFFE07B39),
    'Jantar': Color(0xFF6B4C9A),
    'Sobremesa': Color(0xFFE07BB5),
    'Bebida': Color(0xFF2196F3),
    'Lanche': Color(0xFF4CAF50),
    'Comunidade': Color(0xFF9E9E9E),
  };

  // Retorna a cor da categoria ou uma cor padrão se não encontrada
  static Color corDaCategoria(String categoria) =>
      coresCategorias[categoria] ?? primaria;
}

// ---- TEMA GLOBAL DO APP -------------------------------------
class AppTema {
  AppTema._();

  static ThemeData get tema {
    return ThemeData(
      useMaterial3: true,

      // Esquema de cores baseado na cor primária laranja
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppCores.primaria,
        brightness: Brightness.light,
        primary: AppCores.primaria,
        secondary: AppCores.secundaria,
        surface: AppCores.superficie,
        error: AppCores.erro,
      ),

      // Cor de fundo das telas
      scaffoldBackgroundColor: AppCores.fundo,

      // AppBar com fundo branco e texto escuro
      appBarTheme: const AppBarTheme(
        backgroundColor: AppCores.superficie,
        foregroundColor: AppCores.textoEscuro,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppCores.textoEscuro,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Estilo padrão dos cards
      cardTheme: CardThemeData(
        color: AppCores.superficie,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Botões elevados com cor primária
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppCores.primaria,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Campo de texto com borda arredondada
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppCores.primaria, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppCores.erro),
        ),
        labelStyle: const TextStyle(color: AppCores.textoMedio),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Estilo da barra de navegação inferior
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppCores.superficie,
        indicatorColor: AppCores.primaria.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppCores.primaria);
          }
          return const IconThemeData(color: AppCores.textoMedio);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppCores.primaria,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: AppCores.textoMedio,
            fontSize: 12,
          );
        }),
      ),
    );
  }
}
