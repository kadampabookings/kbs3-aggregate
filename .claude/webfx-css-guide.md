# WebFX CSS Transformation Guide

## Overview

This document explains how WebFX transforms JavaFX CSS properties to web CSS during GWT compilation, including DOM generation and the critical differences developers must understand.

## 1. Architecture: JavaFX to DOM Transformation

### The Peer Pattern

WebFX uses a **Peer Pattern** where each JavaFX Node gets a corresponding "Peer" class:

```
JavaFX Node (Button, Label, etc.)
       ↓
   Node Peer (HtmlButtonPeer, HtmlLabelPeer, etc.)
       ↓
   DOM Element (<fx-button>, <fx-label>, etc.)
```

### DOM Structure Generated (Single-Host Strategy)

WebFX generates **custom HTML elements** with a simplified single-host structure. Each Region element uses:
- The element itself for background and border (via CSS variables and `::before` pseudo-element)
- Direct children (no `<fx-children>` wrapper)
- `<fx-text>` elements for text content

```html
<fx-region class="my-class" fx-border-overlay>
  <fx-label class="label" fx-border-overlay>
    <fx-text class="text">Content</fx-text>
  </fx-label>
</fx-region>
```

**Key attributes:**
- `fx-border-overlay` - Marks elements for CSS variable-based background/border rendering
- Background is applied directly to the element via `--fx-background-color` CSS variable
- Border is rendered via `::before` pseudo-element using `--fx-border-*` CSS variables

### CSS Variables for Styling

WebFX uses CSS custom properties (variables) for styling. These are defined in `:root` and consumed by elements with the `fx-border-overlay` attribute:

```css
:root {
    --fx-background-color: transparent;
    --fx-background-radius: var(--fx-border-radius);
    --fx-border-style: none;
    --fx-border-color: transparent;
    --fx-border-width: 0;
    --fx-border-radius: 0;
    --fx-text-fill: black;
}
```

### Control to DOM Element Mapping

| JavaFX Control | DOM Element |
|---------------|-------------|
| Button | `<fx-button>` |
| Label | `<fx-label>` |
| TextField | `<fx-textfield>` (contains `<input>`) |
| TextArea | `<textarea>` |
| CheckBox | `<fx-checkbox>` |
| RadioButton | `<fx-radiobutton>` |
| ChoiceBox | `<fx-choicebox>` |
| ScrollPane | `<fx-scrollpane>` |
| Region/Pane | `<fx-region>` |
| StackPane | `<fx-stackpane>` |
| VBox | `<fx-vbox>` |
| HBox | `<fx-hbox>` |

## 2. Critical Limitation: `setStyle()` is NOT Parsed

**This is the most important thing to understand:**

```java
// THIS DOES NOT WORK IN WEBFX!
node.setStyle("-fx-background-color: red; -fx-border-color: blue;");
```

WebFX's `updateStyle()` method in `HtmlSvgNodePeer.java` is **intentionally empty** (line 597-599). Inline style strings are NOT parsed or transformed.

### What Works Instead

Use JavaFX property objects:

```java
// THIS WORKS - Using Background property
Region r = new Region();
BackgroundFill fill = new BackgroundFill(Color.RED, new CornerRadii(8), null);
r.setBackground(new Background(fill));

// THIS WORKS - Using Border property
BorderStroke stroke = new BorderStroke(Color.BLUE, BorderStrokeStyle.SOLID,
    new CornerRadii(8), new BorderWidths(1));
r.setBorder(new Border(stroke));
```

Or use CSS classes with proper web CSS files:

```java
// THIS WORKS - Using CSS classes
node.getStyleClass().add("my-styled-element");
```

## 3. CSS Property Conversion Reference

### JavaFX CSS → Web CSS Property Mapping

| JavaFX CSS Property | Web CSS Variable | Alternative Direct CSS | Notes |
|--------------------|------------------|----------------------|-------|
| `-fx-background-color` | `--fx-background-color` | `background-color` | Applied to element directly |
| `-fx-background-radius` | `--fx-background-radius` | `border-radius` | Applied to element directly |
| `-fx-border-color` | `--fx-border-color` | N/A | Border rendered via `::before` |
| `-fx-border-width` | `--fx-border-width` | N/A | Border rendered via `::before` |
| `-fx-border-style` | `--fx-border-style` | N/A | Border rendered via `::before` |
| `-fx-border-radius` | `--fx-border-radius` | N/A | Border rendered via `::before` |
| `-fx-text-fill` | `--fx-text-fill` | `color` on `fx-text` | Apply to `fx-text` element |
| `-fx-font-size` | N/A | `font-size` | Standard CSS |
| `-fx-font-family` | N/A | `font-family` | Standard CSS |
| `-fx-font-weight` | N/A | `font-weight` | Standard CSS |
| `-fx-opacity` | N/A | `opacity` | Standard CSS |
| `-fx-cursor` | N/A | `cursor` | Standard CSS |
| `-fx-padding` | `--fx-padding` | N/A | **Prefer setting in Java code!** |

