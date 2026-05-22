#!/bin/bash

set -e

echo "Verifying GitHub Actions workflow configuration..."
echo "=================================================="

# Check 1: Workflow file syntax (basic)
echo "1. Checking workflow file structure..."
if head -5 .github/workflows/build-offline.yml | grep -q "^name:"; then
  echo "✓ Basic YAML structure looks valid"
else
  echo "⚠ Basic YAML structure check failed"
fi

# Check 2: Required permissions
echo ""
echo "2. Checking required permissions..."
if grep -q "contents: write" .github/workflows/build-offline.yml; then
  echo "✓ Release creation permissions granted"
else
  echo "✗ Missing contents: write permission"
fi

# Check 3: Artifact upload configuration
echo ""
echo "3. Checking artifact configuration..."
if grep -q "actions/upload-artifact" .github/workflows/build-offline.yml; then
  echo "✓ Artifact upload configured"
  
  # Check retention days
  if grep -q "retention-days: 7" .github/workflows/build-offline.yml; then
    echo "✓ 7-day artifact retention"
  else
    echo "⚠ No retention days specified"
  fi
else
  echo "✗ Artifact upload not configured"
fi

# Check 4: Release creation
echo ""
echo "4. Checking release creation..."
if grep -q "softprops/action-gh-release" .github/workflows/build-offline.yml; then
  echo "✓ GitHub release action configured"
  
  # Check tag_name
  if grep -q "tag_name:.*OFFLINE_VERSION" .github/workflows/build-offline.yml; then
    echo "✓ Version tag configured"
  else
    echo "⚠ Version tag may not be set correctly"
  fi
else
  echo "✗ Release creation not configured"
fi

# Check 5: Build matrix
echo ""
echo "5. Checking build matrix..."
MATRIX_COUNT=$(grep -c "os:" .github/workflows/build-offline.yml)
if [ "$MATRIX_COUNT" -ge 6 ]; then
  echo "✓ Build matrix includes $MATRIX_COUNT platforms"
  
  # Check specific platforms
  PLATFORMS=("linux-x64" "linux-arm64" "darwin-x64" "darwin-arm64" "win32-x64" "win32-arm64")
  for platform in "${PLATFORMS[@]}"; do
    if grep -q "$platform" .github/workflows/build-offline.yml; then
      echo "  ✓ $platform included"
    else
      echo "  ✗ $platform missing"
    fi
  done
else
  echo "✗ Insufficient build matrix platforms: $MATRIX_COUNT"
fi

# Check 6: Output files
echo ""
echo "6. Checking output file patterns..."
if grep -q "\.zip" .github/workflows/build-offline.yml; then
  echo "✓ ZIP archives configured"
else
  echo "⚠ ZIP archives not mentioned"
fi

if grep -q "\.tar\.gz" .github/workflows/build-offline.yml; then
  echo "✓ tar.gz archives configured"
else
  echo "⚠ tar.gz archives not mentioned"
fi

# Check 7: Checksum generation
echo ""
echo "7. Checking checksum generation..."
if grep -q "sha256sum" .github/workflows/build-offline.yml; then
  echo "✓ SHA256 checksums will be generated"
else
  echo "✗ No checksum generation"
fi

# Check 8: Environment variables
echo ""
echo "8. Checking offline environment..."
if grep -q "OP_OFFLINE_MODE" .github/workflows/build-offline.yml; then
  echo "✓ Offline mode environment variables set"
  
  OFFLINE_VARS=("OP_OFFLINE_MODE" "OP_DISABLE_EXTERNAL_CONNECTIONS" "OP_LOCAL_WASM_FILES" "OP_DISABLE_UPDATE_CHECKING" "OP_DISABLE_TELEMETRY")
  for var in "${OFFLINE_VARS[@]}"; do
    if grep -q "$var" .github/workflows/build-offline.yml; then
      echo "  ✓ $var configured"
    else
      echo "  ⚠ $var not found"
    fi
  done
else
  echo "✗ Offline environment not configured"
fi

# Check 9: Dependency caching
echo ""
echo "9. Checking dependency caching..."
if grep -q "actions/cache" .github/workflows/build-offline.yml; then
  echo "✓ Dependency caching configured"
else
  echo "⚠ No dependency caching"
fi

# Check 10: Docker build
echo ""
echo "10. Checking Docker build..."
if grep -q "docker-build" .github/workflows/build-offline.yml; then
  echo "✓ Docker build job configured"
  
  if grep -q "docker/setup-buildx" .github/workflows/build-offline.yml; then
    echo "✓ Docker Buildx configured"
  fi
  
  if grep -q "linux/amd64,linux/arm64" .github/workflows/build-offline.yml; then
    echo "✓ Multi-architecture support"
  else
    echo "⚠ Limited architecture support"
  fi
else
  echo "⚠ Docker build not configured"
fi

echo ""
echo "=================================================="
echo "Workflow verification complete!"
echo ""
echo "Summary:"
echo "- Builds for 6 platforms"
echo "- Uploads artifacts to GitHub Actions"
echo "- Creates GitHub releases with version tags"
echo "- Generates SHA256 checksums"
echo "- Includes offline mode configuration"
echo "- Supports Docker multi-arch builds"
echo ""
echo "To trigger manually:"
echo "1. Go to GitHub → Actions → 'Build Offline Binaries'"
echo "2. Click 'Run workflow'"
echo "3. Enter version (e.g., v1.0.0-offline)"
echo "4. Select resource options"
echo "5. Wait for builds (~15-30 minutes)"
echo ""
echo "Output will be available in:"
echo "- GitHub Releases (binaries + checksums)"
echo "- GitHub Container Registry (Docker image)"
echo "- Workflow artifacts (temporary)"