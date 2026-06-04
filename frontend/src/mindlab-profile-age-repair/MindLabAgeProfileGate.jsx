import { useEffect, useMemo, useState } from "react";
import "./MindLabAgeProfileGate.css";

const STORAGE_KEY = "mindlab.localProfile.v1";

const AGE_CATEGORIES = [
  {
    id: "kids",
    label: "Kids",
    description: "Simple, playful activities for younger players."
  },
  {
    id: "adults",
    label: "Adults",
    description: "Focused activities for adult players."
  },
  {
    id: "seniors",
    label: "Seniors",
    description: "Clear, comfortable activities for senior players."
  }
];

const CATEGORY_LABELS = {
  kids: "Kids",
  adults: "Adults",
  seniors: "Seniors"
};

function isAgeCategory(value) {
  return value === "kids" || value === "adults" || value === "seniors";
}

function loadProfile() {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);

    if (!raw) {
      return null;
    }

    const parsed = JSON.parse(raw);

    if (!parsed || !parsed.name || !isAgeCategory(parsed.ageCategory)) {
      return null;
    }

    return {
      name: parsed.name,
      ageCategory: parsed.ageCategory,
      createdAt: parsed.createdAt || new Date().toISOString()
    };
  } catch {
    return null;
  }
}

function saveProfile(profile) {
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(profile));
}

function clearProfile() {
  window.localStorage.removeItem(STORAGE_KEY);
}

function resetDomGuard() {
  document.querySelectorAll("[data-mindlab-age-hidden='true']").forEach((element) => {
    element.style.display = element.dataset.mindlabPreviousDisplay || "";
    delete element.dataset.mindlabAgeHidden;
    delete element.dataset.mindlabPreviousDisplay;
  });
}

function applyDomGuard(activeCategory, allowExplore) {
  resetDomGuard();

  if (allowExplore) {
    return;
  }

  const activeLabel = CATEGORY_LABELS[activeCategory];
  const blockedLabels = Object.values(CATEGORY_LABELS).filter((label) => label !== activeLabel);
  const selector = "button, a, [role='button'], [data-age-category], [class*='card'], [class*='tile'], section, article";

  document.querySelectorAll(selector).forEach((element) => {
    if (element.closest(".mindlab-age-gate")) {
      return;
    }

    const text = (element.textContent || "").replace(/\s+/g, " ").trim();

    if (!text) {
      return;
    }

    const hasActiveLabel = new RegExp(`\\b${activeLabel}\\b`, "i").test(text);
    const hasBlockedLabel = blockedLabels.some((label) => new RegExp(`\\b${label}\\b`, "i").test(text));

    if (hasBlockedLabel && !hasActiveLabel) {
      element.dataset.mindlabAgeHidden = "true";
      element.dataset.mindlabPreviousDisplay = element.style.display || "";
      element.style.display = "none";
    }
  });
}

