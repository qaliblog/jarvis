import { Config, ConfigProvider, Effect } from "effect"

export class OfflineConfig extends Config.Tag("OfflineConfig")<
  OfflineConfig,
  {
    readonly enabled: boolean
    readonly disableExternalConnections: boolean
    readonly localWasmFiles: boolean
    readonly disableUpdateChecking: boolean
    readonly disableTelemetry: boolean
  }
>() {}

export const offlineConfig = Config.all({
  enabled: Config.boolean("OP_OFFLINE_MODE").pipe(Config.withDefault(false)),
  disableExternalConnections: Config.boolean("OP_DISABLE_EXTERNAL_CONNECTIONS").pipe(Config.withDefault(true)),
  localWasmFiles: Config.boolean("OP_LOCAL_WASM_FILES").pipe(Config.withDefault(true)),
  disableUpdateChecking: Config.boolean("OP_DISABLE_UPDATE_CHECKING").pipe(Config.withDefault(true)),
  disableTelemetry: Config.boolean("OP_DISABLE_TELEMETRY").pipe(Config.withDefault(true)),
}).pipe(Config.map((config) => OfflineConfig.of(config)))

export const offlineLayer = ConfigProvider.fromConfig(offlineConfig).pipe(
  Effect.provideService(OfflineConfig),
)

export const isOfflineMode = Effect.gen(function* () {
  const config = yield* OfflineConfig
  return config.enabled
})

export const shouldBlockExternal = Effect.gen(function* () {
  const config = yield* OfflineConfig
  return config.enabled && config.disableExternalConnections
})

export const shouldUseLocalWasm = Effect.gen(function* () {
  const config = yield* OfflineConfig
  return config.enabled && config.localWasmFiles
})

export const shouldDisableUpdates = Effect.gen(function* () {
  const config = yield* OfflineConfig
  return config.enabled && config.disableUpdateChecking
})

export const shouldDisableTelemetry = Effect.gen(function* () {
  const config = yield* OfflineConfig
  return config.enabled && config.disableTelemetry
})