# Local Resources for Offline Mode

Place the following files in this directory:

## Tree-sitter WASM files:
- parsers/tree-sitter-python.wasm
- parsers/tree-sitter-rust.wasm  
- parsers/tree-sitter-go.wasm
- parsers/tree-sitter-cpp.wasm
- ... (other language parsers as needed)

## Query files:
- parsers/queries/python/highlights.scm
- parsers/queries/python/locals.scm
- parsers/queries/rust/highlights.scm
- parsers/queries/rust/locals.scm
- ... (other language queries)

## Kotlin LSP:
- lsp/kotlin-language-server.jar (if using Kotlin)

## How to obtain files:
1. WASM files: Download from https://github.com/tree-sitter/tree-sitter-<language>/releases
2. Query files: Download from https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/master/queries/
3. Kotlin LSP: Download from https://download-cdn.jetbrains.com/kotlin-lsp/

Or run: ./scripts/download-offline-resources.sh
