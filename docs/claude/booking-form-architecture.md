# Booking Form Architecture

## Overview

This document describes the architecture for reusable booking forms in the front-office.
The design allows:
- Common pages (Steps 2-7) to be shared across all forms
- Custom options pages (Step 1) per form type
- Overriding entire pages when needed
- Overriding individual sections within pages
- Consistent theming and styling

## Package Structure

```
one.modality.booking.frontoffice.bookingpage/
├── core/
│   ├── AbstractBookingForm.java           # Template Method for flow
│   ├── BookingFormContext.java            # Shared state across pages
│   ├── BookingFormStep.java               # Enum of standard steps
│   └── BookingFormCallbacks.java          # Inter-section communication
│
├── pages/
│   │── standard/                          # Default implementations
│   │   ├── StandardYourInformationPage.java
│   │   ├── StandardMemberSelectionPage.java
│   │   ├── StandardSummaryPage.java
│   │   ├── StandardPendingBookingsPage.java
│   │   ├── StandardPaymentPage.java
│   │   └── StandardConfirmationPage.java
│   │
│   └── base/
│       └── AbstractBookingPage.java       # Base class for pages
│
├── sections/
│   ├── base/
│   │   └── AbstractBookingSection.java    # Base class for sections
│   │
│   ├── auth/                              # Authentication sections
│   │   ├── EmailInputSection.java
│   │   ├── LoginSection.java
│   │   └── NewUserSection.java
│   │
│   ├── member/                            # Member selection sections
│   │   └── MemberSelectionSection.java
│   │
│   ├── summary/                           # Summary components
│   │   ├── AttendeeSummarySection.java
│   │   ├── EventSummarySection.java
│   │   └── PriceBreakdownSection.java
│   │
│   ├── payment/                           # Payment components
│   │   ├── PaymentOptionsSection.java
│   │   ├── PaymentMethodSection.java
│   │   └── TermsAcceptanceSection.java
│   │
│   └── confirmation/                      # Confirmation components
│       ├── BookingConfirmedSection.java
│       └── NextStepsSection.java
│
└── theme/
    └── BookingFormColorScheme.java        # Color scheme with getId() for CSS classes and getPrimary() for SVG icons
```

## Core Classes

### 1. BookingFormContext - Shared State

The context holds all shared state and is passed to every page and section.
This eliminates the need for sections to know about each other directly.

```java
package one.modality.booking.frontoffice.bookingpage.core;

/**
 * Shared context for all booking form pages and sections.
 * Provides access to working booking, user state, and callbacks.
 */
public class BookingFormContext {

    // === Dependencies ===
    private final HasWorkingBookingProperties activity;
    private final BookingFormColorScheme colorScheme;
    private final String currencySymbol;

    // === User State ===
    private final ObjectProperty<Person> loggedInPersonProperty = new SimpleObjectProperty<>();
    private final ObjectProperty<MemberInfo> selectedMemberProperty = new SimpleObjectProperty<>();
    private final ObjectProperty<NewUserData> pendingNewUserDataProperty = new SimpleObjectProperty<>();

    // === Booking State ===
    private final BooleanProperty allowMemberReselectionProperty = new SimpleBooleanProperty(false);
    private final StringProperty bookingReferenceProperty = new SimpleStringProperty();

    // === Navigation Callbacks ===
    private final BookingFormCallbacks callbacks = new BookingFormCallbacks();

    // === Accessors ===

    public WorkingBookingProperties getWorkingBookingProperties() {
        return activity.getWorkingBookingProperties();
    }

    public WorkingBooking getWorkingBooking() {
        return getWorkingBookingProperties().getWorkingBooking();
    }

    public Event getEvent() {
        return getWorkingBooking().getEvent();
    }

    public BookingFormColorScheme getColorScheme() {
        return colorScheme;
    }

    public String getCurrencySymbol() {
        return currencySymbol;
    }

    // Properties for binding
    public ObjectProperty<Person> loggedInPersonProperty() { return loggedInPersonProperty; }
    public ObjectProperty<MemberInfo> selectedMemberProperty() { return selectedMemberProperty; }
    public BookingFormCallbacks getCallbacks() { return callbacks; }

    // Convenience methods
    public Person getLoggedInPerson() { return loggedInPersonProperty.get(); }
    public void setLoggedInPerson(Person person) { loggedInPersonProperty.set(person); }

    public MemberInfo getSelectedMember() { return selectedMemberProperty.get(); }
    public void setSelectedMember(MemberInfo member) { selectedMemberProperty.set(member); }

    public boolean isUserLoggedIn() { return getLoggedInPerson() != null; }
    public boolean isNewUser() { return pendingNewUserDataProperty.get() != null; }
}
```

