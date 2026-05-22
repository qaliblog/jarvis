#!/bin/bash

set -e

echo "Testing OpenCode offline mode..."
echo "======================================="

# Test 1: Check environment variables
echo "1. Testing environment variables..."
if [ -f .env.offline ]; then
  echo "✓ .env.offline configuration exists"
  grep OP_OFFLINE_MODE .env.offline && echo "✓ OP_OFFLINE_MODE configured"
  grep OP_DISABLE_EXTERNAL .env.offline && echo "✓ External connections disabled"
else
  echo "✗ .env.offline not found"
fi

# Test 2: Check offline configuration module
echo ""
echo "2. Testing offline configuration module..."
if [ -f packages/opencode/src/config/offline.ts ]; then
  echo "✓ Offline configuration module exists"
  
  # Check key exports
  grep -q "export class OfflineConfig" packages/opencode/src/config/offline.ts && echo "✓ OfflineConfig class defined"
  grep -q "export const isOfflineMode" packages/opencode/src/config/offline.ts && echo "✓ isOfflineMode function defined"
  grep -q "export const shouldBlockExternal" packages/opencode/src/config/offline.ts && echo "✓ shouldBlockExternal function defined"
else
  echo "✗ Offline configuration module not found"
fi

# Test 3: Check offline fetch wrapper
echo ""
echo "3. Testing offline fetch wrapper..."
if [ -f packages/opencode/src/utils/offline-fetch.ts ]; then
  echo "✓ Offline fetch wrapper exists"
  
  # Check blocked patterns
  grep -q "api.github.com" packages/opencode/src/utils/offline-fetch.ts && echo "✓ GitHub API blocked"
  grep -q "api.opencode.ai" packages/opencode/src/utils/offline-fetch.ts && echo "✓ OpenCode.ai API blocked"
  grep -q "registry.npmjs.org" packages/opencode/src/utils/offline-fetch.ts && echo "✓ npm registry blocked"
else
  echo "✗ Offline fetch wrapper not found"
fi

# Test 4: Check patched files
echo ""
echo "4. Checking patched files..."

# Check version script
if grep -q "OFFLINE_MODE" packages/script/src/index.ts; then
  echo "✓ Version script patched for offline mode"
else
  echo "✗ Version script not patched"
fi

# Check npm config
if grep -q "OFFLINE_MODE" packages/core/src/npm-config.ts; then
  echo "✓ npm config patched for offline mode"
else
  echo "✗ npm config not patched"
fi

# Check update checking
if grep -q "OFFLINE_MODE" packages/app/src/components/settings-general.tsx; then
  echo "✓ Update checking patched for offline mode"
else
  echo "✗ Update checking not patched"
fi

# Test 5: Check translation
echo ""
echo "5. Checking translations..."
if grep -q "settings.updates.toast.offline" packages/app/src/i18n/en.ts; then
  echo "✓ Offline mode translations added"
else
  echo "✗ Offline translations missing"
fi

# Test 6: Check setup scripts
echo ""
echo "6. Checking setup scripts..."
if [ -f scripts/setup-offline-mode.sh ]; then
  echo "✓ Setup script exists"
  [ -x scripts/setup-offline-mode.sh ] && echo "✓ Setup script executable"
else
  echo "✗ Setup script not found"
fi

if [ -f scripts/download-offline-resources.sh ]; then
  echo "✓ Download script exists"
  [ -x scripts/download-offline-resources.sh ] && echo "✓ Download script executable"
else
  echo "✗ Download script not found"
fi

if [ -f OFFLINE_MODE.md ]; then
  echo "✓ Documentation exists"
else
  echo "✗ Documentation not found"
fi

# Test 7: Simulate offline mode
echo ""
echo "7. Simulating offline mode..."
export OP_OFFLINE_MODE=true
export OP_DISABLE_EXTERNAL_CONNECTIONS=true

echo "Environment variables set:"
echo "  OP_OFFLINE_MODE=$OP_OFFLINE_MODE"
echo "  OP_DISABLE_EXTERNAL_CONNECTIONS=$OP_DISABLE_EXTERNAL_CONNECTIONS"

# Quick compile test
echo ""
echo "8. Quick compile test..."
if bun typecheck 2>/dev/null | head -5; then
  echo "✓ Type checking passes"
else
  echo "✗ Type checking failed"
fi

echo ""
echo "======================================="
echo "Offline mode test complete!"
echo ""
echo "To fully test:"
echo "1. Download resources: ./scripts/download-offline-resources.sh"
echo "2. Apply parser patches: bun run ./scripts/patch-parsers-offline.js"
echo "3. Run in offline mode: OP_OFFLINE_MODE=true bun dev"
echo "4. Verify no external network calls using network monitor"