### Paint/Color Conversion (HtmlPaints.java)

```
JavaFX Color → #RRGGBB or rgba(R,G,B,A)
JavaFX LinearGradient → linear-gradient(Ndeg, color1 X%, color2 Y%)
JavaFX RadialGradient → radial-gradient(circle at X% Y%, color1 X%, color2 Y%)
```

### Transform Conversion (HtmlTransforms.java)

```
Translate → translate(Xpx, Ypx)
Rotate → rotate(Ndeg) or rotateX/rotateY(Ndeg)
Scale → scale(X, Y)
Affine → matrix(mxx, myx, mxy, myy, tx, ty)
```

## 4. Web CSS Styling Pattern

With the new single-host DOM structure, styling is simplified. You can use either **CSS variables** or **direct CSS properties** for backgrounds. Text styling still requires targeting the `fx-text` element.

### Example: Styled Button

**JavaFX CSS (`*-javafx@main.css`):**
```css
.my-button {
    -fx-background-color: #0096D6;
    -fx-text-fill: white;
    -fx-border-color: #007ACC;
    -fx-border-radius: 8px;
    -fx-background-radius: 8px;
}
```

**Web CSS (`*-web@main.css`) - Using CSS Variables (Recommended):**
```css
.my-button {
    --fx-background-color: #0096D6;
    --fx-background-radius: 8px;
    --fx-border-color: #007ACC;
    --fx-border-width: 1px;
    --fx-border-style: solid;
    --fx-border-radius: 8px;
}

/* Text content - fx-text elements still exist */
.my-button fx-text {
    color: white;
}
```

**Web CSS (`*-web@main.css`) - Using Direct CSS (Alternative):**
```css
.my-button {
    background-color: #0096D6;
    border-radius: 8px;
}

/* Text content */
.my-button fx-text {
    color: white;
}
```

**Note:** For borders, CSS variables are required since borders are rendered via `::before` pseudo-element.

## 5. Critical Rules

### Rule 1: Padding and Sizing SHOULD Be Set in Java

```java
// RECOMMENDED - Set in Java code for best cross-platform consistency
container.setPadding(new Insets(16));
container.setSpacing(12);
button.setPrefWidth(200);

// ALTERNATIVE - CSS padding variables (works but Java is preferred)
// .my-container { --fx-padding: 16px; }
```

### Rule 2: Use CSS Variables for Borders

Since borders are rendered via `::before` pseudo-element, you must use CSS variables:

```css
/* CORRECT - Using CSS variables */
.my-element {
    --fx-border-color: #ddd;
    --fx-border-width: 1px;
    --fx-border-style: solid;
    --fx-border-radius: 4px;
}

/* WRONG - Direct border properties won't work */
.my-element {
    border-color: #ddd;  /* This won't create a visible border */
    border-width: 1px;
}
```

### Rule 3: Multi-side Border Syntax

CSS variables support the standard CSS shorthand for multi-side values:

```css
/* Order: top, right, bottom, left */
.my-element {
    --fx-border-color: transparent transparent transparent #ffc107;
    --fx-border-width: 0 0 0 4px;
    --fx-border-style: solid;
}
```

### Rule 4: Variable Cascade Prevention (Automatic)

WebFX automatically resets CSS variables on nested elements to prevent parent styles from leaking into children. This is handled by built-in CSS rules:

```css
/* Built-in: automatically resets variables on nested Region hosts */
:where([fx-border-overlay]) :where([fx-border-overlay]) {
    --fx-background-color: transparent;
    --fx-border-style: none;
    /* etc. */
}
```

You don't need to worry about style cascade like in the old DOM structure.

## 6. CSS File Organization

### Location
```
src/main/webfx/css/
├── module-name-javafx@main.css    (JavaFX desktop)
└── module-name-web@main.css       (GWT/Web)
```

