# mise-vscode — AGENTS.md

## Quick start

```sh
mise install          # install tools (node, bun, etc.)
aube install          # install npm dependencies (pnpm wrapper)
mise run dev          # watch-mode build + launch VSCode extension host
```

## Commands

| Command | What it runs |
|---|---|
| `node --run build` | rsbuild (extension) + rslib (browser) + rsbuild (webviews) |
| `node --run test` | `bun test` — unit tests (`*.test.ts`) |
| `node --run e2e-tests` | `vscode-test` — e2e tests (`src/e2e-tests/*.e2e.ts`) |
| `node --run ts-check` | `tsc --noEmit` |
| `node --run lint` | `biome ci` |
| `node --run lint-fix` | `biome check --fix` |
| `mise run check` | lint-fix → test → ts-check → docs:extractSettings |
| `mise run check-all` | above + docs:build + e2e-tests |

**CI order**: `aube ci --frozen-lockfile` → `lint` → `ts-check` → `test` → `build`

## Architecture

- **Not a monorepo.** `pnpm-workspace.yaml` only adds `docs/` (Astro site). Core is single package.
- **Entrypoints**: `src/extension.ts` (desktop), `src/browser.ts` (web via rslib)
- **Builds** (3 targets): rsbuild → `dist/extension.js` (node), rslib → `dist/browser/` (web), rsbuild with React → `dist/webviews/` (webview panels)
- **Main classes**: `MiseExtension` (lifecycle in `src/miseExtension.ts`), `MiseService` (mise CLI bridge in `src/miseService.ts`, ~1260 lines)
- **Webviews**: React 18 + Zustand + TanStack Query/Table, bundled separately, served in `vscode.WebviewPanel`

## Testing quirks

- **Unit tests** use `bun test`; vscode module is auto-mocked via `bun-preload-test.ts` (configured in `bunfig.toml` `[test] preload`)
- **E2E tests** use `@vscode/test-cli` (mocha + tsx), run via `vscode-test` script, **not** bun test
- E2E fixtures live in `src/e2e-tests/fixtures/`; env `MISE_CEILING_PATHS` must point there
- `mise.configureExtensionsAutomatically` defaults to `false`
- `mise.updateOpenTerminalsEnvAutomatically` defaults to `false`
- `mise.enableTaskSymbolProvider` defaults to `false`

## Tooling

- **Package manager**: pnpm (via `aube` wrapper — `aube install`, `aube ci --frozen-lockfile`)
- **Formatter / linter**: Biome (tabs indent, double quotes, organize imports on save)
- **Pre-commit hooks**: `hk` runs `tsc --noEmit` + `biome check` (`hk.pkl` config)
- **Lockfiles**: `pnpm-lock.yaml` (deps), `mise.lock` (tool versions, `MISE_LOCKED=1` in CI)

## Important conventions

- `mise configureExtensionsAutomaticallyIgnoreList` defaults exclude `biomejs.biome` and `oxc.oxc-vscode`
- `mise.configureExtensionsIncludeGlobalTools` defaults to `true` (pollutes `.vscode/settings.json` with global tools)
- Extension requires trusted workspace (can execute code)
- Virtual workspaces get syntax highlighting only
- Unit test files match `*.test.ts`; e2e test files match `*.e2e.ts`

## Release

- Automated via release-please on push to `main` (node release type)
- Publishing to both VSCode Marketplace and Open VSX on tag push `v*`
