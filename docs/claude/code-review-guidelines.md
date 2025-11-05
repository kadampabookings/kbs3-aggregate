# Code Review Guidelines

This document outlines critical coding standards and best practices for the KBS3 project. These rules ensure cross-platform compatibility (Web, Desktop, Mobile) and maintainable, consistent code.

## Table of Contents

1. [CSS and Styling Rules](#css-and-styling-rules)
2. [Internationalization (i18n) Rules](#internationalization-i18n-rules)
3. [Helper Classes and Centralized Code](#helper-classes-and-centralized-code)
4. [Code Simplicity and Documentation](#code-simplicity-and-documentation)
5. [Common Violations and Fixes](#common-violations-and-fixes)

---

## CSS and Styling Rules

### Rule 1: No CSS in Java Code

**❌ WRONG** - Inline CSS in Java:
```java
button.setStyle("-fx-background-color: #007bff; -fx-text-fill: white;");
label.setStyle("-fx-font-size: 14px; -fx-font-weight: bold;");
```

**✅ CORRECT** - Use CSS classes and helper methods:
```java
// Use Bootstrap helper
Button button = Bootstrap.primaryButton(new Button());

// Or use CSS class
label.getStyleClass().add(Bootstrap.STRONG);
```

**Why**: Inline styles bypass the CSS system, making it impossible to:
- Apply consistent theming
- Override styles in CSS files
- Maintain a unified design system

### Rule 2: Padding and Sizing MUST Be Set in Java Code

**❌ WRONG** - Padding/sizing in CSS files:
```css
/* In CSS file - DO NOT DO THIS */
.my-button {
    -fx-min-width: 100px;
    -fx-pref-width: 150px;
    -fx-padding: 10 20 10 20;
}
```

**✅ CORRECT** - Padding/sizing in Java code:
```java
// Set sizing in Java
button.setMinWidth(100);
button.setPrefWidth(150);
button.setMaxWidth(200);
button.setPadding(new Insets(10, 20, 10, 20));

// Or use Bootstrap helper (includes padding)
Button button = Bootstrap.button(new Button());  // Applies default padding
```

**Why**: Due to GWT compilation, padding and sizing set in CSS don't work correctly on the web platform. **Always set these in Java code.**

**What goes in CSS**: Only visual styling like colors, fonts, borders, background colors, text styles.

**What goes in Java code**: Padding, margins, sizing (min/max/preferred width/height), spacing, gaps.

### Rule 3: Use Bootstrap and ModalityStyle Helpers

**❌ WRONG** - Manual styling:
```java
Button button = new Button("Save");
button.setPadding(new Insets(6, 12, 6, 12));
button.setMinWidth(240);
button.getStyleClass().addAll("btn", "btn-success");
```

**✅ CORRECT** - Use helper methods:
```java
Button button = Bootstrap.largeSuccessButton(I18nControls.newButton(BaseI18nKeys.Save));
```

**Available Helper Classes**:

1. **Bootstrap.java** (`webfx-extras-fork/webfx-extras-styles-bootstrap/src/main/java/dev/webfx/extras/styles/bootstrap/Bootstrap.java`)
   - Base button styles: `primaryButton()`, `successButton()`, `dangerButton()`, `secondaryButton()`
   - Large buttons: `largePrimaryButton()`, `largeSuccessButton()`, etc.
   - Text styles: `h1()`, `h2()`, `textPrimary()`, `strong()`, `small()`
   - Badges: `successBadge()`, `primaryBadge()`, `dangerBadge()`
   - Alerts: `alertInfo()`, `alertSuccess()`, `alertWarning()`, `alertDanger()`

2. **ModalityStyle.java** (`modality-fork/modality-base/modality-base-client-bootstrap/src/main/java/one/modality/base/client/bootstrap/ModalityStyle.java`)
   - Icon buttons: `primaryButtonWithIcon()`, `successButtonWithIcon()`, `dangerButtonWithIcon()`
   - Specific icon buttons: `primaryEditButton()`, `dangerDeleteButton()`, `successSaveButton()`, `primaryAddButton()`
   - Outline buttons: `outlinePrimaryButton()`, `outlineSuccessButton()`, `outlineDangerButton()`
   - Outline icon buttons: `outlinePrimaryEditButton()`, `outlineDangerDeleteButton()`
   - Large icon buttons: `largePrimaryButtonWithIcon()`, `largeSuccessButtonWithIcon()`
   - Badges: `badgeLightInfo()`, `badgeLightSuccess()`, `badgeGray()`, `badgePurple()`
   - Form helpers: `createFormTextField()`, `createFormTextArea()`, `createFormDatePicker()`
   - Tab helpers: `modernTabPane()`, `wrapTabContent()`

---

## Internationalization (i18n) Rules

### Rule 4: No Hardcoded Text in Java Code

**❌ WRONG** - Hardcoded strings:
```java
Button saveButton = new Button("Save");
Label title = new Label("Event Settings");
textField.setPromptText("Enter your email");
alert.setText("Are you sure you want to delete this item?");
```

**✅ CORRECT** - Use i18n keys:
```java
Button saveButton = I18nControls.newButton(BaseI18nKeys.Save);
Label title = I18nControls.newLabel(MediasI18nKeys.EventSettings);
I18n.bindI18nTextProperty(textField.promptTextProperty(), BaseI18nKeys.EnterEmail);
I18n.bindI18nTextProperty(alert.textProperty(), BaseI18nKeys.ConfirmDelete);
```

**Why**:
- The application supports 7 languages (English, French, German, Spanish, Portuguese, Vietnamese, Chinese)
- Hardcoded text cannot be translated
- All user-facing text must be translatable

### Rule 4.1: Use I18nControls for Automatic Language Binding

**CRITICAL**: When creating UI elements like Labels and Buttons, **ALWAYS use `I18nControls` methods** instead of constructors + `I18n.getI18nText()`.

**❌ WRONG** - No automatic language updates:
```java
// This gets the text ONCE at creation time - won't update if user changes language!
Label welcomeLabel = new Label(I18n.getI18nText(BaseI18nKeys.Welcome));
Button saveButton = new Button(I18n.getI18nText(BaseI18nKeys.Save));

// Later, if user switches from English to French, these controls still show English text!
```

**✅ CORRECT** - Automatic language updates:
```java
// These create BINDINGS that automatically update when language changes
Label welcomeLabel = I18nControls.newLabel(BaseI18nKeys.Welcome);
Button saveButton = I18nControls.newButton(BaseI18nKeys.Save);

// When user switches from English to French, text updates automatically!
```

**How it works**:
- `I18nControls.newLabel(key)` creates a Label with a **binding** to the i18n dictionary
- `I18nControls.newButton(key)` creates a Button with a **binding** to the i18n dictionary
- When the user changes language, all bound controls update automatically
- `I18n.getI18nText(key)` returns a **static string** at that moment - no binding, no updates

**Available I18nControls methods**:
```java
// Creating new controls with automatic binding
Label label = I18nControls.newLabel(key);
Button button = I18nControls.newButton(key);
CheckBox checkbox = I18nControls.newCheckBox(key);
RadioButton radio = I18nControls.newRadioButton(key);
Hyperlink link = I18nControls.newHyperlink(key);
ToggleButton toggle = I18nControls.newToggleButton(key);

// Binding properties on existing controls
I18n.bindI18nTextProperty(label.textProperty(), key);
I18n.bindI18nTextProperty(textField.promptTextProperty(), key);
I18n.bindI18nTextProperty(tab.textProperty(), key);

// Binding multiple properties at once
I18nControls.bindI18nProperties(existingLabel, key);  // Binds text, graphic, textFill
I18nControls.bindI18nProperties(existingTextField, key);  // Binds promptText
```

**When to use each approach**:

| Scenario | Correct Approach | Example |
|----------|------------------|---------|
| Creating a new Label | `I18nControls.newLabel(key)` | `Label title = I18nControls.newLabel(BaseI18nKeys.Title);` |
| Creating a new Button | `I18nControls.newButton(key)` | `Button save = I18nControls.newButton(BaseI18nKeys.Save);` |
| Setting prompt text | `I18n.bindI18nTextProperty()` | `I18n.bindI18nTextProperty(textField.promptTextProperty(), key);` |
| Binding existing control | `I18nControls.bindI18nProperties()` | `I18nControls.bindI18nProperties(existingLabel, key);` |
| Building dynamic strings | `I18n.getI18nText()` + binding | See below |

**Rule 4.2: Use Parameters Instead of Concatenation**

When you need dynamic text with variables (e.g., "Delete role: Admin"), **NEVER concatenate multiple i18n calls**. Use parameter placeholders in `.properties` files instead.

**❌ WRONG** - Concatenating i18n calls:
```java
// BAD: Multiple i18n calls concatenated - breaks in other languages
Label msg = new Label(I18n.getI18nText(Delete) + " " + I18n.getI18nText(Space) +
                      role.getName() + I18n.getI18nText(QuestionMark));

// BAD: Word order differs by language!
String message = I18n.getI18nText(WelcomeText) + " " + userName + "!";
```

**Problems with concatenation**:
1. **No binding** - Text won't update when user changes language
2. **Word order differs by language** - "Delete role Admin?" vs "Supprimer le rôle Admin ?"
3. **Hard for translators** - They see fragments like "Delete", "Space", "?" instead of complete sentences
4. **Punctuation varies** - English uses "?" while Spanish uses "¿?" and French adds spaces

**✅ CORRECT** - Use parameter placeholders in properties files:

```properties
# In your_module_en.properties
ConfirmDeleteRole=Are you sure you want to delete the role "{0}"?
WelcomeMessage=Welcome, {0}!
UserAccessSummary=The selected user will have {0} access for role {1} in {2}.
MustBeInRange=Must be between {0} and {1}
PersonAlreadyBooked={0} is already booked for this event.
```

```properties
# In your_module_fr.properties
ConfirmDeleteRole=Êtes-vous sûr de vouloir supprimer le rôle « {0} » ?
WelcomeMessage=Bienvenue, {0} !
UserAccessSummary=L'utilisateur sélectionné aura un accès {0} pour le rôle {1} dans {2}.
MustBeInRange=Doit être entre {0} et {1}
PersonAlreadyBooked={0} est déjà inscrit(e) pour cet événement.
```

```java
// GOOD: Single i18n call with parameters and binding
Label msg = new Label();
msg.textProperty().bind(I18n.i18nTextProperty(ConfirmDeleteRole, role.getName()));

// GOOD: Multiple parameters in correct order for each language
errorMessageProperty.bind(I18n.i18nTextProperty(MustBeInRange, minValue, maxValue));

Label summary = new Label();
summary.textProperty().bind(I18n.i18nTextProperty(UserAccessSummary,
    accessLevel, roleName, organizationName));
```

**Parameter syntax in .properties files**:
- `{0}` - First parameter
- `{1}` - Second parameter
- `{2}` - Third parameter
- And so on...

**Why this matters**: Different languages have different word orders, punctuation, and grammar. Parameters allow translators to arrange words naturally for their language while keeping the logic in one place.

**Rule 4.3: YAML vs Properties - When to Use Each**

**YAML files** (`.yaml`) - For **language-independent resources** (same for all languages):
- SVG paths and graphics
- Image file paths (`"images/s16/actions/delete.png"`)
- Icon references
- Technical identifiers
- Structured metadata

**Properties files** (`.properties`) - For **text that needs translation** (varies by language):
- Button labels
- Dialog messages
- Error messages
- User-facing text
- Dynamic text with parameters

```yaml
# ❌ WRONG - Translatable text in YAML
# modality-backoffice-operations@en.yaml
DeleteConfirmation: "Are you sure you want to delete this item?"
WelcomeMessage: "Welcome to the application"

# ✅ CORRECT - Only language-independent resources in YAML
# modality-backoffice-operations@en.yaml
DeleteButton:
  graphic: "images/s16/actions/delete.png"
EditButton:
  graphic: "images/s16/actions/edit.png"
```

```properties
# ✅ CORRECT - Translatable text in properties files
# modality-backoffice-operations_en.properties
DeleteConfirmation=Are you sure you want to delete this item?
WelcomeMessage=Welcome to the application

# modality-backoffice-operations_fr.properties
DeleteConfirmation=Êtes-vous sûr de vouloir supprimer cet élément ?
WelcomeMessage=Bienvenue dans l'application
```

**Key principle**: If it varies by language, use `.properties`. If it's the same for all languages, use `.yaml`.

### How to Add New Translations

1. **Add key to properties file** for each language:

   `src/main/webfx/i18n/your-module_en.properties`:
   ```properties
   EventSettings=Event Settings
   EnterEmail=Enter your email
   ConfirmDelete=Are you sure you want to delete this item?
   ```

   `src/main/webfx/i18n/your-module_fr.properties`:
   ```properties
   EventSettings=Paramètres de l'événement
   EnterEmail=Entrez votre email
   ConfirmDelete=Êtes-vous sûr de vouloir supprimer cet élément?
   ```

2. **Define key constant** in i18n keys interface:
   ```java
   public interface YourModuleI18nKeys {
       String EventSettings = "EventSettings";
       String EnterEmail = "EnterEmail";
       String ConfirmDelete = "ConfirmDelete";
   }
   ```

3. **Use in code**:
   ```java
   Label title = I18nControls.newLabel(YourModuleI18nKeys.EventSettings);
   ```

### I18n Helper Methods - Quick Reference

**Preferred - Creates controls with automatic binding**:
- `I18nControls.newLabel(key)` - Create Label with automatic language updates
- `I18nControls.newButton(key)` - Create Button with automatic language updates
- `I18nControls.newCheckBox(key)` - Create CheckBox with automatic language updates
- `I18nControls.newRadioButton(key)` - Create RadioButton with automatic language updates
- `I18nControls.newHyperlink(key)` - Create Hyperlink with automatic language updates
- `I18nControls.newToggleButton(key)` - Create ToggleButton with automatic language updates

**For binding properties on existing controls**:
- `I18n.bindI18nTextProperty(property, key)` - Bind a text property (e.g., promptText)
- `I18nControls.bindI18nProperties(control, key)` - Bind all i18n properties on existing control
- `I18n.i18nTextProperty(key, args)` - Get observable property for custom bindings

**Avoid - No automatic updates**:
- ❌ `I18n.getI18nText(key)` - Returns static string, **no binding**, won't update on language change

---

## Helper Classes and Centralized Code

### Rule 5: Use Existing Helpers Before Creating Custom Code

**❌ WRONG** - Reinventing the wheel:
```java
// Creating custom button styling
Button button = new Button();
button.setPadding(new Insets(10, 16, 10, 16));
button.setMinWidth(240);
button.setGraphicTextGap(30);
button.getStyleClass().addAll("btn", "btn-primary", "lg");

// Creating custom icon
SVGPath icon = new SVGPath();
icon.setContent("M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z");
icon.setScaleX(0.8);
icon.setScaleY(0.8);
button.setGraphic(icon);
```

**✅ CORRECT** - Use existing helpers:
```java
// Use ModalityStyle helper for large primary edit button
Button button = ModalityStyle.largePrimaryEditButton(I18nControls.newButton(BaseI18nKeys.Edit));
```

### Available Helper Patterns

#### Button Creation

```java
// Basic buttons
Button primary = Bootstrap.primaryButton(I18nControls.newButton(key));
Button success = Bootstrap.successButton(I18nControls.newButton(key));
Button danger = Bootstrap.dangerButton(I18nControls.newButton(key));
Button secondary = Bootstrap.secondaryButton(I18nControls.newButton(key));

// Large buttons
Button largePrimary = Bootstrap.largePrimaryButton(I18nControls.newButton(key));
Button largeSuccess = Bootstrap.largeSuccessButton(I18nControls.newButton(key));

// Icon buttons
Button editButton = ModalityStyle.primaryEditButton(I18nControls.newButton(key));
Button deleteButton = ModalityStyle.dangerDeleteButton(I18nControls.newButton(key));
Button saveButton = ModalityStyle.successSaveButton(I18nControls.newButton(key));
Button addButton = ModalityStyle.primaryAddButton(I18nControls.newButton(key));

// Outline buttons
Button outlineEdit = ModalityStyle.outlinePrimaryEditButton(I18nControls.newButton(key));
Button outlineDelete = ModalityStyle.outlineDangerDeleteButton(I18nControls.newButton(key));

// Large icon buttons
Button largeEdit = ModalityStyle.largePrimaryEditButton(I18nControls.newButton(key));
Button largeDelete = ModalityStyle.largeDangerDeleteButton(I18nControls.newButton(key));
```

#### Form Field Creation

```java
// Text field with label and help text
TextField emailField = new TextField();
VBox emailContainer = ModalityStyle.createFormTextField(
    I18nControls.newLabel(YourModuleI18nKeys.Email),
    emailField,
    I18n.getI18nText(YourModuleI18nKeys.EnterEmail),  // placeholder
    I18n.getI18nText(YourModuleI18nKeys.EmailHelp)    // help text
);

// Text field with copy button (for read-only fields)
TextField apiKeyField = new TextField();
apiKeyField.setEditable(false);
VBox apiKeyContainer = ModalityStyle.createFormTextField(
    I18nControls.newLabel(YourModuleI18nKeys.ApiKey),
    apiKeyField,
    true  // enable copy button
);

// Text area
TextArea descriptionArea = new TextArea();
VBox descriptionContainer = ModalityStyle.createFormTextArea(
    I18nControls.newLabel(YourModuleI18nKeys.Description),
    descriptionArea,
    I18n.getI18nText(YourModuleI18nKeys.EnterDescription),
    I18n.getI18nText(YourModuleI18nKeys.DescriptionHelp)
);

// Date picker
DatePicker datePicker = new DatePicker();
VBox dateContainer = ModalityStyle.createFormDatePicker(
    I18nControls.newLabel(YourModuleI18nKeys.StartDate),
    datePicker
);
```

#### Text Styling

```java
// Headings
Label h1 = Bootstrap.h1(I18nControls.newLabel(key));
Label h2 = Bootstrap.h2(I18nControls.newLabel(key));

// Text colors
Label primary = Bootstrap.textPrimary(I18nControls.newLabel(key));
Label secondary = Bootstrap.textSecondary(I18nControls.newLabel(key));
Label success = Bootstrap.textSuccess(I18nControls.newLabel(key));
Label warning = Bootstrap.textWarning(I18nControls.newLabel(key));
Label danger = Bootstrap.textDanger(I18nControls.newLabel(key));

// Text styles
Label strong = Bootstrap.strong(I18nControls.newLabel(key));
Label small = Bootstrap.small(I18nControls.newLabel(key));
```

#### Badges

```java
// Bootstrap badges
Label success = Bootstrap.successBadge(I18nControls.newLabel(key));
Label danger = Bootstrap.dangerBadge(I18nControls.newLabel(key));

// Modality custom badges
Label lightInfo = ModalityStyle.badgeLightInfo(I18nControls.newLabel(key));
Label lightSuccess = ModalityStyle.badgeLightSuccess(I18nControls.newLabel(key));
Label gray = ModalityStyle.badgeGray(I18nControls.newLabel(key));
Label purple = ModalityStyle.badgePurple(I18nControls.newLabel(key));
```

#### Tabs

```java
TabPane tabPane = new TabPane();
ModalityStyle.modernTabPane(tabPane);  // Apply modern styling

Tab tab1 = new Tab();
tab1.setText(I18n.getI18nText(YourModuleI18nKeys.Tab1));
tab1.setContent(ModalityStyle.wrapTabContent(content));  // Add padding
```

### Rule 6: Create Reusable Helpers for Common Patterns

If you find yourself writing the same code multiple times, create a helper method.

**❌ WRONG** - Duplicated code:
```java
// In file 1
Button button1 = new Button();
SVGPath icon1 = SvgIcons.createCustomIcon();
ModalityStyle.setIcon(button1, icon1);
Bootstrap.primaryButton(button1);

// In file 2 - same pattern repeated
Button button2 = new Button();
SVGPath icon2 = SvgIcons.createCustomIcon();
ModalityStyle.setIcon(button2, icon2);
Bootstrap.primaryButton(button2);
```

**✅ CORRECT** - Create helper in ModalityStyle:
```java
// Add to ModalityStyle.java
static Button primaryCustomIconButton(Button button) {
    return primaryButtonWithIcon(button, SvgIcons.createCustomIcon());
}

// Use in code
Button button1 = ModalityStyle.primaryCustomIconButton(I18nControls.newButton(key));
Button button2 = ModalityStyle.primaryCustomIconButton(I18nControls.newButton(key));
```

---

## Code Simplicity and Documentation

### Rule 7: Keep Code Simple and Readable

**❌ WRONG** - Complex, nested, unclear code:
```java
private void processData() {
    entityStore.executeQuery("select * from Event").onSuccess(events -> {
        for (Entity entity : events) {
            if (((Event)entity).getStartDate() != null) {
                if (((Event)entity).getStartDate().isAfter(LocalDate.now())) {
                    if (((Event)entity).isAdvertised()) {
                        // nested logic continues...
                    }
                }
            }
        }
    });
}
```

**✅ CORRECT** - Simple, clear, early returns:
```java
/**
 * Processes upcoming advertised events
 */
private void processUpcomingAdvertisedEvents() {
    entityStore.executeQuery("select startDate, advertised from Event where startDate > ?", LocalDate.now())
        .onSuccess(this::handleUpcomingEvents);
}

private void handleUpcomingEvents(EntityList<Event> events) {
    for (Event event : events) {
        if (event.isAdvertised()) {
            processEvent(event);
        }
    }
}

private void processEvent(Event event) {
    // Clear, focused logic
}
```

**Principles**:
1. **Extract methods** - One method does one thing
2. **Early returns** - Avoid deep nesting
3. **Descriptive names** - Methods and variables should explain themselves
4. **Query smarter** - Filter in DSQL query when possible
5. **Use type-safe casts** - `EntityList<Event>` instead of `EntityList`

### Rule 8: Document Complex Logic

**❌ WRONG** - No documentation:
```java
private void updateVodExpirationDate(Event currentEvent, DateTimeFormatter dateFormatter, DateTimeFormatter timeFormatter) {
    try {
        LocalDate date = LocalDate.parse(contentExpirationDateTextField.getText(), dateFormatter);
        LocalTime time = LocalTime.parse(contentExpirationTimeTextField.getText(), timeFormatter);
        currentEvent.setVodExpirationDate(LocalDateTime.of(date, time));
    } catch (DateTimeParseException e) {
        if (Objects.equals(contentExpirationDateTextField.getText(), "") && Objects.equals(contentExpirationTimeTextField.getText(), ""))
            currentEvent.setVodExpirationDate(null);
    }
}
```

**✅ CORRECT** - Clear documentation:
```java
/**
 * Updates the VOD expiration date/time for an event by parsing user input.
 *
 * Combines separate date and time text fields into a single LocalDateTime.
 * If both fields are empty, sets the expiration date to null (no expiration).
 *
 * @param currentEvent The event to update
 * @param dateFormatter Formatter for parsing date field (e.g., "25/09/2025")
 * @param timeFormatter Formatter for parsing time field (e.g., "14:30")
 */
private void updateVodExpirationDate(Event currentEvent, DateTimeFormatter dateFormatter, DateTimeFormatter timeFormatter) {
    try {
        LocalDate date = LocalDate.parse(contentExpirationDateTextField.getText(), dateFormatter);
        LocalTime time = LocalTime.parse(contentExpirationTimeTextField.getText(), timeFormatter);

        // Combine date and time into single datetime
        currentEvent.setVodExpirationDate(LocalDateTime.of(date, time));
    } catch (DateTimeParseException e) {
        // If both fields are empty, clear expiration (no limit)
        if (isEmptyField(contentExpirationDateTextField) && isEmptyField(contentExpirationTimeTextField)) {
            currentEvent.setVodExpirationDate(null);
        }
        // Otherwise, invalid format - keep existing value
    }
}

private boolean isEmptyField(TextField field) {
    return field.getText() == null || field.getText().trim().isEmpty();
}
```

**When to document**:
- Complex business logic
- Non-obvious algorithms
- Workarounds for platform limitations
- Public API methods
- Any code that made you think "why does this work this way?"

**Good JavaDoc elements**:
- **Brief summary** - What does this do?
- **@param** - What do parameters mean?
- **@return** - What does it return?
- **Edge cases** - What happens with null/empty/special values?
- **Side effects** - Does it modify state?

---

## Common Violations and Fixes

### Violation 1: Direct CSS Styling

```java
// ❌ WRONG
button.setStyle("-fx-background-color: blue;");

// ✅ CORRECT
button = Bootstrap.primaryButton(button);
```

### Violation 2: Padding in CSS

```css
/* ❌ WRONG - in CSS file */
.my-container {
    -fx-padding: 20px;
}
```

```java
// ✅ CORRECT - in Java
container.setPadding(new Insets(20));
```

### Violation 3: Hardcoded Text

```java
// ❌ WRONG
new Label("Save Changes");

// ✅ CORRECT
I18nControls.newLabel(BaseI18nKeys.SaveChanges);
```

### Violation 3.1: Using I18n.getI18nText() for Controls

```java
// ❌ WRONG - No automatic language updates
Label label = new Label(I18n.getI18nText(BaseI18nKeys.Welcome));
Button button = new Button(I18n.getI18nText(BaseI18nKeys.Save));

// ✅ CORRECT - Automatic language updates via binding
Label label = I18nControls.newLabel(BaseI18nKeys.Welcome);
Button button = I18nControls.newButton(BaseI18nKeys.Save);
```

### Violation 3.2: Concatenating I18n Calls

```java
// ❌ WRONG - Concatenating multiple i18n calls
Label msg = new Label(I18n.getI18nText(Delete) + " " + role.getName() + I18n.getI18nText(QuestionMark));
String welcome = I18n.getI18nText(Welcome) + " " + userName + "!";

// ✅ CORRECT - Use parameters in properties file
// In properties: ConfirmDeleteRole=Are you sure you want to delete the role "{0}"?
Label msg = new Label();
msg.textProperty().bind(I18n.i18nTextProperty(ConfirmDeleteRole, role.getName()));
```

### Violation 3.3: Translatable Text in YAML Files

```yaml
# ❌ WRONG - Text that needs translation in YAML
DeleteConfirmation: "Are you sure you want to delete this item?"
WelcomeMessage: "Welcome to the application"
```

```properties
# ✅ CORRECT - Translatable text in properties
# your-module_en.properties
DeleteConfirmation=Are you sure you want to delete this item?
WelcomeMessage=Welcome to the application

# your-module_fr.properties
DeleteConfirmation=Êtes-vous sûr de vouloir supprimer cet élément ?
WelcomeMessage=Bienvenue dans l'application
```

### Violation 4: Not Using Helpers

```java
// ❌ WRONG
Button btn = new Button();
btn.setPadding(new Insets(6, 12, 6, 12));
btn.getStyleClass().addAll("btn", "btn-primary");

// ✅ CORRECT
Button btn = Bootstrap.primaryButton(new Button());
```

### Violation 5: Complex Nested Code

```java
// ❌ WRONG
if (x != null) {
    if (y != null) {
        if (z != null) {
            // deep nesting
        }
    }
}

// ✅ CORRECT
if (x == null || y == null || z == null) return;
// flat code
```

### Violation 6: Missing Documentation

```java
// ❌ WRONG
private void process(Event e, boolean f) {
    // complex logic with no explanation
}

// ✅ CORRECT
/**
 * Processes event validation before submission.
 *
 * @param event The event to validate
 * @param forceSave If true, bypasses certain validation checks
 */
private void processEventValidation(Event event, boolean forceSave) {
    // complex logic with clear purpose
}
```

## Code Review Checklist

When reviewing code, check for:

- [ ] **No inline CSS** (`setStyle()` calls)
- [ ] **Padding/sizing in Java**, not CSS
- [ ] **No hardcoded text** - all use i18n keys
- [ ] **I18nControls for UI creation** - use `I18nControls.newLabel()`, `I18nControls.newButton()`, etc. (not `new Label(I18n.getI18nText())`)
- [ ] **I18n bindings** - use `I18n.bindI18nTextProperty()` for properties like promptText
- [ ] **No i18n concatenation** - use parameters (`{0}`, `{1}`) instead of concatenating multiple i18n calls
- [ ] **YAML for language-independent** - icons, SVG, image paths in YAML
- [ ] **Properties for translations** - all translatable text in .properties files (not YAML)
- [ ] **Helper methods used** (Bootstrap, ModalityStyle)
- [ ] **Clear method names** - no generic names like `process()`, `handle()`, `doIt()`
- [ ] **Documentation** - complex logic is explained
- [ ] **Simple structure** - avoid deep nesting
- [ ] **Proper i18n** - all user-facing text is translatable with automatic language updates
- [ ] **Type safety** - use `EntityList<Event>` not raw `EntityList`
- [ ] **No code duplication** - extract common patterns to helpers
- [ ] **WebFX update** ran after modifying CSS/properties/YAML files

## Quick Reference

| What | Where | Example |
|------|-------|---------|
| Button styling | Bootstrap | `Bootstrap.primaryButton()` |
| Icon buttons | ModalityStyle | `ModalityStyle.primaryEditButton()` |
| Form fields | ModalityStyle | `ModalityStyle.createFormTextField()` |
| Labels (i18n) | I18nControls | `I18nControls.newLabel(key)` |
| Buttons (i18n) | I18nControls | `I18nControls.newButton(key)` |
| Property binding | I18n | `I18n.bindI18nTextProperty(property, key)` |
| Translations | properties files | `module_en.properties` |
| Padding | Java code | `node.setPadding(new Insets(20))` |
| Colors | CSS files | `.my-class { -fx-text-fill: blue; }` |

---

[← Back to Main Documentation](../../CLAUDE.md)
