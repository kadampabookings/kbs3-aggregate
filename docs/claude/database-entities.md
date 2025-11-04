# Database Entities

This document provides a lightweight reference to the database structure through Java entity classes. The entity classes serve as the **source of truth** for the database schema.

## Overview

The KBS3 database structure is represented by Java entity classes in the WebFX ORM framework. These entity classes define:
- Database table mappings
- Field names and types
- Relationships between entities
- Business logic methods

**Database**: PostgreSQL 17.5
**Database Name**: `kbs_db`

## Entity Classes Location

**Primary Module**: `modality-fork/modality-base/modality-base-shared-entities/`

**Package Structure**:
```
modality-fork/modality-base/modality-base-shared-entities/src/main/java/one/modality/base/shared/entities/
├── Person.java                  # Customer/person records
├── Event.java                   # Event definitions
├── Document.java                # Bookings/documents
├── DocumentLine.java            # Booking line items
├── Organization.java            # Organizations/centers
├── Site.java                    # Venues/sites
├── Item.java                    # Bookable items (options)
├── MoneyAccount.java            # Financial accounts
├── MoneyFlow.java               # Transactions
├── FrontendAccount.java         # User accounts
├── [60+ other entities]         # Additional tables
└── impl/                        # Implementation classes
    ├── PersonImpl.java
    ├── EventImpl.java
    └── [other implementations]
```

## Understanding Entity Classes

Entity classes are Java interfaces that represent database tables. They use the WebFX ORM framework similar to JPA/Hibernate.

### Entity Structure Pattern

```java
public interface Person extends Entity, EntityHasPersonalDetails {
    // Field name constants (map to database columns)
    String birthDate = "birthdate";
    String name = "name";
    String frontendAccount = "frontendAccount";

    // Getters and setters
    default void setName(String value) {
        setFieldValue(name, value);
    }

    default String getName() {
        return getStringFieldValue(name);
    }

    // Foreign key relationships
    default FrontendAccount getFrontendAccount() {
        return getForeignEntity(frontendAccount);
    }
}
```

### Key Concepts

1. **Field Constants**: String constants represent database column names
2. **Type Safety**: Getter/setter methods provide type-safe access
3. **Relationships**: Foreign key relationships via `getForeignEntity()` methods
4. **Markers**: Interfaces like `EntityHasPersonalDetails` provide common fields

## Core Entity Categories

### 1. Customer & Account Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| `Person` | Customer records | name, birthDate, email, phone, country |
| `FrontendAccount` | User login accounts | username, email, corporation |
| `Organization` | Centers/branches | name, type, country, closed |

### 2. Event & Booking Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| `Event` | Events/courses | name, startDate, endDate, type, venue |
| `EventType` | Event categories | name, recurring, kbs3 |
| `Document` | Bookings/reservations | ref, person, event, confirmed, priceNet |
| `DocumentLine` | Booking line items | site_item, document, price_net, cancelled |

### 3. Inventory Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| `Item` | Bookable options | name, family, code, rate |
| `ItemFamily` | Item categories | name, icon, code |
| `Site` | Venues/locations | name, organization, itemFamily |
| `SiteItem` | Site-specific items | site, item, available, online |

### 4. Financial Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| `MoneyAccount` | Financial accounts | name, organization, balance |
| `MoneyAccountType` | Account types | name, code |
| `MoneyFlow` | Transactions | date, amount, comment, document |
| `MoneyTransfer` | Transfers | date, fromAccount, toAccount, amount |

### 5. Content Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| `News` | News articles | title, organization, date, image, transcript |
| `Podcast` | Podcast episodes | title, date, audioUrl, teacher |
| `Video` | Video content | name, title, url, durationMillis |
| `Book` | Book catalog | title, teacher, url, image |
| `Media` | Generic media | url, type, duration |

### 6. Authorization Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| `AuthorizationRole` | User roles | name, activityState |
| `AuthorizationRoleOperation` | Role permissions | role, operation, activityState |
| `AuthorizationRule` | Access rules | role, resourceFilter |
| `AuthorizationOrganizationAdmin` | Org admins | user, organization |

### 7. System Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| `History` | Change history | record, comment, date, user |
| `Label` | Multilingual labels | code, de, en, es, fr, pt, vi, zh |
| `Image` | Image references | url, cloudinaryPublicId |
| `Filter` | Saved queries | name, fields, orderBy, groupBy |

## Finding Entity Classes

### Search by Entity Name

To find the interface for a specific entity:

