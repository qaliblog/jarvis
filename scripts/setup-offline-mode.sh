#!/bin/bash

set -e

echo "Setting up OpenCode for offline mode..."
echo "======================================="

# Create offline configuration
echo "Creating offline configuration..."
cat > .env.offline << 'EOF'
# Offline Mode Configuration
OP_OFFLINE_MODE=true
OP_DISABLE_EXTERNAL_CONNECTIONS=true
OP_LOCAL_WASM_FILES=true
OP_DISABLE_UPDATE_CHECKING=true
OP_DISABLE_TELEMETRY=true

# LLM Provider Configuration (update these with your local/enterprise endpoints)
OPENAI_API_BASE=http://localhost:8080/v1  # Example: local proxy
ANTHROPIC_API_BASE=http://localhost:8081/v1
GROQ_API_BASE=http://localhost:8082/v1
DEEPSEEK_API_BASE=http://localhost:8083/v1

# Disable external services
OP_DISABLE_GITHUB_INTEGRATION=true
OP_DISABLE_NPM_REGISTRY=true
EOF

echo "Created .env.offline configuration file"

# Create directory for local WASM files
echo "Creating local resources directory..."
mkdir -p ./local-resources/parsers
mkdir -p ./local-resources/parsers/queries

cat > ./local-resources/README.md << 'EOF'
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
EOF

# Create download script
cat > ./scripts/download-offline-resources.sh << 'EOF'
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
EOF

chmod +x ./scripts/download-offline-resources.sh

# Create patch for parsers configuration
echo "Creating parser configuration patch..."
cat > ./scripts/patch-parsers-offline.js << 'EOF'
import { readFileSync, writeFileSync } from 'fs'
import { join } from 'path'

const parsersConfigPath = join(process.cwd(), 'packages/opencode/parsers-config.ts')
let config = readFileSync(parsersConfigPath, 'utf8')

// Replace external URLs with local paths
config = config.replace(
  /"https:\/\/github\.com\/tree-sitter\/tree-sitter-(.*?)\/releases\/download\/.*?\/tree-sitter-(.*?)\.wasm"/g,
  (match, lang, filetype) => {
    return `"local-resources/parsers/tree-sitter-${filetype}.wasm"`
  }
)

config = config.replace(
  /"https:\/\/raw\.githubusercontent\.com\/nvim-treesitter\/nvim-treesitter\/.*?\/queries\/(.*?)\/(.*?)\.scm"/g,
  (match, lang, query) => {
    return `"local-resources/parsers/queries/${lang}/${query}.scm"`
  }
)

config = config.replace(
  /"https:\/\/github\.com\/tree-sitter\/tree-sitter-(.*?)\/raw\/.*?\/queries\/(.*?)\.scm"/g,
  (match, lang, query) => {
    return `"local-resources/parsers/queries/${lang}/${query}.scm"`
  }
)

writeFileSync(parsersConfigPath, config)
console.log('Updated parsers configuration for offline mode')
EOF

# Create usage instructions
cat > ./OFFLINE_MODE.md << 'EOF'
# OpenCode Offline Mode

## Setup

1. **Enable offline mode**:
   ```bash
   export $(cat .env.offline | xargs)
   # or
   source .env.offline
   ```

2. **Download offline resources**:
   ```bash
   ./scripts/download-offline-resources.sh
   ```

3. **Apply parser patches** (optional):
   ```bash
   bun run ./scripts/patch-parsers-offline.js
   ```

## Configuration

### Environment Variables:
- `OP_OFFLINE_MODE=true` - Enable offline mode
- `OP_DISABLE_EXTERNAL_CONNECTIONS=true` - Block external HTTP requests
- `OP_LOCAL_WASM_FILES=true` - Use local WASM files
- `OP_DISABLE_UPDATE_CHECKING=true` - Disable update checks
- `OP_DISABLE_TELEMETRY=true` - Disable telemetry

### LLM Providers:
Configure local/enterprise endpoints:
```bash
OPENAI_API_BASE=http://your-local-proxy/v1
ANTHROPIC_API_BASE=http://your-local-proxy/v1
# etc.
```

## What's Disabled in Offline Mode

1. **GitHub API calls** - No release checking, user data, or GitHub app integration
2. **OpenCode.ai services** - No token exchange or installation lookup
3. **npm registry** - No version checking or package lookups
4. **External WASM/CDN downloads** - Uses local parser files
5. **Update checking** - Manual updates only
6. **EmailOctopus integration** - No email marketing calls
7. **Remote configuration** - Uses local config only

## Building for Offline Distribution

1. Bundle all resources:
   ```bash
   ./scripts/download-offline-resources.sh
   cp -r local-resources dist/
   ```

2. Set environment variables in deployment

3. Configure local LLM endpoints

## Testing
Run with offline mode enabled:
```bash
OP_OFFLINE_MODE=true bun dev
```

Verify no external connections:
```bash
# Monitor network traffic
sudo tcpdump -i any -n not port 22
```

## Notes
- Some features requiring external services will be limited
- LLM providers must be configured with local/enterprise endpoints
- Manual updates via package manager still work
EOF

echo "======================================="
echo "Offline mode setup complete!"
echo ""
echo "Next steps:"
echo "1. Review .env.offline configuration"
echo "2. Run: ./scripts/download-offline-resources.sh"
echo "3. Set environment: export \$(cat .env.offline | xargs)"
echo "4. Start app: OP_OFFLINE_MODE=true bun dev"
echo ""
echo "See OFFLINE_MODE.md for detailed instructions"