### 2. BookingFormCallbacks - Inter-Section Communication

```java
package one.modality.booking.frontoffice.bookingpage.core;

/**
 * Callbacks for communication between form components.
 * Sections fire events, the form handles navigation.
 */
public class BookingFormCallbacks {

    // === Authentication Events ===
    private Consumer<Person> onLoginSuccess;
    private Consumer<NewUserData> onNewUserContinue;
    private Runnable onLogout;

    // === Member Selection Events ===
    private Consumer<MemberInfo> onMemberSelected;
    private Runnable onAddNewMember;

    // === Navigation Events ===
    private Runnable onBackPressed;
    private Runnable onContinuePressed;

    // === Booking Events ===
    private Runnable onBookingSubmitted;
    private Consumer<PaymentResult> onPaymentCompleted;
    private Runnable onMakeAnotherBooking;

    // Setters and fire methods...

    public void fireLoginSuccess(Person person) {
        if (onLoginSuccess != null) onLoginSuccess.accept(person);
    }

    public void fireMemberSelected(MemberInfo member) {
        if (onMemberSelected != null) onMemberSelected.accept(member);
    }

    // etc...
}
```

### 3. AbstractBookingForm - Template Method Pattern

```java
package one.modality.booking.frontoffice.bookingpage.core;

/**
 * Base class for all booking forms using Template Method pattern.
 *
 * Subclasses MUST implement:
 * - createOptionsPages() - Step 1 is always custom
 *
 * Subclasses MAY override:
 * - createYourInformationPage() - to customize login/registration
 * - createMemberSelectionPage() - to customize member selection
 * - createSummaryPage() - to customize summary display
 * - createPendingBookingsPage() - to customize basket
 * - createPaymentPage() - to customize payment
 * - createConfirmationPage() - to customize confirmation
 *
 * Subclasses MAY override hooks:
 * - includeYourInformationPage() - return false to skip
 * - includeMemberSelectionPage() - return false to skip
 * - onNavigateFromOptions() - custom logic after options
 * - onBookingSubmitted() - custom logic after submission
 * - onPaymentCompleted() - custom logic after payment
 */
public abstract class AbstractBookingForm extends MultiPageBookingForm {

    protected final BookingFormContext context;

    // Page references for navigation (no array indices)
    protected BookingFormPage yourInformationPage;
    protected BookingFormPage memberSelectionPage;
    protected BookingFormPage summaryPage;
    protected BookingFormPage pendingBookingsPage;
    protected BookingFormPage paymentPage;
    protected BookingFormPage confirmationPage;

    public AbstractBookingForm(HasWorkingBookingProperties activity, EventBookingFormSettings settings) {
        super(activity, settings);
        this.context = createContext(activity, settings);
        setupCallbacks();
    }

    /**
     * Creates the form context. Override to provide custom context.
     */
    protected BookingFormContext createContext(HasWorkingBookingProperties activity, EventBookingFormSettings settings) {
        return new BookingFormContext(activity, determineColorScheme(settings), determineCurrencySymbol(settings));
    }

    /**
     * Template method that creates all pages in the standard flow.
     * Calls factory methods that can be overridden by subclasses.
     */
    @Override
    public final BookingFormPage[] getPages() {
        List<BookingFormPage> pages = new ArrayList<>();

        // Step 1: Options (MUST be provided by subclass)
        pages.addAll(createOptionsPages());

        // Steps 2-7: Standard flow with hooks for customization
        if (includeYourInformationPage()) {
            yourInformationPage = createYourInformationPage();
            pages.add(yourInformationPage);
        }

        if (includeMemberSelectionPage()) {
            memberSelectionPage = createMemberSelectionPage();
            pages.add(memberSelectionPage);
        }

        summaryPage = createSummaryPage();
        pages.add(summaryPage);

        pendingBookingsPage = createPendingBookingsPage();
        pages.add(pendingBookingsPage);

        paymentPage = createPaymentPage();
        pages.add(paymentPage);

        confirmationPage = createConfirmationPage();
        pages.add(confirmationPage);

        return pages.toArray(new BookingFormPage[0]);
    }

    // ===========================================
    // ABSTRACT METHOD - Must be implemented
    // ===========================================

    /**
     * Creates the options page(s) for Step 1.
     * This is ALWAYS custom per form type.
     *
     * @return List of pages for the options step (usually just one)
     */
    protected abstract List<BookingFormPage> createOptionsPages();

    // ===========================================
    // FACTORY METHODS - Override to customize
    // ===========================================

    /**
     * Creates the Your Information page (email-first login/registration).
     * Override to provide custom login flow.
     */
    protected BookingFormPage createYourInformationPage() {
        return new StandardYourInformationPage(context);
    }

    /**
     * Creates the Member Selection page.
     * Override to provide custom member selection.
     */
    protected BookingFormPage createMemberSelectionPage() {
        return new StandardMemberSelectionPage(context);
    }

    /**
     * Creates the Summary page.
     * Override to add custom sections or change layout.
     */
    protected BookingFormPage createSummaryPage() {
        return new StandardSummaryPage(context);
    }

    /**
     * Creates the Pending Bookings (basket) page.
     * Override to customize basket display.
     */
    protected BookingFormPage createPendingBookingsPage() {
        return new StandardPendingBookingsPage(context);
    }

    /**
     * Creates the Payment page.
     * Override to customize payment options/methods.
     */
    protected BookingFormPage createPaymentPage() {
        return new StandardPaymentPage(context);
    }

    /**
     * Creates the Confirmation page.
     * Override to customize confirmation display.
     */
    protected BookingFormPage createConfirmationPage() {
        return new StandardConfirmationPage(context);
    }

    // ===========================================
    // INCLUSION HOOKS - Override to skip pages
    // ===========================================

    /**
     * Whether to include the Your Information page.
     * Override to return false for forms that don't need login.
     */
    protected boolean includeYourInformationPage() {
        return true;
    }

    /**
     * Whether to include the Member Selection page.
     * Override to return false for simple single-person bookings.
     */
    protected boolean includeMemberSelectionPage() {
        return true;
    }

    // ===========================================
    // NAVIGATION HOOKS - Override for custom logic
    // ===========================================

    /**
     * Called after navigation from Options page.
     * Override to add custom logic (e.g., load additional data).
     */
    protected void onNavigateFromOptions() {
        // Default: no-op
    }

    /**
     * Called after booking is successfully submitted to database.
     * Override to add custom post-submission logic.
     */
    protected void onBookingSubmitted() {
        // Default: no-op
    }

    /**
     * Called after payment is completed.
     * Override to add custom post-payment logic.
     */
    protected void onPaymentCompleted(PaymentResult result) {
        // Default: no-op
    }

    // ===========================================
    // STANDARD NAVIGATION LOGIC
    // ===========================================

    private void setupCallbacks() {
        BookingFormCallbacks callbacks = context.getCallbacks();

        callbacks.setOnLoginSuccess(person -> {
            context.setLoggedInPerson(person);
            loadHouseholdMembers(person, () -> navigateTo(memberSelectionPage));
        });

        callbacks.setOnNewUserContinue(newUserData -> {
            context.setPendingNewUserData(newUserData);
            // Create temporary member for new user
            navigateTo(memberSelectionPage);
        });

        callbacks.setOnMemberSelected(member -> {
            context.setSelectedMember(member);
        });

        callbacks.setOnContinuePressed(this::handleContinue);
        callbacks.setOnBackPressed(this::handleBack);

        callbacks.setOnMakeAnotherBooking(() -> {
            resetForm();
            navigateToFirstPage();
        });
    }

    /**
     * Standard navigation to next page.
     * Uses page references instead of array indices.
     */
    protected void navigateTo(BookingFormPage page) {
        BookingFormPage[] pages = getPages();
        for (int i = 0; i < pages.length; i++) {
            if (pages[i] == page) {
                navigateToPage(i);
                return;
            }
        }
    }

    /**
     * Prepares for a new booking while keeping existing pending bookings.
     */
    protected void prepareForNewBooking() {
        context.setSelectedMember(null);
        context.setPendingNewUserData(null);
        context.setAllowMemberReselection(false);

        if (workingBookingProperties != null) {
            workingBookingProperties.getWorkingBooking().startNewBooking();
        }
    }

    /**
     * Full form reset for starting completely fresh.
     */
    protected void resetForm() {
        context.setLoggedInPerson(null);
        context.setSelectedMember(null);
        context.setPendingNewUserData(null);
        context.setAllowMemberReselection(false);

        if (workingBookingProperties != null) {
            workingBookingProperties.getWorkingBooking().startNewBooking();
        }
    }
}
```

