# Build & Development

This document covers Maven configuration, build commands, profiles, and development workflows for the KBS3 project.

## Maven Configuration

### Core Settings

- **Parent POM**: `dev.webfx:webfx-parent:0.1.0-SNAPSHOT`
- **JDK Version**: Java 19 (minimum 13 due to javac bugs, but 19 is standard)
- **Runtime**: Java 17 for local development
- **Build Tool**: Maven with WebFX plugin
- **WebFX Configuration**: Uses `webfx.xml` files throughout the project for module definitions

### Maven Profiles

#### Environment Profiles
- `staging` - Staging environment build
- `production` - Production environment build

#### Build Target Profiles
- `gwt-compile` - Compile JavaFX to JavaScript for web deployment
- `gwt-sourcemaps` - Include source maps in GWT compilation
- `openjfx-fatjar` - Build fat JARs for JavaFX desktop applications
- `openjfx-desktop` - Desktop-specific builds
- `vertx-fatjar` - Build fat JAR for Vert.x server application

## Build Commands

### Initial Setup

Before building, you must install the local parent POMs to avoid using Central repository versions:

```bash
cd webfx-parent-fork && mvn install -B --no-transfer-progress && cd ..
cd webfx-stack-parent-fork && mvn install -B --no-transfer-progress && cd ..
```

### Staging Builds

#### Full Staging Build (All Platforms)
```bash
mvn -B -P 'staging,gwt-compile,openjfx-fatjar,!openjfx-desktop' package
```

#### Deployment Build (Server + Web Apps)
```bash
mvn package -P 'staging,vertx-fatjar,gwt-compile,gwt-sourcemaps' \
  -am -pl kbs3/kbs-server-application-vertx,kbs3/kbs-backoffice-application-gwt,kbs3/kbs-frontoffice-application-gwt \
  -B --no-transfer-progress
```

This builds:
- `kbs-server-application-vertx` → Vert.x fat JAR
- `kbs-backoffice-application-gwt` → Back-office WAR file
- `kbs-frontoffice-application-gwt` → Front-office WAR file

### Production Builds

```bash
mvn package -P 'production,vertx-fatjar,gwt-compile,gwt-sourcemaps' \
  -am -pl kbs3/kbs-server-application-vertx,kbs3/kbs-backoffice-application-gwt,kbs3/kbs-frontoffice-application-gwt \
  -B --no-transfer-progress
```

### Module-Specific Builds

Build only specific modules:

```bash
# Build only server
mvn package -P 'staging,vertx-fatjar' -am -pl kbs3/kbs-server-application-vertx

# Build only back-office
mvn package -P 'staging,gwt-compile,gwt-sourcemaps' -am -pl kbs3/kbs-backoffice-application-gwt

# Build only front-office
mvn package -P 'staging,gwt-compile,gwt-sourcemaps' -am -pl kbs3/kbs-frontoffice-application-gwt
```

## Testing

Tests are run as part of the standard Maven lifecycle:

```bash
# Run all tests
mvn test

# Run tests for specific module
mvn test -pl kbs3/kbs-server-application-vertx

# Skip tests during build
mvn package -DskipTests
```

## WebFX Framework Integration

WebFX transpiles JavaFX applications to JavaScript for web deployment while maintaining native capabilities:

- **Web**: GWT-compiled JavaScript
- **Desktop**: OpenJFX native applications
- **Mobile**: Gluon native applications
- **Server**: Vert.x (not transpiled, runs as pure Java)

WebFX synchronizes module configurations based on `webfx.xml` descriptors and generates Maven POMs.

## Common Build Issues & Solutions

### Issue: "Package does not exist" or module not found
**Solution**:
1. Reload Maven in your IDE
2. Run `mvn clean install` from the root
3. Ensure all submodules are on the same branch

### Issue: Build fails with "Parent POM not found"
**Solution**: Install local parent POMs:
```bash
cd webfx-parent-fork && mvn install && cd ..
cd webfx-stack-parent-fork && mvn install && cd ..
```

### Issue: GWT compilation fails or very slow
**Solution**:
- Increase Maven memory: `export MAVEN_OPTS="-Xmx4g"`
- Use draft compile for faster iteration: Add `-Dgwt.draftCompile=true`

## IntelliJ IDEA Setup

### Import Project
1. Open IntelliJ IDEA
2. File → Open → Select `kbs3-aggregate` directory
3. Import as Maven project
4. Wait for Maven indexing to complete

### Troubleshooting IntelliJ Issues

**If modules are not recognized**:
1. Right-click on `kbs3-aggregate` in Project view
2. Maven → Reload Project
3. Alternatively: Run `kbs3-aggregate → Lifecycle → Install`

**If runtime configurations don't work**:
1. Ensure Java 17 SDK is configured
2. File → Project Structure → Project SDK → Select Java 17
3. Rebuild project

### Server Runtime Configuration
- **Type**: Application
- **Name**: KBS3 Server
- **Runtime**: Java 17
- **Module**: `kbs-server-application-vertx`
- **Main class**: `dev.webfx.platform.boot.ApplicationBooter`
- **Working directory**: `$PROJECT_DIR$`

### Back-Office Runtime Configuration
- **Type**: Application
- **Name**: KBS3 Back-Office
- **Runtime**: Java 17
- **Module**: `kbs-backoffice-application-openjfx`
- **Main class**: `dev.webfx.platform.boot.ApplicationBooter`
- **Working directory**: `$PROJECT_DIR$`

### Front-Office Runtime Configuration
- **Type**: Application
- **Name**: KBS3 Front-Office
- **Runtime**: Java 17
- **Module**: `kbs-frontoffice-application-openjfx`
- **Main class**: `dev.webfx.platform.boot.ApplicationBooter`
- **Working directory**: `$PROJECT_DIR$`

## Build Optimization Tips

1. **Parallel builds**: Add `-T 1C` to Maven commands to use one thread per CPU core
2. **Offline mode**: Add `-o` to skip checking for updates (faster)
3. **Skip unnecessary phases**: Use `-DskipTests` to skip tests during development
4. **Incremental compilation**: Build specific modules with `-pl` instead of full builds

## Key Rules

1. **DO NOT** manually edit Maven `pom.xml` files marked with `<!-- File managed by WebFX (DO NOT EDIT MANUALLY) -->`
2. **Install local parent POMs** before building to avoid Central repository versions
3. **Ensure submodules are on matching branches** before building

---
[← Back to Main Documentation](../../CLAUDE.md)
