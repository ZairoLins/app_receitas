# 🍽️ Receitas Rápidas — Trabalho A1

Aplicativo mobile desenvolvido em Flutter/Dart para cadastro e consulta de receitas simples.

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                        # Ponto de entrada do app
├── models/
│   └── receita.dart                 # Modelo de dados com toMap/fromMap
├── services/
│   └── database_service.dart        # Singleton SQLite (CRUD completo)
├── screens/
│   ├── main_screen.dart             # Shell com NavigationBar
│   ├── home_screen.dart             # Tela 1: Home com carrossel
│   ├── listagem_screen.dart         # Tela 2: Lista com filtro e busca
│   ├── detalhe_screen.dart          # Tela 3: Detalhes da receita
│   └── cadastro_screen.dart         # Tela 4: Cadastro e edição
├── widgets/
│   ├── receita_card.dart            # Card reutilizável
│   └── carrossel_destaques.dart     # Carrossel com indicadores
└── utils/
    └── app_theme.dart               # Cores, tema e estilos globais
```

---

## ✅ Requisitos Atendidos

| Requisito                    | Implementação                                      |
|------------------------------|----------------------------------------------------|
| Tela inicial (Home)          | `home_screen.dart`                                 |
| 3 telas adicionais           | listagem, detalhe, cadastro                        |
| Inclusão de imagem           | Campo URL + preview em tempo real no cadastro      |
| Carrossel                    | `carousel_slider` + `smooth_page_indicator`        |
| Comunicação entre telas      | `Navigator.push()` passando objetos `Receita`      |
| Persistência local (SQLite)  | `sqflite` via `DatabaseService` (Singleton)        |
| Navegação funciona           | ✅ NavigationBar + rotas                           |
| Interface clara              | ✅ Tema consistente, cores por categoria           |
| Código organizado            | ✅ models / services / screens / widgets / utils   |
| Separação de responsabilidades | ✅ cada arquivo tem função única                  |

---

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.x instalado
- Android Studio ou VS Code com extensão Flutter
- Emulador Android/iOS ou dispositivo físico

### Passo a passo

```bash
# 1. Entrar na pasta do projeto
cd receitas_app

# 2. Instalar as dependências
flutter pub get

# 3. Verificar se há dispositivo conectado
flutter devices

# 4. Rodar o app
flutter run
```

### Para gerar APK de debug
```bash
flutter build apk --debug
```
O APK estará em: `build/app/outputs/flutter-apk/app-debug.apk`

---

## 📦 Dependências Utilizadas

| Pacote                   | Versão   | Finalidade                        |
|--------------------------|----------|-----------------------------------|
| `sqflite`                | ^2.3.2   | Banco de dados SQLite local       |
| `path_provider`          | ^2.1.2   | Caminho do arquivo do banco       |
| `path`                   | ^1.9.0   | Manipulação de caminhos           |
| `carousel_slider`        | ^4.2.1   | Carrossel de imagens              |
| `smooth_page_indicator`  | ^1.1.0   | Indicadores do carrossel          |
| `uuid`                   | ^4.2.2   | (Auxiliar, não usado no SQLite)   |

---

## 🗄️ Banco de Dados SQLite

O banco é criado automaticamente no primeiro acesso com a tabela:

```sql
CREATE TABLE receitas (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  nome         TEXT    NOT NULL,
  ingredientes TEXT    NOT NULL,  -- separados por '|'
  modoPreparo  TEXT    NOT NULL,
  categoria    TEXT    NOT NULL,
  tempoPreparo INTEGER NOT NULL,
  imagemUrl    TEXT    NOT NULL,
  destaque     INTEGER NOT NULL DEFAULT 0,  -- 0 ou 1
  dataCadastro TEXT    NOT NULL   -- ISO 8601
);
```

5 receitas de exemplo são inseridas automaticamente.

---

*Trabalho A1 — Desenvolvimento de Aplicativo Mobile*  
*Disciplina: Programação para Dispositivos Móveis II — UNITINS*
