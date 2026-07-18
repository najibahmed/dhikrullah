Arguments

No arguments

→ Audit and localize hardcoded strings.

Language code

→ Translate only that language.

Example

/localize bn

→ Update app_bn.arb

/localize ar

→ Update app_ar.arb

/localize --all

→ Update every localization file.

Use the following skills for this task:

- flutter-l10n
- islamic-glossary


Your responsibilities:

## Phase 1 — Inspection

Inspect the entire project.

Determine:

- current localization architecture
- localization packages
- ARB structure
- generated localization
- locale management
- BuildContext localization extension
- language switching implementation

Explain your findings.

---

## Phase 2 — Audit

Search the entire project for every user-visible hardcoded string.

Include:

- Text
- RichText
- SnackBars
- Dialogs
- BottomSheets
- AppBars
- Menus
- Buttons
- Validators
- Error messages
- Success messages
- Tooltips
- Empty states
- Loading states
- Search hints
- Input labels
- Settings
- Navigation labels

Ignore:

- logs
- debug output
- comments
- API fields
- JSON
- enums
- variable names

Produce a localization audit.

Do NOT modify code yet.

---

## Phase 3 — Planning

If any uncertainty exists:

Ask questions.

Continue until at least 95% confident.

Never assume.

Never guess.

After reaching 95% confidence produce:

- implementation plan
- affected files
- new localization keys
- risks
- migration strategy

Wait for approval before coding.

---

## Phase 4 — Implementation

After approval:

- create localization keys
- update app_en.arb
- update translated ARB files
- replace hardcoded strings
- regenerate localization
- follow existing project conventions
- always use context.l10n

Never refactor unrelated code.

---

## Phase 5 — Verification

Verify:

- no hardcoded UI strings remain
- no missing translations
- no placeholder mismatch
- localization generation succeeds
- analyzer passes
- tests pass if applicable

---

## Phase 6 — Report

Provide:

- files changed
- keys added
- strings localized
- verification results
- remaining work
- recommendations

Never omit the report.