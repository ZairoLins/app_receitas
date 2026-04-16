// =============================================================
// lib/main.dart
//
// PONTO DE ENTRADA DO APLICATIVO
//
// Inicializa o app Flutter, aplica o tema global e define
// a tela inicial como MainScreen (que gerencia a navegação).
// =============================================================

import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'screens/main_screen.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }]
  // Inicia o app
  runApp(const ReceitasApp());
}

class ReceitasApp extends StatelessWidget {
  const ReceitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nome do app (aparece no gerenciador de tarefas)
      title: 'Receitas Rápidas',

      // Remove o banner "DEBUG" no canto superior direito
      debugShowCheckedModeBanner: false,

      // Aplica o tema centralizado definido em app_theme.dart
      theme: AppTema.tema,

      // Tela inicial: MainScreen gerencia a NavigationBar e as abas
      home: const MainScreen(),
    );
  }
}
