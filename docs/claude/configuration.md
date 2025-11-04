# Configuration

This document covers database configuration, application configuration, and environment variables for the KBS3 project.

## Database Configuration

### Database Connection Setup

Create `conf/ModalityDatabase.json` from template:

```bash
cp ./modality-fork/modality-base/modality-base-server-datasource/src/main/resources/one/modality/base/server/services/datasource/ModalityDatabase.default.json conf/ModalityDatabase.json
```

### Database Connection File

Edit `conf/ModalityDatabase.json` with your PostgreSQL connection details:

```json
{
  "host": "localhost",
  "port": 5432,
  "database": "kbs_db",
  "username": "your_username",
  "password": "your_password"
}
```

**Important**:
- This file contains sensitive credentials
- Should not be committed to version control
- Should be in `.gitignore`
- For local development only

### Database Schema

The database structure is defined by **Java entity classes** rather than SQL files.

**Entity Classes Location**: `modality-fork/modality-base/modality-base-shared-entities/src/main/java/one/modality/base/shared/entities/`

For detailed information about database entities, see [Database Entities](database-entities.md).

### Database Connection in Server Application

The server application (`kbs-server-application-vertx`) reads database configuration from:

1. **Primary**: `conf/ModalityDatabase.json`
2. **CI/CD**: Environment variables (staging/production)
3. **Fallback**: Default values (development)

### Environment Variable Configuration (Production)

For production/staging environments, database credentials can be provided via environment variables:

```bash
export DB_HOST=database-host.example.com
export DB_PORT=5432
export DB_NAME=kbs_db
export DB_USER=kbs_user
export DB_PASSWORD=secure_password
```

## Application Configuration

### Configuration File Locations

Application configuration is managed through `.properties` files:

**Location**: `src/main/resources/dev/webfx/platform/conf/`

**Key files**:
- `src-root.properties` - Root configuration (origins, API keys)

### src-root.properties Structure

This file contains application-wide configuration values:

```properties
# Application origins (URLs)
frontoffice.origin=https://bookings.example.com
backoffice.origin=https://admin.example.com

# Google Maps Integration
google.maps.api.key=YOUR_GOOGLE_MAPS_API_KEY

# Cloudinary (Image Management)
cloudinary.cloud.name=YOUR_CLOUDINARY_CLOUD_NAME
cloudinary.api.key=YOUR_CLOUDINARY_API_KEY
cloudinary.api.secret=YOUR_CLOUDINARY_API_SECRET

# DeepL Translation API
deepl.api.key=YOUR_DEEPL_API_KEY

# MojoAuth (Passwordless Authentication)
mojoauth.api.key=YOUR_MOJOAUTH_API_KEY

# OAuth Configuration
google.oauth.client.id=YOUR_GOOGLE_OAUTH_CLIENT_ID
google.oauth.client.secret=YOUR_GOOGLE_OAUTH_CLIENT_SECRET
```

**Important**:
- Local development versions use placeholder values
- Real values are injected during CI/CD builds for staging/production
- Never commit real API keys to version control

## Environment Variables

### Front-Office Environment Variables

| Variable | Description | Used In |
|----------|-------------|---------|
| `FRONTOFFICE_ORIGIN` | Front-office application URL | Client config |
| `GOOGLE_MAP_JS_API_KEY` | Google Maps API key | Map components |

### Back-Office Environment Variables

| Variable | Description | Used In |
|----------|-------------|---------|
| `BACKOFFICE_ORIGIN` | Back-office application URL | Client config |
| `GOOGLE_MAP_JS_API_KEY` | Google Maps API key | Map components |

### Server Environment Variables

| Variable | Description | Used In |
|----------|-------------|---------|
| `DB_HOST` | Database host | Database connection |
| `DB_PORT` | Database port | Database connection |
| `DB_NAME` | Database name | Database connection |
| `DB_USER` | Database username | Database connection |
| `DB_PASSWORD` | Database password | Database connection |
| `GOOGLE_OAUTH_CLIENT_ID` | Google OAuth client ID | Authentication |
| `GOOGLE_OAUTH_CLIENT_SECRET` | Google OAuth client secret | Authentication |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name | Image upload |
| `CLOUDINARY_API_KEY` | Cloudinary API key | Image upload |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret | Image upload |
| `DEEPL_API_KEY` | DeepL translation API key | Translation service |
| `MOJOAUTH_API_KEY` | MojoAuth API key | Passwordless auth |

### Setting Environment Variables

#### For Local Development

Create a `.env` file (not committed):

```bash
# Database
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=kbs_db
export DB_USER=postgres
export DB_PASSWORD=your_password

# APIs (use test keys for development)
export GOOGLE_MAP_JS_API_KEY=test_key
export DEEPL_API_KEY=test_key
export CLOUDINARY_CLOUD_NAME=test_cloud
export CLOUDINARY_API_KEY=test_key
export CLOUDINARY_API_SECRET=test_secret
```

Load environment variables:
```bash
source .env
```

#### For IntelliJ IDEA

Add environment variables to run configurations:

1. Open Run Configuration (Server, Back-Office, or Front-Office)
2. Go to "Environment variables" section
3. Add variables as needed

Example for Server configuration:
```
DB_HOST=localhost;DB_PORT=5432;DB_NAME=kbs_db;DB_USER=postgres;DB_PASSWORD=yourpassword
```

## Configuration Best Practices

### Security

1. **Never commit secrets** - Use `.gitignore` for sensitive files
2. **Use environment variables** - For production/staging deployments
3. **Placeholder values** - For local development
4. **Rotate keys regularly** - Update API keys periodically

### Organization

1. **Centralize configuration** - Use `src-root.properties` as single source
2. **Document all variables** - Keep this document updated
3. **Separate environments** - Different configs for dev/staging/prod
4. **Version control templates** - Commit `.template` files, not actual configs

### Development Workflow

1. **Copy templates** - Use template files to create local configs
2. **Set up .env file** - For environment variables
3. **Test with mock values** - Use test API keys for development
4. **Verify before commit** - Ensure no secrets are committed

## Configuration Files to Ignore

Add these to `.gitignore`:

```gitignore
# Database configuration
conf/ModalityDatabase.json

# Environment variables
.env

# Local configuration overrides
**/src-root.properties.local
```

## Troubleshooting Configuration

### Issue: Cannot connect to database

**Check**:
1. `conf/ModalityDatabase.json` exists and has correct credentials
2. PostgreSQL is running
3. Database user has necessary permissions
4. Firewall allows connection to PostgreSQL port

**Solution**:
```bash
# Test database connection
psql -h localhost -p 5432 -U your_username -d kbs_db
```

### Issue: API keys not working

**Check**:
1. `src-root.properties` has correct API keys
2. Environment variables are set (for production)
3. API keys have necessary permissions/quotas
4. Keys are not expired

**Solution**:
- Verify keys in API provider dashboard
- Check application logs for specific errors
- Regenerate keys if necessary

### Issue: Configuration changes not reflected

**Solution**:
1. Rebuild the project: `mvn clean package`
2. Restart the server/application
3. Clear browser cache (for web applications)
4. Verify configuration file is in correct location

## Related Documentation

- [Database Entities](database-entities.md) - Understanding database structure
- [Build & Development](build-and-development.md) - IntelliJ IDEA setup
- [Architecture](architecture.md) - Application structure

---
[← Back to Main Documentation](../../CLAUDE.md)
