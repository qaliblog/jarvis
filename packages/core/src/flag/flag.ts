import { Config } from "effect"

function truthy(key: string) {
  const value = process.env[key]?.toLowerCase()
  return value === "true" || value === "1"
}

// Support both JARVIS_* and OPENCODE_* environment variables for backward compatibility
function getEnv(key: string): string | undefined {
  const jarvisKey = key.replace("OPENCODE_", "JARVIS_")
  return process.env[jarvisKey] || process.env[key]
}

function truthyCompat(key: string): boolean {
  const jarvisKey = key.replace("OPENCODE_", "JARVIS_")
  const value = process.env[jarvisKey]?.toLowerCase() || process.env[key]?.toLowerCase()
  return value === "true" || value === "1"
}

const OPENCODE_EXPERIMENTAL = truthyCompat("OPENCODE_EXPERIMENTAL")
const copy = getEnv("OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT")

export const Flag = {
  OTEL_EXPORTER_OTLP_ENDPOINT: process.env["OTEL_EXPORTER_OTLP_ENDPOINT"],
  OTEL_EXPORTER_OTLP_HEADERS: process.env["OTEL_EXPORTER_OTLP_HEADERS"],

  OPENCODE_AUTO_HEAP_SNAPSHOT: truthyCompat("OPENCODE_AUTO_HEAP_SNAPSHOT"),
  OPENCODE_GIT_BASH_PATH: getEnv("OPENCODE_GIT_BASH_PATH"),
  OPENCODE_CONFIG: getEnv("OPENCODE_CONFIG"),
  OPENCODE_CONFIG_CONTENT: getEnv("OPENCODE_CONFIG_CONTENT"),
  OPENCODE_DISABLE_AUTOUPDATE: truthyCompat("OPENCODE_DISABLE_AUTOUPDATE"),
  OPENCODE_ALWAYS_NOTIFY_UPDATE: truthyCompat("OPENCODE_ALWAYS_NOTIFY_UPDATE"),
  OPENCODE_DISABLE_PRUNE: truthyCompat("OPENCODE_DISABLE_PRUNE"),
  OPENCODE_DISABLE_TERMINAL_TITLE: truthyCompat("OPENCODE_DISABLE_TERMINAL_TITLE"),
  OPENCODE_SHOW_TTFD: truthyCompat("OPENCODE_SHOW_TTFD"),
  OPENCODE_DISABLE_AUTOCOMPACT: truthyCompat("OPENCODE_DISABLE_AUTOCOMPACT"),
  OPENCODE_DISABLE_MODELS_FETCH: truthyCompat("OPENCODE_DISABLE_MODELS_FETCH"),
  OPENCODE_DISABLE_MOUSE: truthyCompat("OPENCODE_DISABLE_MOUSE"),
  OPENCODE_FAKE_VCS: getEnv("OPENCODE_FAKE_VCS"),
  OPENCODE_SERVER_PASSWORD: getEnv("OPENCODE_SERVER_PASSWORD"),
  OPENCODE_SERVER_USERNAME: getEnv("OPENCODE_SERVER_USERNAME"),
  OPENCODE_OFFLINE_MODE: truthyCompat("OPENCODE_OFFLINE_MODE"),

  // Experimental
  OPENCODE_EXPERIMENTAL_FILEWATCHER: Config.boolean("JARVIS_EXPERIMENTAL_FILEWATCHER").pipe(
    Config.withDefault(false),
  ),
  OPENCODE_EXPERIMENTAL_DISABLE_FILEWATCHER: Config.boolean("JARVIS_EXPERIMENTAL_DISABLE_FILEWATCHER").pipe(
    Config.withDefault(false),
  ),
  OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT:
    copy === undefined ? process.platform === "win32" : truthyCompat("OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT"),
  OPENCODE_MODELS_URL: getEnv("OPENCODE_MODELS_URL"),
  OPENCODE_MODELS_PATH: getEnv("OPENCODE_MODELS_PATH"),
  OPENCODE_DB: getEnv("OPENCODE_DB"),

  OPENCODE_WORKSPACE_ID: getEnv("OPENCODE_WORKSPACE_ID"),
  OPENCODE_EXPERIMENTAL_WORKSPACES: OPENCODE_EXPERIMENTAL || truthyCompat("OPENCODE_EXPERIMENTAL_WORKSPACES"),

  // Evaluated at access time (not module load) because tests, the CLI, and
  // external tooling set these env vars at runtime.
  get OPENCODE_DISABLE_PROJECT_CONFIG() {
    return truthyCompat("OPENCODE_DISABLE_PROJECT_CONFIG")
  },
  get OPENCODE_TUI_CONFIG() {
    return getEnv("OPENCODE_TUI_CONFIG")
  },
  get OPENCODE_CONFIG_DIR() {
    return getEnv("OPENCODE_CONFIG_DIR")
  },
  get OPENCODE_PURE() {
    return truthyCompat("OPENCODE_PURE")
  },
  get OPENCODE_PERMISSION() {
    return getEnv("OPENCODE_PERMISSION")
  },
  get OPENCODE_PLUGIN_META_FILE() {
    return getEnv("OPENCODE_PLUGIN_META_FILE")
  },
  get OPENCODE_CLIENT() {
    return getEnv("OPENCODE_CLIENT")
  },
}
