import { Effect, pipe } from "effect"
import * as Offline from "../config/offline.js"

export const getLocalParserPath = (filetype: string): string => {
  const parserMap: Record<string, { wasm: string; queries: Record<string, string[]> }> = {
    python: {
      wasm: "parsers/tree-sitter-python.wasm",
      queries: {
        highlights: ["parsers/queries/python/highlights.scm"],
        locals: ["parsers/queries/python/locals.scm"],
      },
    },
    rust: {
      wasm: "parsers/tree-sitter-rust.wasm",
      queries: {
        highlights: ["parsers/queries/rust/highlights.scm"],
        locals: ["parsers/queries/rust/locals.scm"],
      },
    },
    go: {
      wasm: "parsers/tree-sitter-go.wasm",
      queries: {
        highlights: ["parsers/queries/go/highlights.scm"],
        locals: ["parsers/queries/go/locals.scm"],
      },
    },
    cpp: {
      wasm: "parsers/tree-sitter-cpp.wasm",
      queries: {
        highlights: ["parsers/queries/cpp/highlights.scm"],
        locals: ["parsers/queries/cpp/locals.scm"],
      },
    },
  }
  
  return parserMap[filetype]?.wasm || `parsers/tree-sitter-${filetype}.wasm`
}

export const shouldUseLocalParser = Effect.gen(function* () {
  const useLocal = yield* Offline.shouldUseLocalWasm
  return useLocal
})