### 4. Standard Page Implementations

```java
package one.modality.booking.frontoffice.bookingpage.pages.standard;

/**
 * Standard Summary page composed of reusable sections.
 * Can be subclassed to add/remove/replace sections.
 */
public class StandardSummaryPage extends AbstractBookingPage {

    public StandardSummaryPage(BookingFormContext context) {
        super(context, BookingFormStep.SUMMARY);
    }

    @Override
    protected List<BookingFormSection> createSections() {
        List<BookingFormSection> sections = new ArrayList<>();
        sections.add(createAttendeeSummarySection());
        sections.add(createEventSummarySection());
        sections.add(createPriceBreakdownSection());
        sections.addAll(createAdditionalSections()); // Hook for subclasses
        return sections;
    }

    /**
     * Creates the attendee summary section.
     * Override to customize attendee display.
     */
    protected BookingFormSection createAttendeeSummarySection() {
        return new AttendeeSummarySection(context);
    }

    /**
     * Creates the event summary section.
     * Override to customize event display.
     */
    protected BookingFormSection createEventSummarySection() {
        return new EventSummarySection(context);
    }

    /**
     * Creates the price breakdown section.
     * Override to customize price display.
     */
    protected BookingFormSection createPriceBreakdownSection() {
        return new PriceBreakdownSection(context);
    }

    /**
     * Hook for subclasses to add additional sections.
     * Default returns empty list.
     */
    protected List<BookingFormSection> createAdditionalSections() {
        return Collections.emptyList();
    }

    @Override
    protected void setupButtons() {
        setButtons(
            BookingFormButton.back(context.getCallbacks()::fireBackPressed),
            BookingFormButton.asyncPrimary(
                BaseI18nKeys.Continue,
                button -> submitBookingAndNavigateAsync(),
                validProperty()
            )
        );
    }
}
```

