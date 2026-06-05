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

function normalizeText(value) {
  return String(value || "").replace(/\s+/g, " ").trim();
}

function categoryRegex(label) {
  return new RegExp("\\b" + label + "\\b", "i");
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
  const label = CATEGORY_LABELS[profile.ageCategory] || "Kids";

  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(profile));

  const mirrorProfile = {
    name: profile.name,
    profileName: profile.name,
    displayName: profile.name,
    ageCategory: profile.ageCategory,
    selectedAgeCategory: profile.ageCategory,
    category: profile.ageCategory,
    ageGroup: profile.ageCategory,
    ageGroupLabel: label,
    mode: profile.ageCategory,
    modeLabel: label,
    createdAt: profile.createdAt
  };

  window.localStorage.setItem("mindlabProfile", JSON.stringify(mirrorProfile));
  window.localStorage.setItem("mindlab.profile", JSON.stringify(mirrorProfile));
  window.localStorage.setItem("MindLabProfile", JSON.stringify(mirrorProfile));
  window.localStorage.setItem("mindlab.selectedAgeCategory", profile.ageCategory);
  window.localStorage.setItem("mindlab.activeAgeCategory", profile.ageCategory);
}

function clearProfile() {
  window.localStorage.removeItem(STORAGE_KEY);
  window.localStorage.removeItem("mindlabProfile");
  window.localStorage.removeItem("mindlab.profile");
  window.localStorage.removeItem("MindLabProfile");
  window.localStorage.removeItem("mindlab.selectedAgeCategory");
  window.localStorage.removeItem("mindlab.activeAgeCategory");
}

function resetDomGuard() {
  document.querySelectorAll("[data-mindlab-age-hidden='true']").forEach((element) => {
    element.style.display = element.dataset.mindlabPreviousDisplay || "";
    element.removeAttribute("data-mindlab-age-hidden");
    element.removeAttribute("data-mindlab-previous-display");
  });
}

function shouldSkipElement(element) {
  if (!element) {
    return true;
  }

  if (element.closest(".mindlab-age-gate")) {
    return true;
  }

  if (element.closest("script, style, noscript, svg")) {
    return true;
  }

  return false;
}

function findBestHideTarget(element) {
  const preferredSelectors = [
    "[data-age-category]",
    "[data-age-mode]",
    "[data-category]",
    "[role='button']",
    "button",
    "a",
    "article",
    "li",
    "[class*='card']",
    "[class*='Card']",
    "[class*='tile']",
    "[class*='Tile']",
    "[class*='mode']",
    "[class*='Mode']",
    "[class*='category']",
    "[class*='Category']"
  ];

  for (const selector of preferredSelectors) {
    const target = element.closest(selector);

    if (target && !target.closest(".mindlab-age-gate")) {
      const text = normalizeText(target.textContent);

      if (text.length > 0 && text.length <= 500) {
        return target;
      }
    }
  }

  const directText = normalizeText(element.textContent);

  if (directText.length > 0 && directText.length <= 500) {
    return element;
  }

  return null;
}

function hideElement(element) {
  if (!element || element.dataset.mindlabAgeHidden === "true") {
    return;
  }

  element.dataset.mindlabAgeHidden = "true";
  element.dataset.mindlabPreviousDisplay = element.style.display || "";
  element.style.display = "none";
}

function hideOriginalUndefinedProfileBars() {
  document.querySelectorAll("div, section, aside, header").forEach((element) => {
    if (shouldSkipElement(element)) {
      return;
    }

    const text = normalizeText(element.textContent);

    if (/MindLab Profile:/i.test(text) && /undefined/i.test(text) && text.length <= 250) {
      hideElement(element);
    }
  });
}

function applyDomGuard(activeCategory, allowExplore) {
  resetDomGuard();

  document.documentElement.dataset.mindlabActiveAgeCategory = activeCategory;
  document.documentElement.dataset.mindlabExploreOtherCategories = allowExplore ? "true" : "false";

  hideOriginalUndefinedProfileBars();

  if (allowExplore) {
    return;
  }

  const activeLabel = CATEGORY_LABELS[activeCategory] || "Kids";
  const blockedLabels = Object.values(CATEGORY_LABELS).filter((label) => label !== activeLabel);

  const candidateSelector = [
    "[data-age-category]",
    "[data-age-mode]",
    "[data-category]",
    "button",
    "a",
    "[role='button']",
    "article",
    "li",
    "section",
    "div",
    "[class*='card']",
    "[class*='Card']",
    "[class*='tile']",
    "[class*='Tile']",
    "[class*='mode']",
    "[class*='Mode']",
    "[class*='category']",
    "[class*='Category']"
  ].join(",");

  const allCandidates = Array.from(document.querySelectorAll(candidateSelector));

  allCandidates.forEach((element) => {
    if (shouldSkipElement(element)) {
      return;
    }

    const text = normalizeText(element.textContent);

    if (!text || text.length > 500) {
      return;
    }

    const hasActiveLabel = categoryRegex(activeLabel).test(text);
    const blockedMatches = blockedLabels.filter((label) => categoryRegex(label).test(text));

    if (blockedMatches.length === 0) {
      return;
    }

    if (hasActiveLabel && blockedMatches.length > 0) {
      const childElements = Array.from(element.querySelectorAll("button,a,[role='button'],article,li,div,section"));

      childElements.forEach((child) => {
        if (shouldSkipElement(child)) {
          return;
        }

        const childText = normalizeText(child.textContent);

        if (!childText || childText.length > 500) {
          return;
        }

        const childHasActive = categoryRegex(activeLabel).test(childText);
        const childHasBlocked = blockedLabels.some((label) => categoryRegex(label).test(childText));

        if (childHasBlocked && !childHasActive) {
          const target = findBestHideTarget(child);

          if (target) {
            hideElement(target);
          }
        }
      });

      return;
    }

    const target = findBestHideTarget(element);

    if (target) {
      hideElement(target);
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

    const observer = new MutationObserver(() => {
      applyDomGuard(activeCategory, allowExplore);
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true,
      characterData: true
    });

    const interval = window.setInterval(() => {
      applyDomGuard(activeCategory, allowExplore);
    }, 250);

    return () => {
      observer.disconnect();
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
          <p>Use Review Profile to confirm the selected category.</p>
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
          <p>Default category: {CATEGORY_LABELS[profile.ageCategory]}</p>
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