```bash
# Find interface
find . -name "EntityName.java" -type f | grep "shared/entities/"

# Example: Find Person entity
find . -name "Person.java" -type f | grep "shared/entities/"
```

### Browse All Entities

```bash
# List all entity interfaces
ls modality-fork/modality-base/modality-base-shared-entities/src/main/java/one/modality/base/shared/entities/*.java

# List all entity implementations
ls modality-fork/modality-base/modality-base-shared-entities/src/main/java/one/modality/base/shared/entities/impl/*Impl.java
```

## Reading Entity Classes

When examining an entity class, focus on:

1. **Field Constants**: These map to database column names
   ```java
   String birthDate = "birthdate";  // Column: birthdate
   String name = "name";            // Column: name
   ```

2. **Foreign Key Fields**: Relationships to other tables
   ```java
   String frontendAccount = "frontendAccount";  // FK to frontend_account table
   ```

3. **Getter Methods**: Return type indicates field type
   ```java
   default String getName() { ... }           // VARCHAR field
   default LocalDate getBirthDate() { ... }    // DATE field
   default Integer getRef() { ... }            // INTEGER field
   default Boolean isActive() { ... }          // BOOLEAN field
   ```

4. **Relationship Methods**: Foreign entity access
   ```java
   default FrontendAccount getFrontendAccount() { ... }  // Join to frontend_account
   default Event getEvent() { ... }                      // Join to event
   ```

## Database Schema Changes

When the database schema changes:

1. **Entity classes are updated** to reflect new columns/tables
2. **This documentation remains lightweight** - it points to entity classes
3. **Entity classes are the single source of truth** - no need to duplicate schema info

## Database Schema Reference

### Quick Schema Reference

For a **lightweight table/field reference**, see **[Database Schema Reference](database-schema-reference.md)**:
- All 123 tables organized by functional area
- Key fields and data types
- Foreign key relationships
- Common field patterns
- Quick search guide

### Full SQL Schema

A complete SQL dump is available at the repository root:

**File**: `kbs-database-structure.sql`
**Size**: Large (complete schema with constraints, triggers, indexes)
**Use**: Reference only for detailed DDL

This file is useful for:
- Understanding complex constraints
- Viewing database-level triggers
- Examining indexes and performance optimizations
- Database migration reference

### Recommended Approach

**For day-to-day development**:
1. **Use Java entity classes** (this document) - Easiest, type-safe, always current
2. **Use Database Schema Reference** - Quick table/field lookup
3. **Use SQL dump** - Only when you need detailed DDL/constraints

Entity classes are:
- Easier to read
- Type-safe
- Always in sync with the application code
- Self-documenting

## EntityStore vs UpdateStore

Understanding the difference between `EntityStore` and `UpdateStore` is crucial:

### EntityStore - For READ Operations (SELECT)

Use `EntityStore` for **querying/reading** data from the database:

```java
EntityStore entityStore = EntityStore.create();

// Single query
entityStore.executeQuery("select name, email from Person where id=?", personId)
    .onSuccess(entityList -> {
        // Read results
    });

// Batch queries (multiple SELECT statements)
entityStore.executeQueryBatch(
    new EntityStoreQuery("select * from Item where organization=?", orgId),
    new EntityStoreQuery("select * from Event where id=?", eventId)
).onSuccess(entityLists -> {
    EntityList<Item> items = entityLists[0];
    EntityList<Event> events = entityLists[1];
});
```

### UpdateStore - For WRITE Operations (INSERT/UPDATE)

Use `UpdateStore` for **creating/modifying** entities and saving changes to the database:

```java
// Create UpdateStore above EntityStore
EntityStore entityStore = EntityStore.create();
UpdateStore updateStore = UpdateStore.createAbove(entityStore);

// Get entity for editing (wraps it for tracking changes)
Event currentEvent = updateStore.updateEntity(FXEvent.getEvent());

// Modify the entity
currentEvent.setLivestreamUrl("https://example.com/stream");
currentEvent.setVodExpirationDate(LocalDateTime.now().plusDays(30));

// Create new entity
Document newDocument = updateStore.createEntity(Document.class);
newDocument.setPerson(person);
newDocument.setEvent(event);
newDocument.setConfirmed(false);

// Save all changes to database
updateStore.submitChanges()
    .onFailure(Console::log)
    .onSuccess(result -> Console.log("Saved successfully!"));
```

### Key Differences