### Naming Convention
- Use module prefix for all classes: `modulename-classname`
- Examples: `kitchen-cell`, `roomsetup-dialog`, `booking-card`

## 7. Hover States

Hover states can be styled directly on the element or using CSS variables:

```css
/* Using CSS variables */
.my-button:hover {
    --fx-background-color: #007ACC;
}

/* Or using direct CSS (for backgrounds) */
.my-button:hover {
    background-color: #007ACC;
}
```

## 8. Text Styling

Text content is rendered in `<fx-text>` elements. You can target these elements directly or use the `--fx-text-fill` CSS variable:

```css
/* Using CSS variable for text color */
.my-label {
    --fx-text-fill: #333;
    font-size: 14px;
    font-weight: bold;
}

/* Or targeting fx-text element directly */
.my-label fx-text {
    color: #333;
    font-size: 14px;
    font-weight: bold;
}
```

**Note:** Font properties (`font-size`, `font-family`, `font-weight`) can be set directly on the element and will cascade to `fx-text`.

## 9. Common Pitfalls

### Pitfall 1: Using setStyle() for -fx- properties
**Problem:** `node.setStyle("-fx-background-color: red")` doesn't work
**Solution:** Use `Background`/`Border` objects or CSS classes

### Pitfall 2: Using Direct Border Properties Instead of Variables
**Problem:** `border-color: #ddd` doesn't create a visible border
**Solution:** Use CSS variables: `--fx-border-color: #ddd; --fx-border-style: solid; --fx-border-width: 1px;`

### Pitfall 3: Missing --fx-border-style
**Problem:** Border doesn't appear even with `--fx-border-color` and `--fx-border-width` set
**Solution:** Always include `--fx-border-style: solid` (or `dashed`, `dotted`)

### Pitfall 4: Padding in CSS
**Problem:** Standard `padding: 16px` may not work consistently
**Solution:** Prefer `node.setPadding(new Insets(16))` in Java, or use `--fx-padding: 16px`

### Pitfall 5: Using -fx- Properties in Web CSS
**Problem:** `-fx-background-color: #007ACC;` in web CSS files has no effect
**Solution:** Use standard CSS (`background-color`) or CSS variables (`--fx-background-color`)

## 10. Key Source Files

| File | Purpose |
|------|---------|
| `HtmlPaints.java` | Color/gradient to CSS conversion |
| `HtmlTransforms.java` | Transform to CSS conversion |
| `HtmlRegionPeer.java` | Background/border DOM generation |
| `HtmlSvgNodePeer.java` | Base peer, style class handling |
| `HtmlUtil.java` | Low-level DOM/style utilities |
| `HtmlScenePeer.java` | Scene graph to DOM synchronization |

## 11. SVG Styling

WebFX supports SVG elements for shapes and graphics. SVG uses a different styling approach than HTML elements.

### SVG Element Generation

SVG elements are created using the `SvgUtil` class with native SVG elements:

| JavaFX Shape | SVG Element |
|-------------|-------------|
| Rectangle | `<rect>` |
| Circle | `<circle>` |
| Line | `<line>` |
| Path | `<path>` |
| Text (in SVG) | `<text>` |
| Group | `<g>` |

### SVG Fill and Stroke

SVG shapes use `fill` and `stroke` attributes instead of CSS background/border:

**JavaFX Code:**
```java
Rectangle rect = new Rectangle(100, 50);
rect.setFill(Color.RED);
rect.setStroke(Color.BLUE);
rect.setStrokeWidth(2);
```

**Generated SVG:**
```html
<rect width="100" height="50" fill="#FF0000" stroke="#0000FF" stroke-width="2"/>
```

### SVG CSS Styling

For SVG elements in web CSS:

```css
/* SVG shapes use fill/stroke, NOT background-color/border */
.my-svg-shape {
    fill: #0096D6;
    stroke: #007ACC;
    stroke-width: 2px;
}

/* Stroke properties */
.my-line {
    stroke: #333;
    stroke-width: 1px;
    stroke-linecap: round;      /* butt, round, square */
    stroke-linejoin: round;     /* miter, round, bevel */
    stroke-dasharray: 5, 3;     /* dash pattern */
    stroke-dashoffset: 0;
}
```

### SVG Gradients

Gradients in SVG require `<defs>` definitions:

**JavaFX:**
```java
LinearGradient gradient = new LinearGradient(0, 0, 1, 0, true, CycleMethod.NO_CYCLE,
    new Stop(0, Color.RED), new Stop(1, Color.BLUE));
rect.setFill(gradient);
```

