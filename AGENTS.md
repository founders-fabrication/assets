# AGENTS.md

This repository contains static asset files (images, icons, logos) for the founders-fabrication project.

## Repository Purpose

This is a **static asset repository** - it contains only binary/image files and does not contain source code, tests, or build tooling.

## Asset Guidelines

### Supported Formats
- PNG, JPG, SVG, WebP formats are supported
- All assets are stored in the `/assets` directory

### Asset Naming Conventions
- Use descriptive names indicating content/purpose
- Use underscores for spaces (e.g., `logo_flat.png`, `icon_up.png`)
- Include variant identifiers (e.g., `_flat`, `_up`, `_clean`, `_draft`)

### Adding New Assets
1. Place new assets in the `/assets` directory
2. Ensure descriptive, consistent naming
3. Consider SVG as preferred format for scalable graphics
4. Compress PNG/WebP assets for web use where appropriate

## Git Workflow

### Commits
- This repository uses GPG-signed commits (gpgSign=true)
- Commit messages should describe the asset being added or updated
- Example: `Add new logo_flat.svg variant` or `Update icon_up.png with optimized compression`

### Branches
- Main branch: `main`
- All changes should be committed to `main` or reviewed via PR

## No Code Operations

This repository does not contain:
- Build commands (no package.json, Makefile, etc.)
- Linting commands
- Test commands
- Type checking
- CI/CD pipelines for code

## Code Style Guidelines (if code is added)

If code is ever added to this repository:

### TypeScript/JavaScript
- Use TypeScript for all new code
- Enable strict mode in tsconfig.json
- Prefer `const` over `let`, avoid `var`
- Use async/await over raw promises
- Use named exports over default exports

### Imports
- Use absolute imports with path aliases
- Group imports: external → internal → relative
- Sort alphabetically within groups

### Naming
- Files: kebab-case (e.g., `asset-helper.ts`)
- Classes: PascalCase (e.g., `AssetProcessor`)
- Functions/variables: camelCase (e.g., `processAsset()`)
- Constants: UPPER_SNAKE_CASE (e.g., `MAX_ASSET_SIZE`)
- Interfaces: prefix with `I` (e.g., `IAssetConfig`)

### Error Handling
- Use Result/Either types (e.g., neverthrow) for recoverable errors
- Throw Error instances with descriptive messages for unrecoverable failures
- Always handle async errors with try/catch or Result types
- Log errors with context before rethrowing

### Formatting
- Use Prettier with default settings
- Line length: 100 characters
- Semicolons: required
- Quotes: single quotes for strings

### Testing
- Write unit tests for all business logic
- Use Jest or Vitest as test framework
- Aim for 80%+ coverage on new code
- Place tests alongside source files (e.g., `asset.test.ts`)