| Operation | Use | Example |
|-----------|-----|---------|
| **SELECT queries** | `EntityStore` | `entityStore.executeQuery("select * from Person")` |
| **Batch SELECT queries** | `EntityStore` | `entityStore.executeQueryBatch(query1, query2)` |
| **INSERT/UPDATE** | `UpdateStore` | `updateStore.createEntity()` / `updateStore.updateEntity()` |
| **Save changes** | `UpdateStore` | `updateStore.submitChanges()` |
| **Cancel changes** | `UpdateStore` | `updateStore.cancelChanges()` |
| **Check for changes** | `UpdateStore` | `EntityBindings.hasChangesProperty(updateStore)` |

### Complete Workflow Example

```java
// 1. Create stores
EntityStore entityStore = EntityStore.create();
UpdateStore updateStore = UpdateStore.createAbove(entityStore);

// 2. Query data (READ with EntityStore)
entityStore.executeQuery("select * from Event where id=?", eventId)
    .onSuccess(events -> {
        Event event = events.get(0);

        // 3. Modify entity (WRITE with UpdateStore)
        Event editableEvent = updateStore.updateEntity(event);
        editableEvent.setLivestreamUrl("https://new-url.com");

        // 4. Save changes to database
        updateStore.submitChanges()
            .onSuccess(result -> Console.log("Changes saved!"));
    });
```

### Quick Reference: Which Store to Use?

**Use `EntityStore`** when you need to:
- ✅ Execute SELECT queries
- ✅ Read data from database
- ✅ Execute batch queries (`executeQueryBatch`)
- ✅ Load entities for display (read-only)

**Use `UpdateStore`** when you need to:
- ✅ Create new entities (`createEntity`)
- ✅ Modify existing entities (`updateEntity`)
- ✅ Save changes to database (`submitChanges`)
- ✅ Track unsaved changes
- ✅ Cancel pending changes (`cancelChanges`)

**Remember**:
- `EntityStore` = **READ** operations (SELECT)
- `UpdateStore` = **WRITE** operations (INSERT/UPDATE)
- Always create `UpdateStore` above `EntityStore`: `UpdateStore.createAbove(entityStore)`

## Writing DSQL Queries

The application uses **DSQL** (Domain-Specific Query Language) - a SQL-like syntax for querying entities. Entity field constants map directly to database columns.

### DSQL Query Syntax

DSQL queries are executed on `EntityStore` using SQL-like syntax with entity/table names and field names from entity classes:

```java
entityStore.executeQuery(
    "select fieldName1, fieldName2, foreignKey.fieldName from EntityName where condition=? order by fieldName",
    parameterValue
)
```

### Table Names = Entity Names

The `FROM` clause uses entity class names (which map to database table names):

| Entity Class | Table Name | DSQL Query |
|--------------|------------|------------|
| `Person` | `person` | `select * from Person` |
| `Event` | `event` | `select * from Event` |
| `Document` | `document` | `select * from Document` |
| `ScheduledItem` | `scheduled_item` | `select * from ScheduledItem` |
| `Item` | `item` | `select * from Item` |

### Field Names = Column Names

The `SELECT` clause uses field constants from entity classes:

**Example from Person entity**:
```java
// Entity field constants (from Person.java)
String name = "name";                    // Column: name
String birthDate = "birthdate";          // Column: birthdate
String frontendAccount = "frontendAccount"; // FK column: frontend_account

// DSQL query using these fields
"select name, birthDate, frontendAccount from Person"
```

**Example from Event entity**:
```java
// Entity field constants (from Event.java)
String startDate = "startDate";          // Column: start_date
String endDate = "endDate";              // Column: end_date
String type = "type";                    // FK column: type

// DSQL query
"select name, startDate, endDate, type from Event"
```

### Navigating Relationships with Dot Notation

DSQL supports navigating foreign key relationships using dot notation:

```java
// Navigate through relationships
"select name, person.name, person.email, event.name from Document"
//            ^^^^^^^^^^^  ^^^^^^^^^^^^  ^^^^^^^^^^
//            FK to Person  Person field  FK to Event

// Multi-level navigation
"select name, programScheduledItem.event.name, item.family.code from ScheduledItem"
//            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^    ^^^^^^^^^^^^^^^^
//            ScheduledItem → Event → name     ScheduledItem → Item → ItemFamily → code
```

### Real-World DSQL Examples with EntityStore

All these examples use `EntityStore.executeQueryBatch()` for reading data (from VideoTabView.java:276-303):

