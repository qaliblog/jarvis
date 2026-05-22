#!/bin/bash

set -e

# Set offline mode environment variables
export OP_OFFLINE_MODE=${OP_OFFLINE_MODE:-true}
export OP_DISABLE_EXTERNAL_CONNECTIONS=${OP_DISABLE_EXTERNAL_CONNECTIONS:-true}
export OP_LOCAL_WASM_FILES=${OP_LOCAL_WASM_FILES:-true}
export OP_DISABLE_UPDATE_CHECKING=${OP_DISABLE_UPDATE_CHECKING:-true}
export OP_DISABLE_TELEMETRY=${OP_DISABLE_TELEMETRY:-true}

# Load custom environment if provided
if [ -f "/config/.env" ]; then
    echo "Loading custom environment from /config/.env"
    export $(grep -v '^#' /config/.env | xargs)
elif [ -f ".env" ]; then
    echo "Loading environment from .env"
    export $(grep -v '^#' .env | xargs)
fi

# Check for local resources
if [ "$OP_LOCAL_WASM_FILES" = "true" ] && [ -d "./local-resources" ]; then
    echo "Using local resources from ./local-resources/"
    
    # Set paths for local resources
    export OP_PARSERS_DIR=${OP_PARSERS_DIR:-./local-resources/parsers}
    export OP_QUERIES_DIR=${OP_QUERIES_DIR:-./local-resources/parsers/queries}
    export OP_LSP_DIR=${OP_LSP_DIR:-./local-resources/lsp}
fi

# Create config directory if it doesn't exist
mkdir -p /config

# Generate default config if none exists
if [ ! -f "/config/config.json" ]; then
    echo "Generating default configuration..."
    cat > /config/config.json << 'EOF'
{
  "offline_mode": true,
  "llm_providers": {
    "openai": {
      "base_url": "${OPENAI_API_BASE:-http://localhost:8080/v1}",
      "api_key": "${OPENAI_API_KEY:-}"
    },
    "anthropic": {
      "base_url": "${ANTHROPIC_API_BASE:-http://localhost:8081/v1}",
      "api_key": "${ANTHROPIC_API_KEY:-}"
    },
    "groq": {
      "base_url": "${GROQ_API_BASE:-http://localhost:8082/v1}",
      "api_key": "${GROQ_API_KEY:-}"
    },
    "deepseek": {
      "base_url": "${DEEPSEEK_API_BASE:-http://localhost:8083/v1}",
      "api_key": "${DEEPSEEK_API_KEY:-}"
    }
  },
  "workspace": "/workspace",
  "disable_external": true
}
EOF
fi

# Start OpenCode
echo "Starting OpenCode in offline mode..."
echo "Environment:"
echo "  OP_OFFLINE_MODE=$OP_OFFLINE_MODE"
echo "  OP_DISABLE_EXTERNAL_CONNECTIONS=$OP_DISABLE_EXTERNAL_CONNECTIONS"
echo "  OP_LOCAL_WASM_FILES=$OP_LOCAL_WASM_FILES"
echo "  OP_DISABLE_UPDATE_CHECKING=$OP_DISABLE_UPDATE_CHECKING"
echo "  OP_DISABLE_TELEMETRY=$OP_DISABLE_TELEMETRY"

# Pass through all arguments
exec node ./dist/index.js "$@"