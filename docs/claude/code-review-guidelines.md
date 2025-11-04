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
textField.setPromptText(I18n.getI18nText(BaseI18nKeys.EnterEmail));
alert.setText(I18n.getI18nText(BaseI18nKeys.ConfirmDelete));
```

**Why**:
- The application supports 7 languages (English, French, German, Spanish, Portuguese, Vietnamese, Chinese)
- Hardcoded text cannot be translated
- All user-facing text must be translatable

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

### I18n Helper Methods

- `I18nControls.newLabel(key)` - Create label with i18n text
- `I18nControls.newButton(key)` - Create button with i18n text
- `I18n.getI18nText(key)` - Get translated string
- `I18n.i18nTextProperty(key)` - Get observable i18n property for bindings

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
- [ ] **Helper methods used** (Bootstrap, ModalityStyle)
- [ ] **Clear method names** - no generic names like `process()`, `handle()`, `doIt()`
- [ ] **Documentation** - complex logic is explained
- [ ] **Simple structure** - avoid deep nesting
- [ ] **Proper i18n** - all user-facing text is translatable
- [ ] **Type safety** - use `EntityList<Event>` not raw `EntityList`
- [ ] **No code duplication** - extract common patterns to helpers
- [ ] **WebFX update** ran after modifying CSS/properties/YAML files

## Quick Reference

| What | Where | Example |
|------|-------|---------|
| Button styling | Bootstrap | `Bootstrap.primaryButton()` |
| Icon buttons | ModalityStyle | `ModalityStyle.primaryEditButton()` |
| Form fields | ModalityStyle | `ModalityStyle.createFormTextField()` |
| Labels | I18nControls | `I18nControls.newLabel(key)` |
| Translations | properties files | `module_en.properties` |
| Padding | Java code | `node.setPadding(new Insets(20))` |
| Colors | CSS files | `.my-class { -fx-text-fill: blue; }` |

---

[← Back to Main Documentation](../../CLAUDE.md)
