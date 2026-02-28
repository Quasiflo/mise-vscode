# AGENTS.md - Developer Guidelines for mise-vscode

## Overview

This is a VS Code extension for [mise](https://mise.jdx.dev/), a dev tools manager. The extension provides tasks, tools, and environment variable support for mise.

## Project Structure

- `src/` - Main TypeScript source code
  - `src/extension.ts` - Extension entry point
  - `src/providers/` - VS Code providers (tasks, tools, completions, etc.)
  - `src/utils/` - Utility functions
  - `src/webviews/` - React webview components
- `syntaxes/` - TextMate grammar files for TOML syntax highlighting
- `docs/` - Documentation site

## Build/Lint/Test Commands

```bash
# Build the extension (outputs to dist/)
npm run build

# Development - watch mode for extension
npm run dev-extension

# Development - watch mode for browser
npm run dev-browser

# Development - watch mode for webviews
npm run dev-webviews

# TypeScript type checking
npm run ts-check

# Lint with Biome (CI mode - fails on issues)
npm run lint

# Lint with Biome (auto-fix)
npm run lint-fix

# Run unit tests (uses Bun)
npm run test

# Run a single test file
bun test src/utils/taskInfoParser.test.ts

# Run a single test by name
bun test --test-name-pattern="parseUsageSpecLine" src/utils/taskInfoParser.test.ts

# Run end-to-end tests
npm run e2e-tests
```

## Code Style Guidelines

### General

- **Formatter/Linter**: [Biome](https://biomejs.dev/) is configured in `biome.json`
- **TypeScript**: Strict mode enabled in `tsconfig.json`
- **Indentation**: Tabs (not spaces)
- **Quotes**: Double quotes in JavaScript/TypeScript

### Biome Configuration Highlights

The following rules are enforced:

```json
{
  "style": {
    "noParameterAssign": "error",
    "useAsConstAssertion": "error",
    "useDefaultParameterLast": "error",
    "useEnumInitializers": "error",
    "useSelfClosingElements": "error",
    "useSingleVarDeclarator": "error",
    "noUnusedTemplateLiteral": "error",
    "useNumberNamespace": "error",
    "noInferrableTypes": "error",
    "noUselessElse": "error"
  }
}
```

### Imports

- Use `import type` for type-only imports to improve performance
- Use `node:` prefix for Node.js built-in modules
- Group imports logically: external → internal → types

```typescript
import { existsSync } from "node:fs";
import * as vscode from "vscode";
import type * as Task from "./types";

import { logger } from "./utils/logger";
import { getMiseEnv } from "./configuration";
```

### Naming Conventions

- **Classes/Types**: PascalCase (e.g., `MiseService`, `MiseTask`)
- **Functions/Variables**: camelCase (e.g., `getTasks()`, `miseBinaryPath`)
- **Constants**: camelCase or UPPER_SNAKE_CASE for compile-time constants
- **Files**: camelCase or PascalCase (e.g., `miseService.ts`, `MiseTomlTaskSymbolProvider.ts`)

### TypeScript

- Always enable `strict: true` in tsconfig
- Use explicit return types for exported functions
- Prefer `interface` over `type` for object shapes that may be extended
- Use `satisfies` when you want type inference with validation

```typescript
// Good - explicit return type
export async function getTasks(): Promise<MiseTask[]> {
  // ...
}

// Good - use satisfies for inference with validation
const tool = {
  name: "node",
  version: "20.0.0",
} satisfies MiseTool;
```

### Error Handling

- Always wrap async operations in try/catch
- Use the `logger` utility for logging errors
- Provide descriptive error messages
- Use type guards when checking error types

```typescript
try {
  const result = await someAsyncOperation();
  return result;
} catch (error: unknown) {
  if (error instanceof Error && error.message.includes("specific error")) {
    // Handle specific error
  }
  logger.error("Operation failed", error);
  return [];
}
```

### VS Code Extension Patterns

- Use `vscode.ExtensionContext` for storing state
- Return early with empty arrays/undefined when binary path is not configured
- Use event emitters for cross-component communication
- Implement `dispose()` methods for cleanup

```typescript
export class MiseService {
  private readonly eventEmitter: vscode.EventEmitter<void>;
  
  subscribeToReloadEvent(listener: () => void): vscode.Disposable {
    return this.eventEmitter.event(listener);
  }
  
  dispose() {
    this.eventEmitter.dispose();
  }
}
```

### Testing

- Test files use `.test.ts` suffix
- Use Bun's test framework (`bun:test`)
- Use descriptive test names that explain the scenario
- Group related tests with `describe()` blocks

```typescript
import { describe, expect, test } from "bun:test";

describe("parseTaskInfo", () => {
  test("parses complete task info correctly", () => {
    const input = `...`;
    const result = parseTaskInfo(input);
    expect(result).toEqual({ /* expected */ });
  });
});
```

### React/Webviews

- Use Zustand for state management
- Use TanStack Query for data fetching
- Follow React best practices (hooks, memoization)
- Use `@vscode-elements/react-elements` for VS Code themed components

### Misc

- Run `npm run lint-fix` before committing
- Run `npm run ts-check` to verify types
- Add `// TODO:` comments with issue references for incomplete code
- Use `// biome-ignore` comments sparingly and only when necessary