### 5. Reusable Section Base

```java
package one.modality.booking.frontoffice.bookingpage.sections.base;

/**
 * Base class for all booking form sections.
 * Provides access to context and standard utilities.
 */
public abstract class AbstractBookingSection implements BookingFormSection {

    protected final BookingFormContext context;
    private final BooleanProperty validProperty = new SimpleBooleanProperty(true);

    public AbstractBookingSection(BookingFormContext context) {
        this.context = context;
    }

    // Convenience accessors
    protected BookingFormColorScheme getColorScheme() {
        return context.getColorScheme();
    }

    protected String getCurrencySymbol() {
        return context.getCurrencySymbol();
    }

    protected WorkingBooking getWorkingBooking() {
        return context.getWorkingBooking();
    }

    protected BookingFormCallbacks getCallbacks() {
        return context.getCallbacks();
    }

    // Styling helpers
    protected void applyCardStyle(Region node) {
        BookingFormStyling.applyCardStyle(node, getColorScheme());
    }

    protected void applyPrimaryButtonStyle(Button button) {
        BookingFormStyling.applyPrimaryButtonStyle(button, getColorScheme());
    }

    // Validation
    @Override
    public BooleanProperty validProperty() {
        return validProperty;
    }

    protected void setValid(boolean valid) {
        validProperty.set(valid);
    }
}
```

## Usage Examples

### Example 1: MKMC Online Empowerment Form

```java
package org.kadampabookings.kbs.frontoffice.bookingform.mkmc.onlineempowerment;

public class MKMCOnlineEmpowermentBookingForm extends AbstractBookingForm {

    private EventHeaderSection eventHeaderSection;
    private PrerequisiteSection prerequisiteSection;
    private RateTypeSection rateTypeSection;
    private AudioRecordingSection audioRecordingSection;

    public MKMCOnlineEmpowermentBookingForm(HasWorkingBookingProperties activity, EventBookingFormSettings settings) {
        super(activity, settings);
    }

    @Override
    protected BookingFormContext createContext(HasWorkingBookingProperties activity, EventBookingFormSettings settings) {
        // Use MKMC-specific color scheme
        return new BookingFormContext(activity, BookingFormColorScheme.WISDOM_BLUE, "£");
    }

    @Override
    protected List<BookingFormPage> createOptionsPages() {
        // MKMC-specific options with prerequisite, rate type, audio recordings
        eventHeaderSection = new EventHeaderSection(context);
        prerequisiteSection = new PrerequisiteSection(context);
        rateTypeSection = new RateTypeSection(context);
        audioRecordingSection = new AudioRecordingSection(context);

        CompositeBookingFormPage optionsPage = new CompositeBookingFormPage(
            MKMCI18nKeys.Options,
            eventHeaderSection,
            prerequisiteSection,
            rateTypeSection,
            audioRecordingSection
        );

        optionsPage.setStep(true);
        optionsPage.setHeaderVisible(true);

        // Custom button with async spinner
        optionsPage.setButtons(
            BookingFormButton.asyncPrimary(
                MKMCI18nKeys.Continue,
                button -> navigateFromOptionsAsync(),
                Bindings.not(optionsPage.validProperty())
            )
        );

        return List.of(optionsPage);
    }

    @Override
    protected BookingFormPage createSummaryPage() {
        // Use custom summary that includes audio recording display
        return new MKMCSummaryPage(context, audioRecordingSection);
    }
}
```