**Generated SVG:**
```html
<defs>
    <linearGradient id="G1" x1="0%" y1="0%" x2="100%" y2="0%">
        <stop offset="0%" stop-color="#FF0000"/>
        <stop offset="100%" stop-color="#0000FF"/>
    </linearGradient>
</defs>
<rect fill="url(#G1)" .../>
```

### SVG vs HTML Styling Comparison

| Property | HTML Element | SVG Element |
|----------|-------------|-------------|
| Background | `background-color` | `fill` |
| Border color | `border-color` | `stroke` |
| Border width | `border-width` | `stroke-width` |
| Transparency | `opacity` | `opacity` or `fill-opacity` |
| No fill | N/A | `fill: none` |

## 12. Effect Mapping (Shadows, Blur)

WebFX converts JavaFX effects to CSS filters and box-shadows.

### Supported Effects

| JavaFX Effect | CSS Equivalent | Notes |
|--------------|----------------|-------|
| DropShadow | `box-shadow` + `filter: drop-shadow()` | Full support |
| InnerShadow | `box-shadow: inset` | Full support |
| GaussianBlur | `filter: blur()` | Full support |
| BoxBlur | `filter: blur()` | Converted to Gaussian |
| Reflection | Not supported | Defined but not implemented |

### DropShadow

**JavaFX:**
```java
DropShadow shadow = new DropShadow();
shadow.setRadius(10);
shadow.setOffsetX(5);
shadow.setOffsetY(5);
shadow.setColor(Color.rgb(0, 0, 0, 0.5));
node.setEffect(shadow);
```

**Generated CSS (HTML elements):**
```css
box-shadow: 5px 5px 10px rgba(0, 0, 0, 0.5);
```

**Generated SVG filter (SVG elements):**
```html
<filter id="F1" width="200%" height="200%">
    <feDropShadow dx="5" dy="5" stdDeviation="5" flood-color="rgba(0,0,0,0.5)"/>
</filter>
```

### InnerShadow

**JavaFX:**
```java
InnerShadow innerShadow = new InnerShadow();
innerShadow.setRadius(5);
innerShadow.setOffsetX(2);
innerShadow.setOffsetY(2);
innerShadow.setColor(Color.GRAY);
node.setEffect(innerShadow);
```

**Generated CSS:**
```css
box-shadow: inset 2px 2px 5px #808080;
```

### GaussianBlur

**JavaFX:**
```java
GaussianBlur blur = new GaussianBlur(10);
node.setEffect(blur);
```

**Generated CSS:**
```css
filter: blur(10px);
```

### Web CSS for Effects

When styling elements with effects in web CSS:

```css
/* Drop shadow */
.my-card {
    box-shadow: 2px 4px 8px rgba(0, 0, 0, 0.15);
}

/* Inner shadow (inset) */
.my-inset-panel {
    box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Blur effect */
.my-blurred {
    filter: blur(5px);
}

/* Multiple shadows */
.my-layered-shadow {
    box-shadow:
        0 1px 3px rgba(0,0,0,0.12),
        0 1px 2px rgba(0,0,0,0.24);
}
```

### Effect Limitations

1. **Reflection effect** is not supported in WebFX
2. **Effect chaining** works but may have performance implications
3. **BoxBlur** is approximated using Gaussian blur formula
4. **SVG filters** use 200% viewBox to prevent clipping

### Performance Considerations

- CSS `box-shadow` is more performant than SVG filters
- Avoid blur on frequently animated elements
- Large shadow radii impact rendering performance
- Consider using CSS classes instead of inline effects for static shadows

## 13. Conversion Checklist

When creating web CSS from JavaFX CSS:

- [ ] Replace `-fx-background-color` with `--fx-background-color` or `background-color`
- [ ] Replace `-fx-border-*` with corresponding `--fx-border-*` CSS variables
- [ ] Include `--fx-border-style: solid` when using borders
- [ ] Replace `-fx-text-fill` with `--fx-text-fill` or target `fx-text { color: ...; }`
- [ ] Use standard CSS for fonts (`font-size`, `font-family`, `font-weight`)
- [ ] Prefer setting padding/spacing in Java code, or use `--fx-padding`
- [ ] Use module prefix for all class names
- [ ] For SVG: use `fill`/`stroke` instead of `background`/`border`
- [ ] For effects: use `box-shadow` and `filter` properties
- [ ] Test in browser to verify rendering
