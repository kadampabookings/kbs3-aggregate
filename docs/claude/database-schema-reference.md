# Database Schema Reference

Quick reference to the KBS3 database structure (PostgreSQL 17.5). This document provides a lightweight overview of tables, key fields, and relationships.

**Database**: `kbs_db`
**Tables**: 123 tables
**Source**: `kbs-database-structure.sql` (repository root)

## Using This Reference

- **For DSQL queries**: See [Database Entities](database-entities.md) - use entity classes as they're easier to work with
- **For understanding structure**: This document - quick table/field reference
- **For detailed constraints**: See `kbs-database-structure.sql` at repository root

## Table Organization

Tables are organized by functional area:

- [Core Entities](#core-entities) - Person, Organization, Event, Document
- [Booking & Items](#booking--items) - Document lines, Items, Sites, Rates
- [Scheduling](#scheduling) - ScheduledItem, ScheduledResource, Timeline
- [Financial](#financial) - MoneyAccount, MoneyFlow, MoneyTransfer
- [Content](#content) - News, Podcast, Video, Book, Media
- [Authorization](#authorization) - Roles, Rules, Assignments
- [System](#system) - Label, Image, Filter, History

---

## Core Entities

### person
Customer/participant records

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(255) | Full name |
| birthdate | date | Date of birth |
| email | varchar(255) | Email address |
| phone | varchar(32) | Phone number |
| frontend_account_id | integer | FK → frontend_account |
| account_person_id | integer | FK → person (account holder) |
| branch_id | integer | FK → organization |
| language_id | integer | FK → language |
| country_geonameid | integer | GeoNames country ID |
| country_code | varchar(2) | ISO country code |
| removed | boolean | Soft delete flag |
| never_booked | boolean | Has never made a booking |

### organization
Centers, venues, branches

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(64) | Organization name |
| type_id | integer | FK → organization_type |
| country_id | integer | FK → country |
| closed | boolean | Is closed/inactive |
| corporation_id | integer | FK → organization (parent corp) |

### event
Events, courses, retreats

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(255) | Event name |
| organization_id | integer | FK → organization |
| type_id | integer | FK → event_type |
| state | varchar(16) | Event state (draft, published, etc.) |
| start_date | date | Start date |
| end_date | date | End date |
| opening_date | timestamp | Bookings open date/time |
| venue_id | integer | FK → site |
| live | boolean | Is live event |
| kbs3 | boolean | Uses KBS3 system |
| vod_expiration_date | timestamp | Video-on-demand expiration |
| livestream_url | varchar(512) | Livestream URL |
| advertised | boolean | Publicly advertised |

### document
Bookings, orders, invoices

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| ref | integer | Reference number |
| organization_id | integer | FK → organization |
| event_id | integer | FK → event |
| person_id | integer | FK → person |
| cart_id | integer | FK → cart |
| activity_id | integer | FK → activity |
| creation_date | timestamp | Created at |
| confirmed | boolean | Booking confirmed |
| cancelled | boolean | Booking cancelled |
| read | boolean | Marked as read |
| arrived | boolean | Person arrived |
| price_net | integer | Net price (cents) |
| price_deposit | integer | Deposit amount (cents) |

### frontend_account
User login accounts

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| email | varchar(255) | Login email |
| username | varchar(64) | Username |
| corporation_id | integer | FK → organization |

---

## Booking & Items

### document_line
Line items within bookings

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| document_id | integer | FK → document |
| item_id | integer | FK → item |
| site_id | integer | FK → site |
| quantity | integer | Quantity |
| price_net | integer | Net price (cents) |
| price_is_custom | boolean | Custom pricing |
| cancelled | boolean | Line cancelled |

### item
Bookable items/options

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(128) | Item name |
| family_id | integer | FK → item_family |
| organization_id | integer | FK → organization |
| code | varchar(16) | Item code |
| label_id | integer | FK → label (i18n) |
| share_item_id | integer | FK → item (shared item) |

### item_family
Item categories

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(64) | Family name |
| code | varchar(16) | Family code |
| icon_id | integer | FK → image |
| label_id | integer | FK → label (i18n) |

### site
Venues, locations

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(64) | Site name |
| organization_id | integer | FK → organization |
| item_family_id | integer | FK → item_family |
| main | boolean | Is main site |

### site_item
Site-specific item availability

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| site_id | integer | FK → site |
| item_id | integer | FK → item |
| available | integer | Available quantity |
| online | boolean | Bookable online |

### rate
Pricing rules

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| item_id | integer | FK → item |
| site_id | integer | FK → site |
| price | integer | Price (cents) |
| currency_id | integer | FK → currency |
| start_date | date | Valid from date |
| end_date | date | Valid to date |
| per_day | boolean | Price per day |
| min_deposit | integer | Minimum deposit (cents) |

---

## Scheduling

### scheduled_item
Scheduled activities/sessions

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(255) | Session name |
| event_id | integer | FK → event |
| site_id | integer | FK → site |
| item_id | integer | FK → item |
| date | date | Session date |
| program_scheduled_item_id | integer | FK → scheduled_item (program) |
| timeline_id | integer | FK → timeline |
| available | boolean | Available for booking |
| published | boolean | Published |
| vod_delayed | boolean | Video on demand delayed |

### scheduled_resource
Resources assigned to sessions

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| scheduled_item_id | integer | FK → scheduled_item |
| resource_id | integer | FK → resource |
| resource_configuration_id | integer | FK → resource_configuration |

### timeline
Daily schedules

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| event_id | integer | FK → event |
| day_template_id | integer | FK → day_template |
| date | date | Timeline date |
| start_time | time | Day start time |
| end_time | time | Day end time |

### resource
Teachers, facilitators, equipment

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(128) | Resource name |
| configuration_id | integer | FK → resource_configuration |
| person_id | integer | FK → person (for teachers) |

---

## Financial

### money_account
Financial accounts

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(64) | Account name |
| organization_id | integer | FK → organization |
| type_id | integer | FK → money_account_type |
| balance | integer | Current balance (cents) |
| closed | boolean | Account closed |

### money_flow
Financial transactions

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| date | timestamp | Transaction date |
| document_id | integer | FK → document |
| money_account_id | integer | FK → money_account |
| amount | integer | Amount (cents) |
| comment | varchar(1024) | Transaction note |

### money_transfer
Money transfers between accounts

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| date | timestamp | Transfer date |
| document_id | integer | FK → document |
| from_money_account_id | integer | FK → money_account |
| to_money_account_id | integer | FK → money_account |
| amount | integer | Transfer amount (cents) |
| method_id | integer | FK → method (payment method) |
| payment | boolean | Is payment |
| refund | boolean | Is refund |
| pending | boolean | Pending status |
| successful | boolean | Successfully processed |

### method
Payment methods

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(64) | Method name |
| gateway_company_id | integer | FK → gateway_company |

### gateway_company
Payment gateway providers

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(64) | Gateway name |
| code | varchar(16) | Gateway code |

---

## Content

### news
News articles

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| title | varchar(255) | Article title |
| organization_id | integer | FK → organization |
| date | date | Publication date |
| image_id | integer | FK → image |
| transcript | text | Article content |
| excerpt | text | Short excerpt |
| url | varchar(512) | External URL |

### podcast
Podcast episodes

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| title | varchar(255) | Episode title |
| date | date | Release date |
| audio_url | varchar(512) | Audio file URL |
| teacher_id | integer | FK → teacher |
| duration_millis | bigint | Duration (milliseconds) |

### video
Video content

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(128) | Video name |
| title | varchar(255) | Display title |
| url | varchar(512) | Video URL |
| duration_millis | bigint | Duration (milliseconds) |

### book
Book catalog

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| title | varchar(255) | Book title |
| teacher_id | integer | FK → teacher |
| url | varchar(512) | Purchase/info URL |
| image_id | integer | FK → image (cover) |

### media
Generic media files

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| url | varchar(512) | Media URL |
| scheduled_item_id | integer | FK → scheduled_item |
| type_id | integer | FK → media_type |
| duration_millis | bigint | Duration (milliseconds) |

### teacher
Teachers/presenters

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| person_id | integer | FK → person |
| name | varchar(128) | Display name |
| organization_id | integer | FK → organization |

---

## Authorization

### authorization_role
User roles

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(64) | Role name |

### authorization_rule
Access rules

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(64) | Rule name |
| rule | varchar(255) | Rule expression |

### authorization_assignment
Role/rule assignments

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| management_id | integer | FK → authorization_management |
| scope_id | integer | FK → authorization_scope |
| role_id | integer | FK → authorization_role |
| rule_id | integer | FK → authorization_rule |
| active | boolean | Assignment active |

### authorization_management
User management relationships

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| manager_id | integer | FK → frontend_account |
| user_id | integer | FK → frontend_account |
| active | boolean | Relationship active |

---

## System

### label
Multilingual labels (i18n)

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| code | varchar(16) | Label code |
| de | text | German text |
| en | text | English text |
| es | text | Spanish text |
| fr | text | French text |
| pt | text | Portuguese text |
| vi | text | Vietnamese text |
| zh | text | Chinese text |

### image
Image references

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| url | varchar(512) | Image URL |
| cloudinary_public_id | varchar(255) | Cloudinary ID |

### filter
Saved search filters

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| name | varchar(64) | Filter name |
| activity_state_id | integer | FK → activity_state |
| fields | text | Field definitions |
| order_by | varchar(512) | Sort order |
| group_by | varchar(512) | Grouping |

### history
Change audit log

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| date | timestamp | Change date |
| user_id | integer | FK → frontend_account |
| comment | text | Change description |
| record | text | Changed data |

### language
Language definitions

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| code | varchar(2) | ISO language code |
| name | varchar(64) | Language name |

### country
Country definitions

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| code | varchar(2) | ISO country code |
| name | varchar(64) | Country name |
| geonameid | integer | GeoNames ID |

### currency
Currency definitions

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Primary key |
| code | varchar(3) | ISO currency code |
| symbol | varchar(8) | Currency symbol |

---

## Additional Tables

### Other Important Tables

| Table | Description |
|-------|-------------|
| `cart` | Shopping carts |
| `multiple_booking` | Group bookings |
| `attendance` | Session attendance tracking |
| `bookable_period` | Bookable time periods |
| `day_template` | Daily schedule templates |
| `allocation_rule` | Resource allocation rules |
| `kdm_center` | KDM (Kadampa) center sync |
| `magic_link` | Passwordless login links |
| `mail` | Email queue |
| `error` | Error logging |
| `snapshot` | Data snapshots |
| `activity` | Activity types |
| `activity_state` | UI activity states |
| `channel` | Communication channels |
| `topic` | Content topics/categories |

### Accounting Tables

| Table | Description |
|-------|-------------|
| `accounting_account` | Chart of accounts |
| `accounting_account_type` | Account types |
| `accounting_model` | Accounting models |

### Banking Tables

| Table | Description |
|-------|-------------|
| `bank` | Bank information |
| `bank_system` | Banking systems |
| `bank_system_account` | Bank account mapping |

---

## Common Field Patterns

### Primary Keys
All tables use `id integer NOT NULL` as primary key with auto-increment sequences.

### Foreign Keys
Foreign keys follow the pattern: `{table_name}_id` pointing to `{table_name}.id`

Examples:
- `person_id` → `person.id`
- `event_id` → `event.id`
- `organization_id` → `organization.id`

### Timestamps
- `date` - Date only (date type)
- `creation_date`, `date` - Timestamp (timestamp without time zone)
- Often defaults to `now()`

### Booleans
- Default to `false` or `true` depending on meaning
- Common flags: `active`, `closed`, `cancelled`, `confirmed`, `published`

### Money Amounts
- Stored as **integers** in **cents** (not decimals)
- Example: $50.00 stored as 5000
- Fields: `price`, `price_net`, `amount`, `balance`, etc.

### Soft Deletes
- `removed` boolean - Mark as deleted without actual deletion
- `cancelled` boolean - Cancel booking/order
- `closed` boolean - Close account/organization

### i18n Fields
- `label_id` → `label` table for multilingual text
- Some tables have language-specific columns (de, en, es, fr, pt, vi, zh)

---

## Using This Reference

### For Writing DSQL Queries

1. **Find the table** in this document
2. **Check the field names** you need
3. **Look at foreign key relationships** for joins
4. **See [Database Entities](database-entities.md)** for DSQL query syntax

### Example Workflow

**Task**: Get all bookings for an event with customer names

1. **Tables**: `document` (bookings), `person` (customers)
2. **Key fields**:
   - `document`: id, event_id, person_id, confirmed
   - `person`: id, name, email
3. **Relationship**: `document.person_id` → `person.id`
4. **DSQL Query**:
   ```java
   entityStore.executeQuery(
       "select ref, person.name, person.email, confirmed, price_net from Document where event=?",
       eventId
   )
   ```

### For Understanding Structure

Use this document to:
- See what fields are available on each table
- Understand relationships between tables
- Find the right table for your data needs
- Plan database queries

### For Detailed Information

For constraints, indexes, triggers, and full DDL:
- See `kbs-database-structure.sql` at repository root
- File is large (complete schema dump) but has all details

---

## Quick Search

**Need customer data?** → `person`, `frontend_account`
**Need booking data?** → `document`, `document_line`
**Need event data?** → `event`, `event_type`, `site`
**Need item/pricing?** → `item`, `item_family`, `rate`
**Need financial data?** → `money_account`, `money_flow`, `money_transfer`
**Need schedule data?** → `scheduled_item`, `timeline`, `resource`
**Need content?** → `news`, `podcast`, `video`, `book`, `media`
**Need translations?** → `label` (multilingual table)

---

[← Back to Main Documentation](../../CLAUDE.md)
