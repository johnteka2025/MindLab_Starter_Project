import React, { useMemo, useState } from "react";

const STORAGE_KEY = "mindlab.localProfile.v1";
const AGE_CATEGORIES = ["Kids", "Adults", "Seniors"];

function readProfile() {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

function makeProfile(displayName, selectedAgeCategory) {
  const now = new Date().toISOString();

  return {
    localProfileId: `mindlab-${Date.now()}`,
    displayName: displayName.trim(),
    selectedAgeCategory,
    privacyConsentVersion: "account-disclosure-v1",
    createdAt: now,
    updatedAt: now
  };
}

export default function LocalProfileGate({ children }) {
  const [profile, setProfile] = useState(readProfile);
  const [displayName, setDisplayName] = useState("");
  const [selectedAgeCategory, setSelectedAgeCategory] = useState("");
  const [guestMode, setGuestMode] = useState(false);

  const canCreate =
    displayName.trim().length > 0 &&
    AGE_CATEGORIES.includes(selectedAgeCategory);

  const activeModeLabel = useMemo(() => {
    if (guestMode) return "Guest mode";
    if (profile) return `${profile.displayName} - ${profile.selectedAgeCategory}`;
    return "No local profile selected";
  }, [guestMode, profile]);

  function saveProfile() {
    if (!canCreate) return;

    const next = makeProfile(displayName, selectedAgeCategory);

    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
    window.dispatchEvent(new CustomEvent("mindlab-profile-updated", { detail: next }));

    setProfile(next);
    setGuestMode(false);
  }

  function resetProfile() {
    window.localStorage.removeItem(STORAGE_KEY);
    window.dispatchEvent(new CustomEvent("mindlab-profile-reset"));

    setProfile(null);
    setGuestMode(false);
    setDisplayName("");
    setSelectedAgeCategory("");
  }

  window.MindLabLocalProfile = profile;

  if (!profile && !guestMode) {
    return (
      <main style={{ minHeight: "100vh", background: "#f8fafc", color: "#0f172a", fontFamily: "Arial, Helvetica, sans-serif", padding: 24 }}>
        <section style={{ maxWidth: 760, margin: "0 auto", background: "#ffffff", border: "1px solid #e2e8f0", borderRadius: 20, padding: 28, boxShadow: "0 18px 50px rgba(15,23,42,0.10)" }}>
          <p style={{ fontWeight: 700, color: "#075985" }}>MindLab Local Profile</p>

          <h1>Create Local Profile</h1>

          <p>
            Create a local profile on this device, or continue as guest.
            Email, password, exact age, and date of birth are not collected.
          </p>

          <label style={{ display: "block", fontWeight: 700, marginTop: 16 }}>
            Display name only
          </label>

          <input
            aria-label="Display name only"
            value={displayName}
            onChange={(event) => setDisplayName(event.target.value)}
            maxLength={32}
            style={{ width: "100%", padding: 12, border: "1px solid #cbd5e1", borderRadius: 12, marginTop: 6 }}
          />

          <fieldset style={{ border: "1px solid #cbd5e1", borderRadius: 12, padding: 14, marginTop: 18 }}>
            <legend style={{ fontWeight: 700 }}>Required age category selection</legend>

            {AGE_CATEGORIES.map((category) => (
              <label key={category} style={{ display: "block", margin: "8px 0" }}>
                <input
                  type="radio"
                  name="ageCategory"
                  value={category}
                  checked={selectedAgeCategory === category}
                  onChange={() => setSelectedAgeCategory(category)}
                />{" "}
                {category}
              </label>
            ))}
          </fieldset>

          <p>
            No default age category is assigned before selection.
            Kids category does not require email, exact age, date of birth, or real name.
          </p>

          <div style={{ display: "flex", gap: 12, flexWrap: "wrap", marginTop: 20 }}>
            <button
              onClick={saveProfile}
              disabled={!canCreate}
              style={{ padding: "12px 16px", borderRadius: 12, border: 0, background: canCreate ? "#2563eb" : "#94a3b8", color: "#ffffff", fontWeight: 700 }}
            >
              Create Local Profile
            </button>

            <button
              onClick={() => setGuestMode(true)}
              style={{ padding: "12px 16px", borderRadius: 12, border: "1px solid #cbd5e1", background: "#ffffff", fontWeight: 700 }}
            >
              Continue as Guest
            </button>
          </div>

          <p style={{ marginTop: 18 }}>
            <a href="/MindLab_Starter_Project/privacy.html">Privacy Policy</a>
            {" | "}
            <a href="/MindLab_Starter_Project/support.html">Support</a>
          </p>
        </section>
      </main>
    );
  }

  return (
    <>
      <div style={{ background: "#e0f2fe", color: "#0f172a", padding: "10px 16px", fontFamily: "Arial, Helvetica, sans-serif", display: "flex", justifyContent: "space-between", gap: 12, flexWrap: "wrap" }}>
        <strong>MindLab Profile: {activeModeLabel}</strong>

        <button
          onClick={resetProfile}
          style={{ border: "1px solid #0369a1", background: "#ffffff", borderRadius: 999, padding: "6px 10px", fontWeight: 700 }}
        >
          Delete / Reset Local Profile
        </button>
      </div>

      {children}
    </>
  );
}
