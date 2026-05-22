import { Effect, pipe } from "effect"
import * as Offline from "../config/offline.js"

export class OfflineFetchError {
  readonly _tag = "OfflineFetchError"
  constructor(readonly url: string) {}
}

export const offlineFetch = (
  input: RequestInfo | URL,
  init?: RequestInit,
): Effect.Effect<Response, OfflineFetchError> =>
  Effect.gen(function* () {
    const block = yield* Offline.shouldBlockExternal
    
    if (block) {
      const url = typeof input === "string" ? input : input instanceof URL ? input.href : input.url
      
      const blockedPatterns = [
        /^https?:\/\/api\.github\.com/,
        /^https?:\/\/api\.opencode\.ai/,
        /^https?:\/\/api\.emailoctopus\.com/,
        /^https?:\/\/registry\.npmjs\.org/,
        /^https?:\/\/api\.openai\.com/,
        /^https?:\/\/api\.anthropic\.com/,
        /^https?:\/\/api\.groq\.com/,
        /^https?:\/\/api\.deepseek\.com/,
        /^https?:\/\/github\.com\/.*\/releases\/download/,
        /^https?:\/\/download-cdn\.jetbrains\.com/,
        /^https?:\/\/raw\.githubusercontent\.com/,
        /^https?:\/\/json\.schemastore\.org/,
      ]
      
      const shouldBlock = blockedPatterns.some(pattern => pattern.test(url))
      
      if (shouldBlock) {
        yield* new OfflineFetchError(url)
        return new Response(
          JSON.stringify({ error: "Offline mode: External connection blocked", url }),
          { status: 403, headers: { "Content-Type": "application/json" } },
        )
      }
    }
    
    return yield* Effect.tryPromise({
      try: () => fetch(input, init),
      catch: (error) => error as Error,
    })
  })