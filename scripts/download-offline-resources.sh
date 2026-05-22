#!/bin/bash

set -e

echo "Downloading offline resources..."
cd ./local-resources

# Download tree-sitter WASM files
echo "Downloading tree-sitter WASM files..."
mkdir -p parsers
cd parsers

# Python
curl -L -o tree-sitter-python.wasm \
  "https://github.com/tree-sitter/tree-sitter-python/releases/download/v0.23.6/tree-sitter-python.wasm"

# Rust
curl -L -o tree-sitter-rust.wasm \
  "https://github.com/tree-sitter/tree-sitter-rust/releases/download/v0.24.0/tree-sitter-rust.wasm"

# Go
curl -L -o tree-sitter-go.wasm \
  "https://github.com/tree-sitter/tree-sitter-go/releases/download/v0.25.0/tree-sitter-go.wasm"

# C++
curl -L -o tree-sitter-cpp.wasm \
  "https://github.com/tree-sitter/tree-sitter-cpp/releases/download/v0.23.4/tree-sitter-cpp.wasm"

# JavaScript
curl -L -o tree-sitter-javascript.wasm \
  "https://github.com/tree-sitter/tree-sitter-javascript/releases/download/v0.24.2/tree-sitter-javascript.wasm"

# TypeScript
curl -L -o tree-sitter-typescript.wasm \
  "https://github.com/tree-sitter/tree-sitter-typescript/releases/download/v0.24.2/tree-sitter-typescript.wasm"

# Java
curl -L -o tree-sitter-java.wasm \
  "https://github.com/tree-sitter/tree-sitter-java/releases/download/v0.24.2/tree-sitter-java.wasm"

# C#
curl -L -o tree-sitter-c_sharp.wasm \
  "https://github.com/tree-sitter/tree-sitter-c-sharp/releases/download/v0.24.2/tree-sitter-c_sharp.wasm"

cd ..

# Download query files
echo "Downloading query files..."
mkdir -p parsers/queries

download_query() {
  local lang=$1
  local query=$2
  mkdir -p "parsers/queries/$lang"
  curl -L -o "parsers/queries/$lang/$query.scm" \
    "https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/master/queries/$lang/$query.scm"
}

# Download for each language
for lang in python rust go cpp javascript typescript java c_sharp; do
  echo "Downloading queries for $lang..."
  download_query $lang "highlights"
  download_query $lang "locals"
done

# Download Kotlin LSP (optional)
echo "Downloading Kotlin LSP..."
mkdir -p lsp
cd lsp
curl -L -o kotlin-language-server.jar \
  "https://download-cdn.jetbrains.com/kotlin-lsp/2.0.0/kotlin-language-server.jar"
cd ..

echo "Download complete!"
echo "Resources are available in ./local-resources/"
