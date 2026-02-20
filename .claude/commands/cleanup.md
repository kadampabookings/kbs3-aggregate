Perform an iterative code cleanup on the kbs3-react codebase, validating all code against the project's code review checklist until everything is compliant and all tests pass.

## Scope

Target path: `$ARGUMENTS`

If no path argument was provided, identify recently changed files in `kbs3-react/` using `git diff --name-only` and `git status`. Otherwise, scan all `.ts`, `.tsx`, `.css`, and config files under the given path.

## Step 1: Read the Code Review Checklist

**You MUST start by reading the full checklist before doing anything else:**

```
Read kbs3-react/docs/code-review-checklist.md
```

Also read `kbs3-react/docs/testing-guide.md` for test-specific conventions.

Internalize every section — you will validate code against ALL of them.

## Step 2: Identify Target Files

Find all source files and their corresponding `__tests__/` test files in the scope. List them so the user can see what will be reviewed.

## Step 3: Full Code Review

Read each target file and validate it against **every applicable section** of the checklist:

- **Type safety**: no `any`, no `@ts-ignore`, no unsafe `as unknown as` casts
- **Naming & structure**: file organization, naming conventions, barrel exports
- **JSDoc**: all exports have JSDoc with `@param`, `@returns`, `@example`
- **Error handling**: proper try/catch, typed errors, no silent swallows
- **React patterns**: hook rules, memo usage, context patterns, dependency arrays
- **CSS**: namespace prefixes (`kbs-c-`, `kbs-bo-`, `kbs-fo-`), no inline styles
- **i18n**: feature-prefixed keys, no hardcoded user-facing strings
- **Security**: Zod validation on external data, no XSS vectors
- **Performance**: no unnecessary re-renders, proper memoization, lazy loading
- **Accessibility**: ARIA attributes, keyboard navigation
- **Code duplication**: DRY — extract shared logic into helpers
- **Dependencies**: proper imports, no circular dependencies
- **Constants**: no magic numbers or hardcoded strings
- **Testing**: every source file has a corresponding test in `__tests__/`, mocks properly isolated, console output suppressed in error tests, coverage gaps identified
- **Post-iteration cleanup**: no leftover TODOs, no dead code, no unused imports

### Test Code Compliance (applied to every `__tests__/*.test.ts(x)` file)

In addition to the checklist above, validate every test file against the **testing guide** (`kbs3-react/docs/testing-guide.md`). Specifically check:

- **File-level JSDoc**: each test file starts with a `/** */` block describing what is being tested
- **`describe`/`it` structure**: top-level `describe` matches the module under test, `it` descriptions are behavior-oriented (not implementation details)
- **Mock isolation**: mocks are set up with `vi.mock()` at module level, reset with `vi.clearAllMocks()` in `beforeEach`, and never leak between tests
- **No `any` types in tests**: test code follows the same type-safety rules as source code
- **Console suppression**: tests that trigger `console.error`/`console.warn` must spy and suppress, then restore with `mockRestore()`
- **Async handling**: `act()` wraps state updates, `waitFor()` used for async assertions, no floating promises
- **Test helper reuse**: shared mock factories and wrapper creators live in `test-utils.ts`, not duplicated across test files
- **Coverage completeness**: every public function/method in the source file has at least one corresponding test case — identify and flag any untested exports

For each file, record all violations found with the section number and a description of the issue.

## Step 4: Fix All Issues

Apply fixes directly to both source and test files. For each fix:
- Show the file path and the issue being fixed
- Make the minimal change needed to resolve the violation
- Do NOT introduce new issues while fixing existing ones

If a source file is missing its test file, create the test file following the conventions in the testing guide.

## Step 5: Run Tests

Execute:
```bash
cd kbs3-react && npx vitest run
```

If running against a specific workspace (e.g., `shared`):
```bash
cd kbs3-react/shared && npx vitest run
```

## Step 6: Fix Test Failures

If any tests fail:
- Read the failure output carefully
- Diagnose the root cause (broken test, broken source, or both)
- Fix the issue
- Do NOT just delete or skip failing tests

## Step 7: Iterate

Go back to **Step 3** and re-validate all target files. Fixes from Step 4 or Step 6 may have introduced new issues or missed edge cases.

**Repeat the loop (Steps 3-7) until:**
- Zero checklist violations remain across all files
- All tests pass with zero failures

Only then proceed to Step 8.

## Step 8: Report

Output a final summary:

```
## Cleanup Report

### Files Reviewed
[List of all files checked]

### Issues Found and Fixed
[For each issue: file, section violated, what was fixed]

### Test Results
[Final test run output — all passing]

### Iterations Required
[How many passes it took to reach zero issues]
```
