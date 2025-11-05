# Module Conventions

This document covers CSS styling, internationalization (i18n), and configuration file conventions used throughout the KBS3 project.

## CSS File Conventions

Each module can have both JavaFX and Web CSS files. Since the project compiles to both native JavaFX and GWT (web), separate CSS files are maintained for each platform.

### Location and Naming

**Location**: `src/main/webfx/css/`

**Naming Pattern**: `[module-name]-[platform]@main.css`

- **JavaFX CSS**: `[module-name]-javafx@main.css`
- **Web CSS**: `[module-name]-web@main.css`

**Examples**:
```
kbs-backoffice-festivalcreator-javafx@main.css
kbs-backoffice-festivalcreator-web@main.css

modality-client-brand-javafx@main.css
modality-client-brand-web@main.css

webfx-extras-bootstrap-javafx@main.css
webfx-extras-bootstrap-web@main.css
```

### CSS Syntax Differences

#### JavaFX CSS

```css
.root {
    /* Variables without -- prefix */
    -kbs-spring-color: #8BC34A;
    -brand-orange-color: #FF6B35;
}

.my-button {
    /* JavaFX properties with -fx- prefix */
    -fx-font-family: "Arial";
    -fx-text-fill: -brand-orange-color;
    -fx-background-color: -kbs-spring-color;

    /* WebFX properties with -webfx- prefix */
    -webfx-aria-toggle-button-background-color-fired: #FF0000;
}
```

#### Web CSS

```css
:root {
    /* Variables with -- prefix */
    --kbs-spring-color: #8BC34A;
    --brand-orange-color: #FF6B35;
}

.my-button {
    /* Standard CSS properties */
    font-family: "Arial";
    color: var(--brand-orange-color);
    background-color: var(--kbs-spring-color);
}

/* Custom element selectors */
fx-button {
    border-radius: 4px;
}
```

### Critical CSS Styling Rule

**IMPORTANT**: Min, max, and preferred widths/heights, as well as padding, should be set in **Java code**, NOT in CSS.

This ensures consistent behavior across both JavaFX and Web platforms. CSS should only be used for visual styling (colors, fonts, borders, etc.).

#### ✅ Correct Approach - In Java Code

```java
button.setMinWidth(100);
button.setPrefWidth(150);
button.setMaxWidth(200);
button.setPadding(new Insets(10, 20, 10, 20));

// For layouts
HBox hbox = new HBox(10); // spacing
hbox.setPadding(new Insets(15));
```

#### ❌ Incorrect Approach - In CSS

```css
/* DO NOT DO THIS */
.my-button {
    -fx-min-width: 100px;
    -fx-pref-width: 150px;
    -fx-padding: 10 20 10 20;
}
```

### CSS Best Practices

1. **Use CSS variables** for colors, fonts, and reusable values
2. **Keep platform-specific files in sync** for visual consistency
3. **Test on both platforms** when making CSS changes

## Internationalization (i18n)

The project supports 7 languages with consistent file naming conventions.

### Critical Rule: Use I18nControls for Automatic Language Binding

**ALWAYS use `I18nControls` methods** when creating UI elements to ensure automatic language updates when users switch languages.

**❌ WRONG** - No automatic language updates:
```java
Label label = new Label(I18n.getI18nText(key));  // Gets text ONCE, won't update
Button button = new Button(I18n.getI18nText(key));  // Gets text ONCE, won't update
```

**✅ CORRECT** - Automatic language updates:
```java
Label label = I18nControls.newLabel(key);  // Creates binding, updates automatically
Button button = I18nControls.newButton(key);  // Creates binding, updates automatically
```

**Why this matters**:
- `I18nControls` methods create **bindings** to the i18n dictionary
- When users change language, all bound controls update automatically
- `I18n.getI18nText()` returns a **static string** - no binding, no updates

**Available methods**:
- `I18nControls.newLabel(key)` - Create Label with binding
- `I18nControls.newButton(key)` - Create Button with binding
- `I18nControls.newCheckBox(key)` - Create CheckBox with binding
- `I18nControls.newRadioButton(key)` - Create RadioButton with binding
- `I18nControls.newHyperlink(key)` - Create Hyperlink with binding
- `I18nControls.newToggleButton(key)` - Create ToggleButton with binding
- `I18n.bindI18nTextProperty(property, key)` - Bind existing property (e.g., promptText)
- `I18nControls.bindI18nProperties(control, key)` - Bind all properties on existing control