**Example 1: Query Items** (from VideoTabView.java:277)
```java
new EntityStoreQuery(
    "select distinct name, family.code from Item where organization=? and family.code=? order by name",
    //               ^^^^  ^^^^^^^^^^^                ^^^^^^^^^^^^        ^^^^^^^^^^^
    //               Item  Item→ItemFamily            FK to Org           ItemFamily field
    currentEditedEvent.getOrganization(),
    KnownItem.VIDEO.getCode()
)
```

**Example 2: Query ScheduledItems with nested relationships** (from VideoTabView.java:279)
```java
new EntityStoreQuery(
    "select name, programScheduledItem.(startTime, endTime), date, event, site, " +
    "expirationDate, available, vodDelayed, published, comment, commentLabel, item, item.code, " +
    "programScheduledItem.name, programScheduledItem.timeline.startTime, " +
    "programScheduledItem.timeline.endTime " +
    "from ScheduledItem " +
    "where programScheduledItem.event=? and item.code=? and programScheduledItem.item.family.code=? " +
    "order by date",
    //  ^^^^^^^^^^^^^^^^^^^^^^^^^^      ^^^^^^^^^      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    //  Navigate FK relationships       Item FK field   Multi-level: SI→Item→Family→code
    currentEditedEvent,
    KnownItem.VIDEO.getCode(),
    KnownItemFamily.TEACHING.getCode()
)
```

**Example 3: Query Media with relationships** (from VideoTabView.java:281)
```java
new EntityStoreQuery(
    "select url, scheduledItem.(item, item.code, date, vodDelayed, published) " +
    "from Media " +
    "where scheduledItem.event=? and scheduledItem.item.code=? " +
    "order by id",
    //  ^^^^^^^^^^^^^^^^^^^      ^^^^^^^^^^^^^^^^^^^^^^^
    //  Media→ScheduledItem→Event  Media→ScheduledItem→Item→code
    currentEditedEvent,
    KnownItem.VIDEO.getCode()
)
```

**Complete Batch Query Example** (from VideoTabView.java:276-303):
```java
// Use EntityStore for SELECT queries
entityStore.executeQueryBatch(
    new EntityStoreQuery("select distinct name, family.code from Item where organization=? and family.code=? order by name",
        currentEditedEvent.getOrganization(), KnownItem.VIDEO.getCode()),
    new EntityStoreQuery("select name, programScheduledItem.(startTime, endTime), date, event, site from ScheduledItem where programScheduledItem.event=?",
        currentEditedEvent),
    new EntityStoreQuery("select url, scheduledItem.(item, date) from Media where scheduledItem.event=?",
        currentEditedEvent)
).onFailure(Console::log)
  .inUiThread()
  .onSuccess(entityLists -> {
      // Access results from each query
      EntityList<Item> items = entityLists[0];
      EntityList<ScheduledItem> scheduledItems = entityLists[1];
      EntityList<Media> mediaList = entityLists[2];

      // Process the data
      items.forEach(item -> Console.log(item.getName()));
  });
```

### Understanding Query Results

Query results are returned as `EntityList` which can be cast to specific entity types:

```java
entityStore.executeQuery("select name, email from Person where id=?", personId)
    .onSuccess(entityList -> {
        EntityList<Person> persons = entityList;
        for (Person person : persons) {
            System.out.println(person.getName() + ": " + person.getEmail());
        }
    });
```

**Batch queries** return multiple EntityLists:

```java
entityStore.executeQueryBatch(
    new EntityStoreQuery("select * from Item where organization=?", orgId),
    new EntityStoreQuery("select * from ScheduledItem where event=?", eventId),
    new EntityStoreQuery("select * from Media where scheduledItem.event=?", eventId)
).onSuccess(entityLists -> {
    EntityList<Item> items = entityLists[0];
    EntityList<ScheduledItem> scheduledItems = entityLists[1];
    EntityList<Media> mediaList = entityLists[2];

    // Use the results
    items.forEach(item -> Console.log(item.getName()));
});
```

### How to Find Field Names for Queries

When writing queries, reference the entity class to find exact field names:

**Step 1: Identify the entity** you're querying
- Example: Querying `ScheduledItem` table

**Step 2: Open the entity interface**
- File: `modality-fork/modality-base/modality-base-shared-entities/src/main/java/one/modality/base/shared/entities/ScheduledItem.java`

**Step 3: Look at field constants**
```java
public interface ScheduledItem extends Entity {
    String date = "date";                    // Use in query: select date
    String event = "event";                  // Use in query: select event or where event=?
    String site = "site";                    // Use in query: select site
    String programScheduledItem = "programScheduledItem"; // Use in query: select programScheduledItem.name
    String item = "item";                    // Use in query: select item.code
    String available = "available";          // Use in query: select available
    String vodDelayed = "vodDelayed";        // Use in query: select vodDelayed
    // ... more fields
}
```

