#!/bin/bash

set -e

echo "Testing offline build workflow..."
echo "======================================="

# Test 1: Check workflow file exists
echo "1. Checking workflow file..."
if [ -f .github/workflows/build-offline.yml ]; then
  echo "✓ build-offline.yml exists"
  
  # Check key components
  grep -q "Build Offline Binaries" .github/workflows/build-offline.yml && echo "✓ Workflow name correct"
  grep -q "matrix" .github/workflows/build-offline.yml && echo "✓ Build matrix defined"
  grep -q "linux-x64" .github/workflows/build-offline.yml && echo "✓ Linux x64 target"
  grep -q "darwin-arm64" .github/workflows/build-offline.yml && echo "✓ macOS ARM64 target"
  grep -q "win32-x64" .github/workflows/build-offline.yml && echo "✓ Windows x64 target"
else
  echo "✗ Workflow file not found"
fi

# Test 2: Check Dockerfile
echo ""
echo "2. Checking Dockerfile..."
if [ -f packages/containers/Dockerfile.offline ]; then
  echo "✓ Dockerfile.offline exists"
  grep -q "OP_OFFLINE_MODE" packages/containers/Dockerfile.offline && echo "✓ Offline mode enabled"
  grep -q "local-resources" packages/containers/Dockerfile.offline && echo "✓ Local resources included"
else
  echo "✗ Dockerfile.offline not found"
fi

# Test 3: Check build script
echo ""
echo "3. Checking offline build script..."
if [ -f packages/opencode/script/build-offline.ts ]; then
  echo "✓ build-offline.ts exists"
  grep -q "OFFLINE_MODE" packages/opencode/script/build-offline.ts && echo "✓ Offline mode detection"
  grep -q "linux.*arm64" packages/opencode/script/build-offline.ts && echo "✓ ARM64 support"
else
  echo "✗ build-offline.ts not found"
fi

# Test 4: Check startup scripts
echo ""
echo "4. Checking startup scripts..."
if [ -f scripts/opencode-offline.sh ]; then
  echo "✓ opencode-offline.sh exists"
  [ -x scripts/opencode-offline.sh ] && echo "✓ Startup script executable"
  grep -q "OP_OFFLINE_MODE" scripts/opencode-offline.sh && echo "✓ Offline environment"
else
  echo "✗ opencode-offline.sh not found"
fi

# Test 5: Validate workflow syntax (basic)
echo ""
echo "5. Validating workflow syntax..."
if command -v yq &> /dev/null; then
  yq eval '.' .github/workflows/build-offline.yml > /dev/null && echo "✓ YAML syntax valid"
else
  echo "⚠ yq not installed, skipping YAML validation"
fi

# Test 6: Check for required actions
echo ""
echo "6. Checking required GitHub Actions..."
if [ -d .github/actions/setup-bun ]; then
  echo "✓ setup-bun action exists"
else
  echo "✗ setup-bun action not found"
fi

# Test 7: Check environment variables
echo ""
echo "7. Checking environment configuration..."
if [ -f .env.offline ]; then
  echo "✓ .env.offline exists"
  grep -q "OP_OFFLINE_MODE" .env.offline && echo "✓ Offline mode variable"
  grep -q "OP_DISABLE_EXTERNAL" .env.offline && echo "✓ External connection blocking"
else
  echo "⚠ .env.offline not found (run ./scripts/setup-offline-mode.sh)"
fi

# Test 8: Check local resources script
echo ""
echo "8. Checking resource download script..."
if [ -f scripts/download-offline-resources.sh ]; then
  echo "✓ download-offline-resources.sh exists"
  [ -x scripts/download-offline-resources.sh ] && echo "✓ Download script executable"
  grep -q "tree-sitter" scripts/download-offline-resources.sh && echo "✓ Tree-sitter downloads"
else
  echo "✗ download-offline-resources.sh not found"
fi

echo ""
echo "======================================="
echo "Offline build workflow test complete!"
echo ""
echo "To use the workflow:"
echo "1. Push to GitHub"
echo "2. Go to Actions → 'Build Offline Binaries'"
echo "3. Click 'Run workflow'"
echo "4. Enter version tag (e.g., v1.0.0-offline)"
echo "5. Wait for builds to complete"
echo ""
echo "The workflow will:"
echo "- Build for 6 platforms (Linux x64/ARM64, macOS x64/ARM64, Windows x64/ARM64)"
echo "- Create GitHub release with all binaries"
echo "- Build Docker image for multiple architectures"
echo "- Include offline resources (WASM files, queries)"
echo "- Generate checksums for verification"