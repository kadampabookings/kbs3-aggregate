# Booking Data API

Reference this when:
- Working with booking state management
- Understanding initial vs current booking state
- Binding UI to booking properties (prices, balance, etc.)
- Loading or modifying booking data

## Overview

Three key classes manage booking data on the client:

| Class | Purpose | Mutability |
|-------|---------|------------|
| DocumentAggregate | Holds server-loaded booking snapshot | READ-ONLY |
| WorkingBooking | Manages in-progress booking state | Mutable (via events) |
| WorkingBookingProperties | Exposes reactive properties for UI | Observable wrapper |

## DocumentAggregate

**Location**: `modality-fork/modality-ecommerce/modality-ecommerce-document-service/src/main/java/one/modality/ecommerce/document/service/DocumentAggregate.java`

**Purpose**: Immutable data container holding a booking snapshot loaded from the server.

**CRITICAL**: Never modify DocumentAggregate directly. All changes go through WorkingBooking.

### Key Methods
- `getDocument()` - The Document entity
- `getDocumentLines()` - What's being booked (rooms, meals, etc.)
- `getAttendances()` - When/where attendance happens
- `getMoneyTransfers()` - Payment records
- `getAttendancesAdded(excludePreviousVersions)` - Attendances added
- `getAttendancesRemoved(excludePreviousVersions)` - Attendances removed

### Data Structure
- Event chain: `previousVersion` + `newDocumentEvents` (event sourcing)
- Reconstructed state: document, documentLines, attendances, moneyTransfers

## WorkingBooking

**Location**: `modality-fork/modality-booking/modality-booking-client-workingbooking/src/main/java/one/modality/booking/client/workingbooking/WorkingBooking.java`

**Purpose**: Mutable facade for editing bookings. Tracks initial state vs changes.

### Three-State Model

1. **Initial State** (`getInitialDocumentAggregate()`)
   - Original booking from database (null for new bookings)
   - Never modified

2. **Changes** (`getDocumentChanges()`)
   - Observable list of user modifications
   - AddAttendancesEvent, RemoveAttendancesEvent, etc.

3. **Current State** (`getLastestDocumentAggregate()`)
   - Computed: initial + all changes replayed
   - Rebuilt on demand

### Key Methods

**State Queries**
- `isNewBooking()` - True if no initial aggregate
- `hasChanges()` / `hasChangesProperty()` - True if modifications exist
- `getVersion()` / `versionProperty()` - Increments on any change

**Price Calculation**
- `calculateTotal()` - Current total price
- `calculateDeposit()` - Current deposit
- `calculateBalance()` - Amount remaining to pay
- `calculatePreviousTotal()` - Original booking total
- `calculatePreviousBalance()` - Original balance

**Booking Modifications**
- `bookScheduledItems(items, addOnly)` - Add/replace scheduled items
- `unbookScheduledItems(items)` - Remove scheduled items
- `removeAttendance(attendance)` - Remove single attendance
- `cancelBooking()` / `uncancelBooking()` - Cancel/restore booking
- `addRequest(request)` - Add special request

**Change Management**
- `cancelChanges()` - Revert to initial state
- `startNewBooking()` - Reset for fresh booking
- `submitChanges(comment)` - Submit to server

### Usage Pattern
```java
// Compare initial vs current state
int previousTotal = workingBooking.calculatePreviousTotal();
int currentTotal = workingBooking.calculateTotal();
int additionalCost = currentTotal - previousTotal;

// Check what changed
List<Attendance> added = workingBooking.getAttendancesAdded(false);
List<Attendance> removed = workingBooking.getAttendancesRemoved(false);
```

## WorkingBookingProperties

**Location**: `modality-fork/modality-booking/modality-booking-client-workingbooking/src/main/java/one/modality/booking/client/workingbooking/WorkingBookingProperties.java`

**Purpose**: Observable property wrapper for UI binding. Auto-updates when WorkingBooking changes.

### Observable Properties

| Property | Raw Value | Formatted |
|----------|-----------|-----------|
| Deposit | `depositProperty()` | `formattedDepositProperty()` |
| Total | `totalProperty()` | `formattedTotalProperty()` |
| Balance | `balanceProperty()` | `formattedBalanceProperty()` |
| Min Deposit | `minDepositProperty()` | `formattedMinDepositProperty()` |
| Previous Total | `previousTotalProperty()` | `formattedPreviousTotalProperty()` |
| Previous Balance | `previousBalanceProperty()` | `formattedPreviousBalanceProperty()` |
| No Discount Total | `noDiscountTotalProperty()` | `formattedNoDiscountTotalProperty()` |

### Additional Properties
- `hasChangesProperty()` - Whether unsaved changes exist
- `submittableProperty()` - Whether booking can be submitted

### Usage Pattern
```java
// Get properties wrapper
WorkingBookingProperties props = context.getWorkingBookingProperties();

// Bind to UI
totalLabel.textProperty().bind(props.formattedTotalProperty());
submitButton.disableProperty().bind(props.submittableProperty().not());

// Access values directly
int balance = props.getBalance();
String formattedTotal = props.getFormattedTotal(); // "€1,500.00"
```

## Common Patterns

### 1. Calculating Price Difference
```java
// Create temporary booking to calculate period price
WorkingBooking tempBooking = new WorkingBooking(
    policyAggregate,
    workingBooking.getInitialDocumentAggregate()
);
tempBooking.unbookScheduledItems(items);
int unbookedPrice = tempBooking.calculateTotal();
tempBooking.bookScheduledItems(items, false);
int bookedPrice = tempBooking.calculateTotal();
int priceDiff = bookedPrice - unbookedPrice;
```

### 2. Accessing from BookingFormContext
```java
// In booking form sections
WorkingBooking wb = context.getWorkingBooking();
WorkingBookingProperties props = context.getWorkingBookingProperties();
```

### 3. Checking Initial vs New
```java
if (workingBooking.isNewBooking()) {
    // No previous state - this is a fresh booking
} else {
    // Modifying existing booking
    DocumentAggregate initial = workingBooking.getInitialDocumentAggregate();
}
```
