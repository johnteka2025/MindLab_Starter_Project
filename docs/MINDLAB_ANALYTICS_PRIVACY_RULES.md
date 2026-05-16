# MindLab Analytics Privacy Rules

Approved scope: Analytics planning
Repository root: C:\Projects\MindLab_Starter_Project
QA notes root: C:\Projects\MindLab_QA_Notes

## Data Collection Restrictions

- Do not collect names.
- Do not collect email addresses.
- Do not collect free-text child input.
- Do not collect exact birthdates.
- Do not intentionally collect IP addresses.
- Do not collect device identifiers unless separately approved.
- Do not collect classroom, school, household, or location details.

## Allowed Aggregate Fields

- Age category: Kids, Adults, Seniors.
- Difficulty level.
- Event name.
- Event count.
- Completion status.
- Error category.
- Session-level anonymous count only if separately approved.

## Future Approval Requirements

- Any SDK installation requires separate approval.
- Any event tracking implementation requires separate approval.
- Any network call for analytics requires separate approval.
- Any data retention policy requires separate approval.
- Any child-facing analytics behavior requires separate privacy review.

## PASS Tokens

PASS: ANALYTICS_PRIVACY_RULES_CREATED
PASS: NO_PII_COLLECTION_ALLOWED
PASS: CHILD_DATA_PROTECTION_RULES_DOCUMENTED
PASS: FUTURE_IMPLEMENTATION_REQUIRES_SEPARATE_APPROVAL
