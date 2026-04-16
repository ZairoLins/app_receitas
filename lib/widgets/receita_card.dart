// =============================================================
// lib/widgets/receita_card.dart
//
// WIDGET: ReceitaCard
//
// Card reutilizável para exibir resumo de uma receita.
// Usa ImagemReceita para exibir foto local ou placeholder.
// =============================================================

import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../utils/app_theme.dart';
import 'imagem_receita.dart';

class ReceitaCard extends StatelessWidget {
  final Receita receita;
  final VoidCallback onTap;
  final VoidCallback? onDeletar;

  const ReceitaCard({
    super.key,
    required this.receita,
    required this.onTap,
    this.onDeletar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Imagem local via File()
            ImagemReceita(
              imagemPath: receita.imagemPath,
              width: 100,
              height: 100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),

            // Informações
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receita.nome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppCores.textoEscuro,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppCores.corDaCategoria(receita.categoria)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            receita.categoria,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppCores.corDaCategoria(receita.categoria),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.timer_outlined,
                            size: 13, color: AppCores.textoMedio),
                        const SizedBox(width: 2),
                        Text(
                          '${receita.tempoPreparo} min',
                          style: const TextStyle(
                              fontSize: 12, color: AppCores.textoMedio),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (onDeletar != null)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppCores.erro, size: 20),
                onPressed: onDeletar,
              ),

            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: AppCores.textoClaro),
            ),
          ],
        ),
      ),
    );
  }
}
