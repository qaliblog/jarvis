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
