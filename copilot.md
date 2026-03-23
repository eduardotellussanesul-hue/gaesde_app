# gaesde_app — Documentação do Aplicativo Flutter

## Visão Geral
App Flutter que consome uma API .NET + MongoDB hospedada em `http://191.252.192.39/api`.

- **Flutter SDK**: `$HOME/dev/Aplicativos/flutter/bin`
- **Projeto**: `/home/eduardo/dev/Aplicativos/gaesde_app`
- **Dispositivo de teste**: Galaxy A15 (SM A156M), device ID `RQCX40DA1PR`, Android 15 API 35

---

## Estrutura de Telas

### Navegação — 6 abas (home_screen.dart)
1. **Estoque** — `EstoqueListScreen`
2. **Itens** — `ItemListScreen`
3. **Categorias** — `CategoriaListScreen`
4. **Unidades** — `UnidadeListScreen`
5. **Locais** — `LocalListScreen`
6. **Usuários** — `UserListScreen`

---

## CRUDs Implementados

### Categoria
- **Service**: `lib/services/categoria_service.dart`
  - `getAll()`, `create()`, `update()`, `delete()`
  - Endpoint: `GET/POST/PUT/DELETE /api/categoria`
- **Telas**:
  - `lib/screens/categoria_list_screen.dart` — lista com editar/excluir por item, FAB para criar
  - `lib/screens/categoria_form_screen.dart` — formulário (campo: nome)

### Unidade
- **Service**: `lib/services/unidade_service.dart`
  - `getAll()`, `create()`, `update()`, `delete()`
  - Endpoint: `GET/POST/PUT/DELETE /api/unidade`
- **Telas**:
  - `lib/screens/unidade_list_screen.dart` — lista com editar/excluir por item, FAB para criar
  - `lib/screens/unidade_form_screen.dart` — formulário (campo: nome)

### Item
- **Service**: `lib/services/item_service.dart`
- **Telas**: `lib/screens/item_list_screen.dart`

### Local
- **Service**: `lib/services/local_service.dart`
- **Telas**: `lib/screens/local_list_screen.dart`

### Usuário
- **Service**: `lib/services/user_service.dart`
- **Telas**: `lib/screens/user_list_screen.dart`

### Estoque
- **Service**: `lib/services/estoque_service.dart`
  - `getAll()`, `getSaldo()`, `getBaixoEstoque()`, `entrada()`, `saida()`, `transferencia()`
  - `create()` — `POST /api/estoque` com payload `{item_id, local_id, quantidade}`
  - `delete()` — `DELETE /api/estoque/{id}`
- **Telas**:
  - `lib/screens/estoque_list_screen.dart` — lista com busca/filtro por categoria, opção "Novo estoque" no bottom sheet, `PopupMenuButton` com "Excluir estoque" em cada card
  - `lib/screens/estoque_form_screen.dart` — formulário direto (dropdowns de item e local, campo quantidade)
  - `lib/screens/estoque_movimentacao_screen.dart` — entrada, saída, transferência

---

## Payloads da API

### POST /api/estoque
```json
{ "item_id": "...", "local_id": "...", "quantidade": 10 }
```
Retorna `201` com `{ "id": "...", "item_id": "...", "local_id": "...", "quantidade": 10 }`

### DELETE /api/estoque/{id}
Retorna `204 No Content`

### POST /api/categoria
```json
{ "nome": "..." }
```
Retorna `201`

### POST /api/unidade
```json
{ "nome": "..." }
```
Retorna `201`

---

## Correções Aplicadas

### `DropdownButtonFormField` — propriedade `value` depreciada
Arquivo: `lib/screens/estoque_movimentacao_screen.dart`
- Substituído `value:` por `initialValue:` nos 3 dropdowns (linhas ~204, ~225, ~249)

---

## Comandos Úteis

### Rodar no Galaxy A15
```bash
cd /home/eduardo/dev/Aplicativos/gaesde_app
export PATH="$PATH:$HOME/dev/Aplicativos/flutter/bin"
flutter run -d RQCX40DA1PR
```

### Verificar análise estática
```bash
flutter analyze
```
Status atual: **No issues found!**
