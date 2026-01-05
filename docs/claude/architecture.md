# Architecture

This document describes the application architecture, module structure, and plugin system for the KBS3 project.

## Three-Tier Application Model

The KBS3 system is built on a three-tier architecture with server, back-office, and front-office applications.

### 1. Server Application

**Location**: `kbs3/kbs-server-application-vertx/`

- **Runtime**: Vert.x
- **Main class**: `dev.webfx.platform.boot.ApplicationBooter`
- **Output**: Fat JAR (`*-fat.jar`)
- **Database**: PostgreSQL (see `kbs-database-structure.sql`)
- **Purpose**: Backend API, business logic, database access, job scheduling

**Key responsibilities**:
- RESTful API endpoints
- Database operations
- Authentication and authorization
- Background jobs (imports, data synchronization)
- WebSocket connections
- Email sending

### 2. Back-Office Application

**Location**: `kbs3/kbs-backoffice-application-*/`

**Variants**:
- `kbs-backoffice-application-gwt` - Web (GWT-compiled JavaScript)
- `kbs-backoffice-application-openjfx` - Desktop (JavaFX native)
- `kbs-backoffice-application-gluon` - Mobile (Gluon native)

- **Main class**: `dev.webfx.platform.boot.ApplicationBooter`
- **Web output**: WAR file
- **Purpose**: Event management, bookings administration, internal tools

**Key features**:
- Event creation and management
- Booking administration
- User management
- Financial reporting
- Content management (news, podcasts, books)
- Festival creator tools

### 3. Front-Office Application

**Location**: `kbs3/kbs-frontoffice-application-*/`

**Variants**:
- `kbs-frontoffice-application-gwt` - Web (GWT-compiled JavaScript)
- `kbs-frontoffice-application-openjfx` - Desktop (JavaFX native)
- `kbs-frontoffice-application-gluon` - Mobile (Gluon native)

- **Main class**: `dev.webfx.platform.boot.ApplicationBooter`
- **Web output**: WAR file
- **Purpose**: Public-facing booking interface for customers

**Key features**:
- Event browsing and search
- Online booking forms
- User registration and login
- Payment processing
- Booking confirmation and management
- Multi-language support

## Plugin Architecture

Both KBS3 and Modality use a modular plugin system to extend functionality. Plugins are modules that follow naming convention `*-plugin`.

### Server Plugins

**Location**: `kbs3/kbs-*-plugin-server/`, `modality-fork/modality-*/modality-*-plugin-server/`

**Examples**:
- **Import plugins**: News import, podcast import, video import, KDM data synchronization
- **Update plugins**: Organization data updates, customer data synchronization
- **Job plugins**: Scheduled tasks, background processing

**Common patterns**:
```
kbs-news-import-plugin-server/
kbs-podcast-import-plugin-server/
kbs-kdm-sync-plugin-server/
modality-base-server-update-plugin/
```

### Client Plugins

**Location**: `kbs3/kbs-*-plugin/`, `modality-fork/modality-*/modality-*-plugin/`

**Categories**:

1. **Activity modules**: UI screens and user flows
   - Home page plugin
   - Login plugin
   - News viewing plugin
   - Podcast player plugin
   - Books catalog plugin

2. **Booking plugins**: Custom booking forms and flows
   - Event booking plugin
   - Accommodation booking plugin
   - Payment processing plugin

3. **Customization plugins**: Brand-specific UI elements
   - Festival creator plugin
   - Footer customization plugin
   - Theme plugin

**Common patterns**:
```
kbs-backoffice-festivalcreator-plugin/
kbs-frontoffice-booking-plugin/
modality-base-client-activity-home-plugin/
modality-base-client-activity-login-plugin/
```

### Plugin Structure

Plugins typically contain:
- `src/main/java/` - Java source code
- `src/main/webfx/css/` - Platform-specific CSS files
- `src/main/webfx/i18n/` - Internationalization files
- `webfx.xml` - WebFX module descriptor
- `pom.xml` - Maven configuration (generated, do not edit manually)

## Module Organization

### Module Naming Conventions

Modules follow a hierarchical naming pattern:

**KBS3 modules**: `kbs-[area]-[component]-[variant]`
- `kbs-backoffice-festivalcreator-plugin`
- `kbs-server-application-vertx`
- `kbs-client-festivaltypes`