### Example 2: Simple Day Course Form

```java
package org.kadampabookings.kbs.frontoffice.bookingform.simple;

public class SimpleDayCourseBookingForm extends AbstractBookingForm {

    public SimpleDayCourseBookingForm(HasWorkingBookingProperties activity, EventBookingFormSettings settings) {
        super(activity, settings);
    }

    @Override
    protected List<BookingFormPage> createOptionsPages() {
        // Simple form - just event info and date selection
        return List.of(
            new CompositeBookingFormPage(
                BaseI18nKeys.Options,
                new EventHeaderSection(context),
                new SimpleDateSelectionSection(context)
            )
        );
    }

    @Override
    protected boolean includeMemberSelectionPage() {
        // Day courses don't need member selection - book for self only
        return false;
    }
}
```

### Example 3: Hotel Retreat Form (Override Summary Page)

```java
package org.kadampabookings.kbs.frontoffice.bookingform.retreat;

public class HotelRetreatBookingForm extends AbstractBookingForm {

    private AccommodationSection accommodationSection;
    private MealSelectionSection mealSection;

    @Override
    protected List<BookingFormPage> createOptionsPages() {
        accommodationSection = new AccommodationSection(context);
        mealSection = new MealSelectionSection(context);

        return List.of(
            new CompositeBookingFormPage(BaseI18nKeys.Options,
                new EventHeaderSection(context),
                new TeachingProgrammeSection(context),
                accommodationSection,
                mealSection
            )
        );
    }

    @Override
    protected BookingFormPage createSummaryPage() {
        // Custom summary page with accommodation and meal details
        return new RetreatSummaryPage(context, accommodationSection, mealSection);
    }
}

// Custom summary page for retreats
public class RetreatSummaryPage extends StandardSummaryPage {

    private final AccommodationSection accommodationSection;
    private final MealSelectionSection mealSection;

    public RetreatSummaryPage(BookingFormContext context,
                              AccommodationSection accommodationSection,
                              MealSelectionSection mealSection) {
        super(context);
        this.accommodationSection = accommodationSection;
        this.mealSection = mealSection;
    }

    @Override
    protected List<BookingFormSection> createAdditionalSections() {
        // Add accommodation and meal summary sections
        return List.of(
            new AccommodationSummarySection(context, accommodationSection),
            new MealSummarySection(context, mealSection)
        );
    }
}
```

## Key Design Decisions

### 1. Context Object Pattern
All shared state lives in `BookingFormContext`, passed to every component.
This eliminates tight coupling between sections.

### 2. Template Method for Flow
`AbstractBookingForm.getPages()` is final and defines the standard flow.
Subclasses customize via factory methods and hooks.

### 3. Factory Methods for Customization
Each page/section has a factory method that can be overridden.
This allows replacing a single component without copying everything.

### 4. Composition over Inheritance for Sections
Pages are composed of sections. Sections can be mixed and matched.
New sections can be added via `createAdditionalSections()` hook.

### 5. Callbacks for Communication
Sections fire events via `BookingFormCallbacks`.
The form handles navigation logic, sections don't need to know about each other.

### 6. Page References Not Indices
Navigation uses page field references (`navigateTo(summaryPage)`) not array indices.
This is more maintainable and less error-prone.

## Migration Path

1. **Phase 1**: Create `BookingFormContext` and move shared state
2. **Phase 2**: Create `AbstractBookingForm` with factory methods
3. **Phase 3**: Extract common sections to `bookingpage.sections`
4. **Phase 4**: Create `Standard*Page` implementations
5. **Phase 5**: Migrate `MKMCOnlineEmpowermentBookingForm` to extend `AbstractBookingForm`
6. **Phase 6**: Create additional form types as needed

## Benefits

| Aspect | Benefit |
|--------|---------|
| **Reusability** | Steps 2-7 are written once, used everywhere |
| **Customization** | Override any page or section as needed |
| **Maintainability** | Changes to common flow propagate automatically |
| **Type Safety** | No array indices, compiler catches navigation errors |
| **Testing** | Sections can be unit tested in isolation |
| **Theming** | Color scheme flows through context to all components |
