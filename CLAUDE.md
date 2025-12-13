# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

**KBS3** (Kadampa Business System 3) is a hospitality-oriented booking system built as an extension of the Modality project. It leverages **WebFX** to create cross-platform applications (Web, Desktop, Mobile) from a single JavaFX codebase that compiles to JavaScript via GWT.

## Repository Structure

This is a **multi-repository aggregate** managed via Git submodules:

- `kbs3/` - Organization-specific extensions to Modality
- `kbsx/` - Additional KBS extensions
- `modality-fork/` - Forked Modality booking system (base, booking, catering, crm, ecommerce, event, hotel modules)
- `webfx-*-fork/` - Various WebFX framework forks (platform, stack, extras, parent POMs, javacup runtime)

**Critical**: All submodules must be on the same branch (staging/prod) when building.

## Quick Reference

The documentation is organized into focused subfiles for efficiency:

### 📦 [Build & Development](docs/claude/build-and-development.md)
Reference this when:
- Building the project or running builds
- Working with Maven commands and profiles
- Setting up local development environment
- Setting up IntelliJ IDEA
- Troubleshooting build issues

### 🏗️ [Architecture](docs/claude/architecture.md)
Reference this when:
- Understanding the three-tier application model
- Working with Server, Back-Office, or Front-Office applications
- Implementing or modifying plugins
- Understanding module structure and dependencies
- Working with WebFX framework features

### 🗄️ [Database Entities](docs/claude/database-entities.md)
Reference this when:
- Writing DSQL queries with EntityStore/UpdateStore
- Working with entity classes
- Understanding ORM patterns
- Creating or modifying entities

### 📊 [Database Schema Reference](docs/claude/database-schema-reference.md)
Reference this when:
- Quick lookup of table names and fields
- Understanding table relationships
- Finding foreign keys
- Planning database queries
- Understanding data types and field patterns

### 🎨 [Module Conventions](docs/claude/module-conventions.md)
Reference this when:
- Working with CSS files (JavaFX vs Web)
- Adding or modifying translations (i18n)
- Creating UI elements with automatic language binding (I18nControls)
- Working with properties or YAML configuration files
- Understanding naming conventions for resources
- Styling UI components
- Using GWT-compatible UI patterns (EntityButtonSelector instead of ComboBox/ChoiceBox)

### 🔀 [Submodule Management](docs/claude/submodules.md)
Reference this when:
- Working across multiple submodules
- Managing branches and synchronization
- Making changes that span repositories
- Syncing upstream changes from WebFX
- Understanding branch structure

### ⚙️ [Configuration](docs/claude/configuration.md)
Reference this when:
- Configuring database connections
- Setting up application configuration
- Working with environment variables
- Managing API keys and secrets
- Local development setup

### ✅ [Code Review Guidelines](docs/claude/code-review-guidelines.md)
Reference this when:
- Reviewing pull requests
- Writing new UI code
- Styling components
- Adding translations
- Ensuring code quality and consistency

## Essential Commands Quick Start

```bash
# Initial setup - install parent POMs
cd webfx-parent-fork && mvn install -B --no-transfer-progress && cd ..
cd webfx-stack-parent-fork && mvn install -B --no-transfer-progress && cd ..

# Build for staging
mvn package -P 'staging,vertx-fatjar,gwt-compile,gwt-sourcemaps' \
  -am -pl kbs3/kbs-server-application-vertx,kbs3/kbs-backoffice-application-gwt,kbs3/kbs-frontoffice-application-gwt \
  -B --no-transfer-progress
```

## Key Rules

1. **DO NOT** manually edit Maven `pom.xml` files marked with `<!-- File managed by WebFX (DO NOT EDIT MANUALLY) -->`
2. **Set sizing/padding in Java code, NOT CSS** - ensures cross-platform consistency
3. **Use I18nControls for creating UI elements** (e.g., `I18nControls.newLabel(key)`) - ensures automatic language updates
4. **Ensure submodules are on matching branches** before building
5. **Install local parent POMs** before building to avoid Central repository versions
6. **NEVER hard-delete entities** - Always use soft-delete by setting `removed=true` to preserve referential integrity with related records (bookings, etc.)

## Database Reference

The database structure is defined by **Java entity classes** in:
`modality-fork/modality-base/modality-base-shared-entities/src/main/java/one/modality/base/shared/entities/`

**Three ways to understand the database**:
1. **[Database Entities](docs/claude/database-entities.md)** - Use entity classes for DSQL queries (RECOMMENDED)
2. **[Database Schema Reference](docs/claude/database-schema-reference.md)** - Lightweight table/field reference (123 tables)
3. **`kbs-database-structure.sql`** - Full SQL dump at repository root (for detailed DDL only)

**Use Java entity classes as the source of truth** - they're type-safe, always current, and easier to work with.

## Getting Help

- For build issues → [Build & Development](docs/claude/build-and-development.md)
- For architecture questions → [Architecture](docs/claude/architecture.md)
- For writing DSQL queries → [Database Entities](docs/claude/database-entities.md)
- For table/field lookup → [Database Schema Reference](docs/claude/database-schema-reference.md)
- For styling/i18n → [Module Conventions](docs/claude/module-conventions.md)
- For git/submodule issues → [Submodule Management](docs/claude/submodules.md)
- For configuration → [Configuration](docs/claude/configuration.md)
- For code review → [Code Review Guidelines](docs/claude/code-review-guidelines.md)