**See also**: [Code Review Guidelines - I18n Rules](code-review-guidelines.md#internationalization-i18n-rules) for complete details.

### Supported Languages

| Language | Suffix | Example |
|----------|--------|---------|
| English | `_en` / `@en` | `module_en.properties`, `module@en.yaml` |
| French | `_fr` / `@fr` | `module_fr.properties`, `module@fr.yaml` |
| German | `_de` / `@de` | `module_de.properties`, `module@de.yaml` |
| Spanish | `_es` / `@es` | `module_es.properties`, `module@es.yaml` |
| Portuguese | `_pt` / `@pt` | `module_pt.properties`, `module@pt.yaml` |
| Vietnamese | `_vi` / `@vi` | `module_vi.properties`, `module@vi.yaml` |
| Chinese | `_zh` / `@zh` | `module_zh.properties`, `module@zh.yaml` |

### Properties Files (.properties)

Used for **translations** (internationalization) - text that varies by language.

**Location**: `src/main/webfx/i18n/`

**Naming Pattern**: `[module-name]_[language].properties`

**Examples**:
```
kbs-client-festivaltypes_en.properties
kbs-client-festivaltypes_fr.properties
modality-base-i18n_en.properties
modality-base-i18n_de.properties
override_modality-client-brand_en.properties
```

**Format**:
```properties
# English translations
BookingLabel=Booking
ConfirmButton=Confirm
CancelButton=Cancel

# With parameters (RECOMMENDED for dynamic text)
WelcomeMessage=Welcome, {0}!
BookingConfirmation=Your booking #{0} has been confirmed.
PersonAlreadyBooked1={0} is already booked for this event.
MustBeInRange2=Must be between {0} and {1}
AssignRoleSummaryText=Summary: The selected user will have {0} access for role {1} in {2}.
```

**CRITICAL: Use Parameters Instead of Concatenation**

**❌ WRONG** - Concatenating multiple i18n calls:
```java
// BAD: Multiple separate i18n calls concatenated
Label msg = new Label(I18n.getI18nText(Delete) + " " + I18n.getI18nText(Space) +
                      role.getName() + I18n.getI18nText(QuestionMark));

// BAD: No binding, won't update on language change, and hard to translate
String message = I18n.getI18nText(WelcomeText) + " " + userName + "!";
```

**Problems with concatenation**:
1. **No binding** - Text won't update when user changes language
2. **Word order differs by language** - "Delete role Admin?" in English becomes "Supprimer le rôle Admin ?" in French
3. **Hard for translators** - They see fragments, not complete sentences
4. **Punctuation varies** - Spaces, question marks, colons differ across languages

**✅ CORRECT** - Use parameters in .properties file:
```properties
# In your_module_en.properties
ConfirmDeleteRole=Are you sure you want to delete the role "{0}"?
WelcomeMessage=Welcome, {0}!
UserAccessSummary=The selected user will have {0} access for role {1} in {2}.
EditEventInformation=Edit event information: {0}
ModifyBookingNumber=Modify booking number {0}
OnlineFestivalAvailableUntil=Video recordings will be available online until {0}.
```

```properties
# In your_module_fr.properties
ConfirmDeleteRole=Êtes-vous sûr de vouloir supprimer le rôle « {0} » ?
WelcomeMessage=Bienvenue, {0} !
UserAccessSummary=L'utilisateur sélectionné aura un accès {0} pour le rôle {1} dans {2}.
EditEventInformation=Modifier les informations de l'événement: {0}
ModifyBookingNumber=Modifier la réservation numéro {0}
OnlineFestivalAvailableUntil=Les enregistrements vidéo seront disponibles en ligne jusqu'au {0}.
```

```java
// GOOD: Single i18n call with parameters - allows proper translation
Label msg = new Label();
msg.textProperty().bind(I18n.i18nTextProperty(ConfirmDeleteRole, role.getName()));

// GOOD: With binding for automatic language updates
errorMessageProperty.bind(I18n.i18nTextProperty(MustBeInRange2, minValue, maxValue));

// GOOD: Multiple parameters in correct order for each language
Label summary = new Label();
summary.textProperty().bind(I18n.i18nTextProperty(UserAccessSummary,
    accessLevel, roleName, organizationName));
```

**Parameter syntax**:
- `{0}` - First parameter
- `{1}` - Second parameter
- `{2}` - Third parameter
- And so on...

**Real-world examples from the codebase**:
```java
// Example 1: Date range validation
errorMessageProperty.bind(I18n.i18nTextProperty(
    OnlineFestivalI18nKeys.MustBeInRange2,
    priceFormatter.apply(minAmount),
    priceFormatter.apply(maxAmount)
));

// Example 2: Event information
event.setName(I18n.getI18nText(
    "[{0}] Festival {1} Online",
    festivalType.getShortI18nKey(),
    year
));

// Example 3: Refund message
String refundMessage = I18n.getI18nText(
    OrderI18nKeys.RefundMessage,
    contactEmail
);
```

### YAML Files (.yaml)

Used for **language-independent resources** and common properties that are the same across all languages.

**IMPORTANT**: YAML files (even language-specific ones like `@en.yaml`) should contain **only elements that don't need translation**:
- SVG paths and graphics
- Image file paths
- Icons references
- Technical identifiers
- Structured metadata

**Text that needs translation** should be in `.properties` files, NOT in YAML files.

**Location**: `src/main/webfx/i18n/` or `src/main/webfx/conf/`

**Naming Patterns**:
- Resource files: `[module-name]@[language].yaml` (language suffix is convention, but content is language-independent)
- Configuration files: `[namespace].yaml`
- Overrides: `override@[original-name]@[language].yaml` or `override@[namespace].yaml`

**Examples**:
```
modality-base-i18n@en.yaml
kbs-backoffice-i18n-forwards@en.yaml
modality.base.client.i18n.yaml
override@modality.base.client.i18n.yaml
```

**Format** - Language-independent resources only:
```yaml
# Graphics and icons (same for all languages)
DeleteRoom:
  text: "Delete room"  # This is just a fallback/identifier, real translation in .properties
  graphic: "images/s16/actions/delete.png"  # Same image path for all languages

EditRoomProperties:
  text: "Edit room properties"
  graphic: "images/s16/actions/edit.png"

# Icon references
OpenBookingCart:
  graphic: "images/s16/cart.png"

CancelOthers:
  graphic: "images/s16/actions/cancel.png"

# Dynamic graphics based on expressions
ShowBookingEditor:
  graphic: "[expression: genderIcon]"

ToggleMarkNotMultipleBooking:
  graphic: "[expression: multipleBooking = null ? '[MarkMultipleBooking]' : '[MarkNotMultipleBooking]' ]"
```

**Real-world examples from the codebase**:

`modality-hotel-backoffice-resourceconfiguration@en.yaml`:
```yaml
ChangeRoomType: "Change room type"
DeleteRoom:
  text: "Delete room"
  graphic: "images/s16/actions/delete.png"
EditRoomProperties:
  text: "Edit room properties"
  graphic: "images/s16/actions/edit.png"
ToggleOnlineOffline: "Toggle online/offline"
```

`modality-ecommerce-backoffice-document@en.yaml`:
```yaml
OpenBookingCart:
  graphic: "images/s16/cart.png"
CancelOthers:
  graphic: "images/s16/actions/cancel.png"
MarkMultipleBooking:
  graphic: "images/s16/multipleBookings/redCross.png"
MarkAsArrived:
  graphic: "images/s16/actions/markAsArrived.png"
```

**Key principle**: If it varies by language, use `.properties`. If it's the same for all languages (like image paths, SVG data, icons), use `.yaml`.

### Configuration Files

**Location**: `src/main/webfx/conf/`

**Types**:

1. **Declaration files**: `declare@[namespace].properties`
   - Declares that a module provides a service or functionality

2. **Override files**: `override@[namespace].properties` or `override@[namespace].yaml`
   - Overrides or extends existing configuration/translations

3. **Global configuration**: `global-variables.properties`
   - Project-wide configuration values

4. **Application configuration**: `src/main/resources/dev/webfx/platform/conf/src-root.properties`
   - Root application configuration (origins, API keys)

**Example - declare file**:
```properties
# declare@modality.base.client.i18n.properties
# This module provides i18n services
```

**Example - override file**:
```properties
# override@modality.base.client.i18n.properties
# Override specific translations from base module
BookingLabel=Reservation
```

### Translation Key Forwarding

Some modules use forwarding files to map translation keys between modules.

**Naming**: `[module-name]-forwards@[language].yaml`

**Example**: `kbs-backoffice-i18n-forwards@en.yaml`
```yaml
# Maps keys from one module to another
NewKey: ExistingModule.ExistingKey
CustomLabel: modality.base.StandardLabel
```

### Special Naming Conventions

- `declare@[namespace]` - Declares a module/service provides functionality
- `override@[namespace]` - Overrides or extends existing configuration/translations
- `[name]-forwards` - Translation key forwarding/mapping between modules

## File Location Summary

| File Type | Location | Pattern | Example |
|-----------|----------|---------|---------|
| JavaFX CSS | `src/main/webfx/css/` | `[name]-javafx@main.css` | `kbs-backoffice-festivalcreator-javafx@main.css` |
| Web CSS | `src/main/webfx/css/` | `[name]-web@main.css` | `kbs-backoffice-festivalcreator-web@main.css` |
| YAML i18n | `src/main/webfx/i18n/` | `[name]@[lang].yaml` | `modality-base-i18n@en.yaml` |
| Properties i18n | `src/main/webfx/i18n/` | `[name]_[lang].properties` | `kbs-client-festivaltypes_en.properties` |
| YAML config | `src/main/webfx/conf/` | `[namespace].yaml` | `modality.base.client.i18n.yaml` |
| Properties config | `src/main/webfx/conf/` | `[name].properties` | `global-variables.properties` |
| App config | `src/main/resources/dev/webfx/platform/conf/` | `src-root.properties` | Application-level configuration |

## Best Practices

### CSS
1. Set sizing and padding in Java code, not CSS
2. Maintain both JavaFX and Web CSS files for visual consistency
3. Use CSS variables for reusable values
4. Test on both platforms after changes

### i18n
1. **Use `I18nControls` methods** for creating UI elements (ensures automatic language updates)
2. **Avoid `I18n.getI18nText()`** for control creation (no binding, won't update on language change)
3. **Use parameters (`{0}`, `{1}`, etc.) instead of concatenation** - allows proper word order per language
4. **YAML files for language-independent resources** (SVG, icons, image paths) - same for all languages
5. **Properties files for translations** - text that varies by language
6. Always provide translations for all 7 supported languages
7. Use descriptive key names that indicate purpose
8. Keep translation files organized by module

### Configuration
1. Use `declare@` files to register module capabilities
2. Use `override@` files to customize existing modules
3. Keep sensitive data out of committed config files
4. Document configuration options in comments

### Workflow
1. Make changes to CSS/properties/YAML files
2. Build project
3. Test on target platforms

## GWT-Compatible UI Patterns

### Entity Selection with EntityButtonSelector

Due to GWT compilation limitations, standard JavaFX selection controls like `ComboBox` and `ChoiceBox` don't work correctly on the web platform. Instead, use `EntityButtonSelector` for entity selection.

**Location**: `webfx-extras-fork/webfx-extras-entity-controls/src/main/java/dev/webfx/extras/entity/controls/EntityButtonSelector.java`

#### ❌ Don't Use ComboBox/ChoiceBox

```java
// ❌ WRONG - Doesn't compile with GWT
ComboBox<Person> personSelector = new ComboBox<>();
personSelector.getItems().addAll(personList);

ChoiceBox<Event> eventSelector = new ChoiceBox<>();
eventSelector.getItems().addAll(eventList);
```

#### ✅ Use EntityButtonSelector

```java
// ✅ CORRECT - GWT-compatible
EntityButtonSelector<Person> personSelector = createPersonButtonSelector(dataSourceModel);
Button personButton = personSelector.getButton();
personButton.setMaxWidth(Double.MAX_VALUE);

// Set selection
personSelector.setSelectedItem(person);

// Get selection
Person selected = personSelector.getSelectedItem();

// Listen to changes
personSelector.selectedItemProperty().addListener((obs, oldVal, newVal) -> {
    // Handle selection change
});
```

### Creating an EntityButtonSelector

#### Basic Pattern

```java
private EntityButtonSelector<Person> createPersonButtonSelector(DataSourceModel dataSourceModel) {
    // JSON query configuration
    String query = "{"
        + "class: 'Person', "
        + "alias: 'p', "
        + "columns: [{expression: '[firstName,lastName,`(` + email + `)`]'}], "
        + "where: 'owner and !removed and frontendAccount.(backoffice and !disabled)', "
        + "orderBy: 'firstName,lastName'"
        + "}";

    // Create selector with search dialog
    return new EntityButtonSelector<Person>(
        query,
        new ButtonFactoryMixin() {},  // Button factory for dialog
        FXMainFrameDialogArea::getDialogArea,  // Dialog area provider
        dataSourceModel
    )
    .setSearchCondition("abcNames(p..fullName) like ?abcSearchLike or lower(p..email) like ?searchEmailLike");
}
```

#### JSON Query Configuration

The EntityButtonSelector uses JSON-based query configuration:

**JSON Query Parameters**:
- `class` - Entity class name (e.g., 'Person', 'Event', 'AuthorizationRole')
- `alias` - Short alias for the entity (e.g., 'p', 'e', 'r')
- `columns` - Array of column expressions to display
  - `expression` - DSQL expression (e.g., 'name', '[firstName,lastName]', '`(` + email + `)`')
- `where` - Filter condition (e.g., 'owner and !removed')
- `orderBy` - Sorting specification (e.g., 'firstName,lastName', 'name')

**Examples**:
```java
// Simple entity selection
String roleQuery = "{class: 'AuthorizationRole', alias: 'r', columns: [{expression: 'name'}], orderBy: 'name'}";

// With specific filtering
String personQuery = "{class: 'Person', alias: 'p', columns: [{expression: '[firstName,lastName]'}], where: 'owner and !removed', orderBy: 'firstName,lastName'}";

// With complex display expression
String eventQuery = "{class: 'ScheduledEvent', alias: 'e', columns: [{expression: 'name,timeline'}], where: 'event=?', orderBy: 'timeline.startTime'}";
```

### Complete Examples

#### Person Selector with Search

```java
/**
 * Creates a selector for choosing a Person from filtered list
 */
private static EntityButtonSelector<Person> createPersonButtonSelector(
    DataSourceModel dataSourceModel) {

    String query = "{"
        + "class: 'Person', "
        + "alias: 'p', "
        + "columns: [{expression: '[firstName,lastName,`(` + email + `)`]'}], "
        + "where: 'owner and !removed and frontendAccount.(backoffice and !disabled)', "
        + "orderBy: 'firstName,lastName'"
        + "}";

    return new EntityButtonSelector<Person>(
        query,
        new ButtonFactoryMixin() {},
        FXMainFrameDialogArea::getDialogArea,
        dataSourceModel
    )
    // Add search functionality
    .setSearchCondition("abcNames(p..fullName) like ?abcSearchLike or lower(p..email) like ?searchEmailLike");
}
```

#### Role Selector

```java
/**
 * Creates a selector for choosing an AuthorizationRole
 */
private static EntityButtonSelector<Entity> createRoleButtonSelector(
    DataSourceModel dataSourceModel,
    ButtonSelectorParameters buttonSelectorParameters) {

    String roleJson = "{"
        + "class: 'AuthorizationRole', "
        + "alias: 'r', "
        + "columns: [{expression: 'name'}], "
        + "orderBy: 'name'"
        + "}";

    return new EntityButtonSelector<>(roleJson, dataSourceModel, buttonSelectorParameters);
}
```

#### Event Selector with Dynamic Filtering

```java
/**
 * Creates a selector for choosing a ScheduledEvent within a specific Event
 */
private static EntityButtonSelector<ScheduledEvent> createScheduledEventButtonSelector(
    DataSourceModel dataSourceModel,
    ButtonSelectorParameters buttonSelectorParameters,
    Event currentEvent) {

    String eventJson = "{"
        + "class: 'ScheduledEvent', "
        + "alias: 'e', "
        + "columns: [{expression: 'name,timeline'}], "
        + "where: 'event=?', "
        + "orderBy: 'timeline.startTime'"
        + "}";

    return new EntityButtonSelector<ScheduledEvent>(
        eventJson,
        dataSourceModel,
        buttonSelectorParameters,
        currentEvent  // Pass parameter for WHERE clause
    );
}
```

### Key Methods

#### Creation and Configuration
```java
// Create with full parameters
EntityButtonSelector<Person> selector = new EntityButtonSelector<>(
    query,                              // JSON query string
    buttonFactory,                      // Button factory
    dialogAreaProvider,                 // Dialog area
    dataSourceModel                     // Data source
);

// Add search condition
selector.setSearchCondition("abcNames(p..fullName) like ?abcSearchLike");

// Set button to full width
selector.getButton().setMaxWidth(Double.MAX_VALUE);
```

#### Selection Management
```java
// Set selected item
selector.setSelectedItem(person);

// Get selected item
Person selected = selector.getSelectedItem();

// Clear selection
selector.setSelectedItem(null);

// Get button for layout
Button button = selector.getButton();
```

#### Listening to Changes
```java
// Listen to selection changes
selector.selectedItemProperty().addListener((observable, oldValue, newValue) -> {
    if (newValue != null) {
        Console.log("Selected: " + newValue.getName());
    }
});

// Use in property binding
userSelector.selectedItemProperty().addListener((obs, oldUser, newUser) -> {
    updateFormState();
});
```

### Integration in Forms

```java
// Create form container
VBox formContainer = new VBox(10);

// Person selector
Label userLabel = I18nControls.newLabel(AdminI18nKeys.User);
EntityButtonSelector<Person> userSelector = createPersonButtonSelector(dataSourceModel);
Button userButton = userSelector.getButton();
userButton.setMaxWidth(Double.MAX_VALUE);

// Role selector
Label roleLabel = I18nControls.newLabel(AdminI18nKeys.Role);
EntityButtonSelector<Entity> roleSelector = createRoleButtonSelector(dataSourceModel, buttonSelectorParameters);
Button roleButton = roleSelector.getButton();
roleButton.setMaxWidth(Double.MAX_VALUE);

// Add to form
formContainer.getChildren().addAll(
    userLabel, userButton,
    roleLabel, roleButton
);

// Set initial values
userSelector.setSelectedItem(currentUser);
roleSelector.setSelectedItem(currentRole);

// Handle changes
userSelector.selectedItemProperty().addListener((obs, old, newUser) -> {
    validateForm();
});
```

### ButtonSelectorParameters

For simplified selectors without search dialogs:

```java
ButtonSelectorParameters buttonSelectorParameters = new ButtonSelectorParameters();
buttonSelectorParameters.setShowDialog(false);  // No search dialog

EntityButtonSelector<Entity> selector = new EntityButtonSelector<>(
    query,
    dataSourceModel,
    buttonSelectorParameters
);
```

### When to Use EntityButtonSelector

**Use EntityButtonSelector when**:
- Selecting entities from the database (Person, Event, Role, etc.)
- Need cross-platform compatibility (Web/Desktop/Mobile)
- Want integrated search functionality
- Need to display entity data in a button

**Don't use EntityButtonSelector for**:
- Simple string selections (use RadioButton or custom button group)
- Hardcoded options (use enum-based button groups)
- Non-entity selections (use appropriate JavaFX controls that work with GWT)

### Real-World Reference

**Example file**: `modality-fork/modality-crm/modality-crm-backoffice-activity-admin-plugin/src/main/java/one/modality/crm/backoffice/activities/admin/AssignUserAndRoleToOrganizationDialog.java`

This file demonstrates:
- Creating Person selectors with search
- Creating Role selectors
- Creating Organization selectors
- Setting initial selections
- Handling selection changes
- Integrating selectors in dialog forms

---
[← Back to Main Documentation](../../CLAUDE.md)