**Modality modules**: `modality-[area]-[component]-[variant]`
- `modality-base-client-activity-home-plugin`
- `modality-hotel-server-datasource`
- `modality-ecommerce-backoffice-operations-booking`

**WebFX modules**: `webfx-[category]-[component]`
- `webfx-platform-boot`
- `webfx-stack-orm-entity`
- `webfx-extras-visual-grid`

### Module Types

1. **Application modules**: Entry points for Server, Back-Office, Front-Office
2. **Plugin modules**: Extend functionality with specific features
3. **Domain modules**: Business logic and entities
4. **UI modules**: User interface components and views
5. **Service modules**: Shared services and utilities
6. **Datasource modules**: Database access and queries

## Cross-Platform Compilation

WebFX enables compiling the same JavaFX codebase to multiple platforms:

### Compilation Targets

| Platform | Technology | Build Profile | Output |
|----------|-----------|---------------|--------|
| Web | GWT | `gwt-compile` | JavaScript + WAR |
| Desktop | OpenJFX | `openjfx-fatjar` | Executable JAR |
| Mobile | Gluon | `gluon-native` | Native app |
| Server | Vert.x | `vertx-fatjar` | Fat JAR |

### Platform-Specific Code

WebFX allows conditional compilation for platform-specific features:

**Java code**:
```java
if (Platform.isClient()) {
    // Client-only code (Back-Office, Front-Office)
}
if (Platform.isServer()) {
    // Server-only code
}
```

**Resource files**: Use platform suffixes
- `-fxweb@main.css` - **Unified CSS (Recommended)** - generates both JavaFX and Web CSS
- `-javafx@main.css` - JavaFX/Desktop (legacy)
- `-web@main.css` - GWT/Web (legacy)
- `-gluon@main.css` - Gluon/Mobile

See [Module Conventions - Unified CSS](module-conventions.md#unified-css-approach-recommended) for details.

## Module Dependencies

### Dependency Hierarchy

```
Application (vertx/gwt/openjfx)
  ├── Application plugins
  │     └── Domain plugins
  │           └── Service modules
  │                 └── WebFX framework modules
  └── Modality base modules
        └── WebFX framework modules
```

### Dependency Management

- **Parent POMs**: `webfx-parent`, `webfx-stack-parent` provide version management
- **WebFX descriptors**: `webfx.xml` files declare module dependencies
- **Maven**: Dependencies are generated from `webfx.xml` by WebFX

**Important**: Never manually edit `pom.xml` files marked as managed by WebFX. Always modify `webfx.xml` instead.

## Service Provider Interface (SPI)

WebFX uses Java SPI for cross-platform service implementations:

1. **Interface**: Define service interface
2. **Implementation**: Create platform-specific implementations
3. **Registration**: Register in `META-INF/services/` or `webfx.xml`
4. **Runtime**: WebFX loads appropriate implementation for target platform

**Example**:
```
Interface: webfx-platform-storage
Implementations:
  - webfx-platform-storage-java (Server/Desktop)
  - webfx-platform-storage-gwt (Web)
  - webfx-platform-storage-gluon (Mobile)
```

## Data Flow

### Client-Server Communication

1. **Client** → Makes API call via WebFX RPC
2. **Server** → Processes request, queries database
3. **Database** → Returns data
4. **Server** → Transforms data, applies business logic
5. **Client** → Receives response, updates UI

### Entity System

- **ORM**: WebFX provides entity framework similar to JPA
- **Queries**: Execute on server, transfer results to client
- **Entities**: Shared entity classes between client and server
- **Store**: Client-side entity store with change tracking

## Database Schema

The database structure is defined by **Java entity classes** in:
`modality-fork/modality-base/modality-base-shared-entities/src/main/java/one/modality/base/shared/entities/`

**Key entity areas**:
- Organizations and sites
- Events and schedules
- Bookings and options
- Documents and items
- Customers and accounts
- Payments and transactions
- Content (news, podcasts, books)

For detailed information, see [Database Entities](database-entities.md).

**Why entity classes instead of SQL?**
- Entity classes are the source of truth for the application
- They're easier to read and understand
- They're type-safe and self-documenting
- They stay in sync with the codebase
- They will be updated when the database changes

---
[← Back to Main Documentation](../../CLAUDE.md)
