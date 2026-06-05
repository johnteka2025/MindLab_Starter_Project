import { useEffect, useMemo, useState } from "react";
import "./MindLabAgeProfileGate.css";

const STORAGE_KEY = "mindlab.localProfile.v1";
const EVENT_NAME = "mindlab-profile-changed";

const AGE_CATEGORIES = [
  { id: "kids", label: "Kids", description: "Simple, playful activities for younger players." },
  { id: "adults", label: "Adults", description: "Focused activities for adult players." },
  { id: "seniors", label: "Seniors", description: "Clear, comfortable activities for senior players." }
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

function publishProfile(profile, allowExplore) {
  const detail = {
    profile,
    activeAgeCategory: profile?.ageCategory || "kids",
    allowExploreOtherCategories: Boolean(allowExplore)
  };

  window.dispatchEvent(new CustomEvent(EVENT_NAME, { detail }));
}

function saveProfile(profile, allowExplore) {
  const label = CATEGORY_LABELS[profile.ageCategory] || "Kids";

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

  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(profile));
  window.localStorage.setItem("mindlabProfile", JSON.stringify(mirrorProfile));
  window.localStorage.setItem("mindlab.profile", JSON.stringify(mirrorProfile));
  window.localStorage.setItem("MindLabProfile", JSON.stringify(mirrorProfile));
  window.localStorage.setItem("mindlab.selectedAgeCategory", profile.ageCategory);
  window.localStorage.setItem("mindlab.activeAgeCategory", profile.ageCategory);
  window.localStorage.setItem("mindlab.allowExploreOtherCategories", allowExplore ? "true" : "false");

  publishProfile(profile, allowExplore);
}

function clearProfile() {
  window.localStorage.removeItem(STORAGE_KEY);
  window.localStorage.removeItem("mindlabProfile");
  window.localStorage.removeItem("mindlab.profile");
  window.localStorage.removeItem("MindLabProfile");
  window.localStorage.removeItem("mindlab.selectedAgeCategory");
  window.localStorage.removeItem("mindlab.activeAgeCategory");
  window.localStorage.removeItem("mindlab.allowExploreOtherCategories");

  window.dispatchEvent(new CustomEvent(EVENT_NAME, {
    detail: {
      profile: null,
      activeAgeCategory: "kids",
      allowExploreOtherCategories: false
    }
  }));
}

export default function MindLabAgeProfileGate({ children }) {
  const loadedProfile = useMemo(() => loadProfile(), []);
  const [profile, setProfile] = useState(loadedProfile);
  const [name, setName] = useState(loadedProfile?.name || "");
  const [selectedAgeCategory, setSelectedAgeCategory] = useState(loadedProfile?.ageCategory || "kids");
  const [allowExplore, setAllowExplore] = useState(false);
  const [showReview, setShowReview] = useState(false);
  const [screen, setScreen] = useState(loadedProfile ? "game" : "profile");

  const activeCategory = profile?.ageCategory || selectedAgeCategory || "kids";

  useEffect(() => {
    if (profile) {
      saveProfile(profile, allowExplore);
    }
  }, [profile, allowExplore]);

  function createProfile() {
    const nextProfile = {
      name: name.trim() || "MindLab Player",
      ageCategory: selectedAgeCategory,
      createdAt: new Date().toISOString()
    };

    setProfile(nextProfile);
    setAllowExplore(false);
    setShowReview(false);
    setScreen("game");
    saveProfile(nextProfile, false);
  }

  function exitProfile() {
    clearProfile();
    setProfile(null);
    setName("");
    setSelectedAgeCategory("kids");
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
          <p>Only a local profile name and selected category are used.</p>
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

      {children}
    </>
  );
}