export default function MindLabAgeProfileGate({ children }) {
  const loadedProfile = useMemo(() => loadProfile(), []);
  const [profile, setProfile] = useState(loadedProfile);
  const [name, setName] = useState(loadedProfile?.name || "");
  const [selectedAgeCategory, setSelectedAgeCategory] = useState(loadedProfile?.ageCategory || "kids");
  const [activeCategory, setActiveCategory] = useState(loadedProfile?.ageCategory || "kids");
  const [allowExplore, setAllowExplore] = useState(false);
  const [showReview, setShowReview] = useState(false);
  const [screen, setScreen] = useState(loadedProfile ? "game" : "profile");

  useEffect(() => {
    if (!profile) {
      resetDomGuard();
      return undefined;
    }

    applyDomGuard(activeCategory, allowExplore);
    const interval = window.setInterval(() => applyDomGuard(activeCategory, allowExplore), 500);

    return () => {
      window.clearInterval(interval);
      resetDomGuard();
    };
  }, [profile, activeCategory, allowExplore]);

  function createProfile() {
    const safeName = name.trim() || "MindLab Player";

    const nextProfile = {
      name: safeName,
      ageCategory: selectedAgeCategory,
      createdAt: new Date().toISOString()
    };

    saveProfile(nextProfile);
    setProfile(nextProfile);
    setActiveCategory(nextProfile.ageCategory);
    setAllowExplore(false);
    setShowReview(false);
    setScreen("game");
  }

  function exitProfile() {
    clearProfile();
    resetDomGuard();
    setProfile(null);
    setName("");
    setSelectedAgeCategory("kids");
    setActiveCategory("kids");
    setAllowExplore(false);
    setShowReview(false);
    setScreen("profile");
  }

  if (screen === "privacy") {
    return (
      <main className="mindlab-age-gate mindlab-age-gate-page">
        <section className="mindlab-age-gate-card">
          <h1>Privacy</h1>
          <p>MindLab uses a local profile on this device to guide the game experience.</p>
          <p>Only a local profile name and selected category are used in this repair scope.</p>
          <div className="mindlab-age-gate-actions">
            <button type="button" onClick={() => setScreen("profile")}>Return to Main Menu</button>
            <button type="button" onClick={() => setScreen(profile ? "game" : "profile")}>Back to Game</button>
          </div>
        </section>
      </main>
    );
  }

  if (screen === "support") {
    return (
      <main className="mindlab-age-gate mindlab-age-gate-page">
        <section className="mindlab-age-gate-card">
          <h1>Support</h1>
          <p>Use Review Profile to confirm the selected age category.</p>
          <p>Use Exit Profile to clear the local profile and start again.</p>
          <div className="mindlab-age-gate-actions">
            <button type="button" onClick={() => setScreen("profile")}>Return to Main Menu</button>
            <button type="button" onClick={() => setScreen(profile ? "game" : "profile")}>Back to Game</button>
          </div>
        </section>
      </main>
    );
  }

  if (!profile || screen === "profile") {
    return (
      <main className="mindlab-age-gate mindlab-age-gate-page">
        <section className="mindlab-age-gate-card">
          <h1>Create Local Profile</h1>

          <label className="mindlab-age-gate-label">
            Profile name
            <input
              value={name}
              onChange={(event) => setName(event.target.value)}
              placeholder="MindLab Player"
            />
          </label>

          <fieldset className="mindlab-age-gate-fieldset">
            <legend>Select default age category</legend>
            {AGE_CATEGORIES.map((category) => (
              <label key={category.id} className="mindlab-age-gate-option">
                <input
                  type="radio"
                  name="mindlab-age-category"
                  value={category.id}
                  checked={selectedAgeCategory === category.id}
                  onChange={() => setSelectedAgeCategory(category.id)}
                />
                <span>
                  <strong>{category.label}</strong>
                  <small>{category.description}</small>
                </span>
              </label>
            ))}
          </fieldset>

          <div className="mindlab-age-gate-actions">
            <button type="button" onClick={createProfile}>Create Local Profile</button>
          </div>

          <div className="mindlab-age-gate-links">
            <button type="button" onClick={() => setScreen("privacy")}>Privacy</button>
            <button type="button" onClick={() => setScreen("support")}>Support</button>
          </div>
        </section>
      </main>
    );
  }

  return (
    <>
      <aside className="mindlab-age-gate mindlab-age-gate-toolbar">
        <strong>{CATEGORY_LABELS[activeCategory]} default profile</strong>
        <span>{profile.name}</span>

        <button type="button" onClick={() => setShowReview((value) => !value)}>Review Profile</button>
        <button type="button" onClick={() => setAllowExplore((value) => !value)}>
          {allowExplore ? "Return to Default Category" : "Explore Other Categories"}
        </button>
        <button type="button" onClick={() => setScreen("privacy")}>Privacy</button>
        <button type="button" onClick={() => setScreen("support")}>Support</button>
        <button type="button" onClick={exitProfile}>Exit Profile</button>
      </aside>

      {showReview && (
        <section className="mindlab-age-gate mindlab-age-gate-review">
          <h2>Profile Review</h2>
          <p>Profile name: {profile.name}</p>
          <p>Default age category: {CATEGORY_LABELS[profile.ageCategory]}</p>
          <p>Current view: {allowExplore ? "Exploring other categories" : CATEGORY_LABELS[activeCategory]}</p>
        </section>
      )}

      {allowExplore && (
        <section className="mindlab-age-gate mindlab-age-gate-switcher">
          <h2>Switch Age Category</h2>
          {AGE_CATEGORIES.map((category) => (
            <button
              key={category.id}
              type="button"
              onClick={() => {
                setActiveCategory(category.id);
                setAllowExplore(false);
              }}
            >
              {category.label}
            </button>
          ))}
        </section>
      )}

      {children}
    </>
  );
}

