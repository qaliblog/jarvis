# Example GitHub Release Output

When the workflow runs successfully, it will create a GitHub release like this:

## Release: OpenCode Offline v1.0.0-offline

### Assets included:

**Linux:**
- `opencode-offline-linux-x64.tar.gz` (Linux x64)
- `opencode-offline-linux-x64.tar.gz.sha256` (Checksum)
- `opencode-offline-linux-arm64.tar.gz` (Linux ARM64)
- `opencode-offline-linux-arm64.tar.gz.sha256` (Checksum)

**macOS:**
- `opencode-offline-macos-x64.tar.gz` (macOS Intel)
- `opencode-offline-macos-x64.tar.gz.sha256` (Checksum)
- `opencode-offline-macos-arm64.tar.gz` (macOS Apple Silicon)
- `opencode-offline-macos-arm64.tar.gz.sha256` (Checksum)

**Windows:**
- `opencode-offline-windows-x64.zip` (Windows x64)
- `opencode-offline-windows-x64.zip.sha256` (Checksum)
- `opencode-offline-windows-arm64.zip` (Windows ARM64)
- `opencode-offline-windows-arm64.zip.sha256` (Checksum)

### Each archive contains:
```
opencode-offline/
├── index.js           # Main application
├── package.json       # Dependencies
├── opencode.sh        # Startup script (Unix)
├── opencode.cmd       # Startup script (Windows)
├── README.md          # Instructions
├── local-resources/   # Offline resources
│   ├── parsers/       # Tree-sitter WASM files
│   └── queries/       # Syntax highlighting
└── .env.example       # Configuration template
```

### Docker Images:
- `ghcr.io/your-org/opencode-offline:v1.0.0-offline`
- `ghcr.io/your-org/opencode-offline:latest`

### Verification:
```bash
# Verify checksums
sha256sum -c opencode-offline-linux-x64.tar.gz.sha256

# Extract and run
tar -xzf opencode-offline-linux-x64.tar.gz
cd opencode-offline
./opencode.sh
```

## Workflow Triggers:

1. **Manual**: Go to Actions → Run workflow with version tag
2. **Tag push**: Push tag like `v1.0.0-offline`
3. **Branch push**: Push to `release/offline*` branches

## Estimated Build Times:
- Linux builds: ~5 minutes each
- macOS builds: ~8 minutes each  
- Windows builds: ~10 minutes each
- Docker build: ~7 minutes
- Total: ~45-60 minutes

## Requirements for GitHub Organization:
- GitHub Actions enabled
- Write permissions for releases
- GitHub Container Registry enabled
- Sufficient storage (artifacts + packages)