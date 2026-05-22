import { readFileSync, writeFileSync } from 'fs'
import { join } from 'path'

const parsersConfigPath = join(process.cwd(), 'packages/opencode/parsers-config.ts')
let config = readFileSync(parsersConfigPath, 'utf8')

// Replace external URLs with local paths
config = config.replace(
  /"https:\/\/github\.com\/tree-sitter\/tree-sitter-(.*?)\/releases\/download\/.*?\/tree-sitter-(.*?)\.wasm"/g,
  (match, lang, filetype) => {
    return `"local-resources/parsers/tree-sitter-${filetype}.wasm"`
  }
)

config = config.replace(
  /"https:\/\/raw\.githubusercontent\.com\/nvim-treesitter\/nvim-treesitter\/.*?\/queries\/(.*?)\/(.*?)\.scm"/g,
  (match, lang, query) => {
    return `"local-resources/parsers/queries/${lang}/${query}.scm"`
  }
)

config = config.replace(
  /"https:\/\/github\.com\/tree-sitter\/tree-sitter-(.*?)\/raw\/.*?\/queries\/(.*?)\.scm"/g,
  (match, lang, query) => {
    return `"local-resources/parsers/queries/${lang}/${query}.scm"`
  }
)

writeFileSync(parsersConfigPath, config)
console.log('Updated parsers configuration for offline mode')