**Step 4: Write the query**
```java
"select date, event, site, item.code, available from ScheduledItem where event=?"
```

### Common Query Patterns

#### Pattern 1: Simple selection
```java
"select name, email, birthDate from Person where id=?"
```

#### Pattern 2: Foreign key navigation
```java
"select name, person.name, person.email from Document where event=?"
```

#### Pattern 3: Multi-level navigation
```java
"select name, item.family.code, site.organization.name from ScheduledItem"
```

#### Pattern 4: Grouped field selection
```java
"select name, programScheduledItem.(startTime, endTime, name) from ScheduledItem"
// Parentheses group multiple fields from the same relationship
```

#### Pattern 5: Distinct values
```java
"select distinct date from ScheduledItem where event=? order by date"
```

### Creating and Updating Entities with UpdateStore

After querying data with `EntityStore`, use `UpdateStore` to create or modify entities:

**Creating New Entities (INSERT)**:
```java
// Create UpdateStore
UpdateStore updateStore = UpdateStore.createAbove(entityStore);

// Create new document
Document newDocument = updateStore.createEntity(Document.class);
newDocument.setPerson(person);
newDocument.setEvent(event);
newDocument.setConfirmed(false);
newDocument.setPriceNet(totalPrice);

// Save to database (INSERT)
updateStore.submitChanges()
    .onFailure(Console::log)
    .onSuccess(result -> Console.log("Document created!"));
```

**Updating Existing Entities (UPDATE)**:
```java
// Get existing entity from query
entityStore.executeQuery("select * from Event where id=?", eventId)
    .onSuccess(events -> {
        Event event = events.get(0);

        // Wrap entity for editing with UpdateStore
        Event editableEvent = updateStore.updateEntity(event);

        // Modify fields
        editableEvent.setLivestreamUrl("https://new-stream-url.com");
        editableEvent.setVodExpirationDate(LocalDateTime.now().plusDays(30));

        // Save to database (UPDATE)
        updateStore.submitChanges()
            .onFailure(Console::log)
            .onSuccess(result -> Console.log("Event updated!"));
    });
```

**Real-World Example from VideoTabView.java**:
```java
// 1. Create stores (lines 54-55)
private final EntityStore entityStore = EntityStore.create();
private final UpdateStore updateStore = UpdateStore.createAbove(entityStore);

// 2. Get entity for editing (line 110)
Event currentEvent = updateStore.updateEntity(FXEvent.getEvent());

// 3. Modify entity via UI listeners (lines 128-134)
livestreamGlobalLinkTextField.textProperty().addListener(observable -> {
    if (Objects.equals(livestreamGlobalLinkTextField.getText(), "")) {
        currentEvent.setLivestreamUrl(null);
    } else {
        currentEvent.setLivestreamUrl(livestreamGlobalLinkTextField.getText());
    }
});

// 4. Save changes (lines 197-204)
saveButton.setOnAction(e -> {
    if (validationSupport.isValid()) {
        updateStore.submitChanges()
            .onFailure(Console::log)
            .onSuccess(Console::log);
    }
});
```

**Tracking Changes**:
```java
// Check if UpdateStore has unsaved changes
BooleanExpression hasChangesProperty = EntityBindings.hasChangesProperty(updateStore);

// Bind to UI (disable save button when no changes)
saveButton.disableProperty().bind(hasChangesProperty.not());

// Cancel unsaved changes
updateStore.cancelChanges();
```

## Additional Entity Modules

Besides the base entities, there are additional entity modules:

- **Hotel entities**: `modality-fork/modality-hotel/modality-hotel-shared-entities/`
- **Ecommerce entities**: `modality-fork/modality-ecommerce/modality-ecommerce-shared-entities/`
- **KBS entities**: `kbs3/kbs-shared-entities/` (if exists)

These extend the base system with domain-specific tables.

## Best Practices

1. **Reference entity classes, not SQL** - Entity classes are the source of truth
2. **Use entity methods for relationships** - Don't manually join tables
3. **Follow ORM patterns** - Use EntityStore for queries and changes
4. **Check field constants** - Always use entity constants instead of string literals
5. **Understand marker interfaces** - They provide common functionality

## Database Connection

See [Configuration](configuration.md) for database connection setup.

---
[← Back to Main Documentation](../../CLAUDE.md)
