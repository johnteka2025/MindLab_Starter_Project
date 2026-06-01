import {
  MINDLAB_PRODUCT_DECISIONS,
  filterContentByAgeCategory,
  buildProfileReview,
  getPolicyNavigationLabels
} from "./mindlabProductFeedbackControls.js";

const PROFILE_REVIEW_LABEL = "Profile Review";
const RETURN_TO_MAIN_MENU_LABEL = "Return to Main Menu";
const BACK_TO_GAME_LABEL = "Back to Game";
const EXIT_PROFILE_LABEL = "Exit Profile";
const SWITCH_PROFILE_LABEL = "Switch Profile";
const RESET_LOCAL_PROFILE_LABEL = "Reset Local Profile";

function safeReadJson(value) {
  try {
    return JSON.parse(value);
  } catch {
    return null;
  }
}

function readStoredProfile() {
  if (typeof window === "undefined" || !window.localStorage) {
    return { isGuest: true };
  }

  const keys = [
    "mindlab_profile",
    "mindlabProfile",
    "mindlabLocalProfile",
    "localProfile",
    "profile"
  ];

  for (const key of keys) {
    const raw = window.localStorage.getItem(key);
    if (!raw) continue;

    const parsed = safeReadJson(raw);
    if (parsed && typeof parsed === "object") {
      return parsed;
    }
  }

  return { isGuest: true };
}

function clearMindLabLocalProfile() {
  if (typeof window === "undefined" || !window.localStorage) return;

  const keys = [
    "mindlab_profile",
    "mindlabProfile",
    "mindlabLocalProfile",
    "localProfile",
    "profile"
  ];

  for (const key of keys) {
    window.localStorage.removeItem(key);
  }

  window.dispatchEvent(new CustomEvent("mindlab:profile-reset"));
}

function createInfoRow(label, value) {
  const row = document.createElement("div");
  row.style.display = "flex";
  row.style.justifyContent = "space-between";
  row.style.gap = "1rem";
  row.style.margin = "0.25rem 0";

  const left = document.createElement("strong");
  left.textContent = label;

  const right = document.createElement("span");
  right.textContent = value;

  row.appendChild(left);
  row.appendChild(right);

  return row;
}

function createButton(label, onClick) {
  const button = document.createElement("button");
  button.type = "button";
  button.textContent = label;
  button.style.margin = "0.25rem";
  button.style.padding = "0.45rem 0.65rem";
  button.style.borderRadius = "0.5rem";
  button.style.border = "1px solid currentColor";
  button.style.cursor = "pointer";
  button.addEventListener("click", onClick);
  return button;
}

export function renderMindLabProductFeedbackUiIntegration() {
  if (typeof document === "undefined") return;

  if (document.getElementById("mindlab-product-feedback-ui-integration")) {
    return;
  }

  const storedProfile = readStoredProfile();
  const review = buildProfileReview(storedProfile);
  const policyLabels = getPolicyNavigationLabels();

  const section = document.createElement("section");
  section.id = "mindlab-product-feedback-ui-integration";
  section.setAttribute("aria-label", PROFILE_REVIEW_LABEL);
  section.style.maxWidth = "720px";
  section.style.margin = "1rem auto";
  section.style.padding = "1rem";
  section.style.border = "1px solid rgba(0,0,0,0.25)";
  section.style.borderRadius = "0.75rem";
  section.style.background = "rgba(255,255,255,0.92)";
  section.style.color = "#111";
  section.style.fontFamily = "system-ui, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif";

  const title = document.createElement("h2");
  title.textContent = PROFILE_REVIEW_LABEL;
  title.style.marginTop = "0";

  const description = document.createElement("p");
  description.textContent = "Review your local MindLab profile before continuing. MindLab uses display name and selected age category only. Email, password, exact age, and birthdate are not collected.";

  section.appendChild(title);
  section.appendChild(description);

  section.appendChild(createInfoRow("Display name", review.displayName));
  section.appendChild(createInfoRow("Selected age category", review.selectedAgeCategory));
  section.appendChild(createInfoRow("Profile type", review.profileType));
  section.appendChild(createInfoRow("Age-category behavior", MINDLAB_PRODUCT_DECISIONS.ageCategoryBehavior));

  const controls = document.createElement("div");
  controls.style.marginTop = "0.75rem";

  controls.appendChild(createButton(EXIT_PROFILE_LABEL, () => {
    window.dispatchEvent(new CustomEvent("mindlab:exit-profile"));
    window.scrollTo({ top: 0, behavior: "smooth" });
  }));

  controls.appendChild(createButton(SWITCH_PROFILE_LABEL, () => {
    window.dispatchEvent(new CustomEvent("mindlab:switch-profile"));
    window.scrollTo({ top: 0, behavior: "smooth" });
  }));

  controls.appendChild(createButton(RESET_LOCAL_PROFILE_LABEL, () => {
    clearMindLabLocalProfile();
    window.location.reload();
  }));

  controls.appendChild(createButton(policyLabels[0] || RETURN_TO_MAIN_MENU_LABEL, () => {
    window.location.hash = "";
    window.scrollTo({ top: 0, behavior: "smooth" });
  }));

  controls.appendChild(createButton(policyLabels[1] || BACK_TO_GAME_LABEL, () => {
    if (window.history.length > 1) {
      window.history.back();
    } else {
      window.scrollTo({ top: 0, behavior: "smooth" });
    }
  }));

  section.appendChild(controls);

  const root = document.getElementById("root") || document.body;
  root.appendChild(section);
}

export const mindLabProductFeedbackUiIntegration = {
  label: PROFILE_REVIEW_LABEL,
  profileReviewLabel: PROFILE_REVIEW_LABEL,
  returnToMainMenuLabel: RETURN_TO_MAIN_MENU_LABEL,
  backToGameLabel: BACK_TO_GAME_LABEL,
  exitProfileLabel: EXIT_PROFILE_LABEL,
  switchProfileLabel: SWITCH_PROFILE_LABEL,
  resetLocalProfileLabel: RESET_LOCAL_PROFILE_LABEL,
  decisions: MINDLAB_PRODUCT_DECISIONS,
  filterContentByAgeCategory,
  buildProfileReview,
  getPolicyNavigationLabels,
  renderMindLabProductFeedbackUiIntegration
};

if (typeof window !== "undefined") {
  window.MindLabProductFeedbackUiIntegration = mindLabProductFeedbackUiIntegration;

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", renderMindLabProductFeedbackUiIntegration, { once: true });
  } else {
    window.setTimeout(renderMindLabProductFeedbackUiIntegration, 0);
  }
}
