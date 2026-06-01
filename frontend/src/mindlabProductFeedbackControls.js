export const MINDLAB_PRODUCT_DECISIONS = {
  ageCategoryBehavior: "RESTRICT_VISIBLE_CONTENT_BY_SELECTED_AGE_GROUP",
  collectEmail: false,
  collectPassword: false,
  collectExactAge: false,
  collectBirthdate: false,
  useSignOutLabel: false,
  approvedProfileExitLabels: ["Exit Profile", "Switch Profile", "Reset Local Profile"],
  policyReturnNavigationLabels: ["Return to Main Menu", "Back to Game"],
  googlePlayStatus: "HOLD",
  publicFeedbackCaptureStatus: "HOLD_UNTIL_PRODUCT_FEEDBACK_IMPLEMENTED_AND_VALIDATED"
};

export function filterContentByAgeCategory(items, selectedAgeCategory) {
  if (!Array.isArray(items)) return [];
  if (!selectedAgeCategory) return items;
  return items.filter((item) => {
    if (!item) return false;
    const itemAge = item.ageCategory || item.category || item.group || item.ageGroup;
    if (!itemAge) return true;
    return String(itemAge).toLowerCase() === String(selectedAgeCategory).toLowerCase();
  });
}

export function buildProfileReview(profile) {
  return {
    displayName: profile?.displayName || "Guest",
    selectedAgeCategory: profile?.ageCategory || "Not selected",
    profileType: profile?.isGuest ? "Guest" : "Local Profile",
    allowedControls: ["Exit Profile", "Switch Profile", "Reset Local Profile"]
  };
}

export function getPolicyNavigationLabels() {
  return ["Return to Main Menu", "Back to Game"];
}
