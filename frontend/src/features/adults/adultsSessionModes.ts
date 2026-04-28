export type AdultsSessionModeId = "QuickFocus" | "Standard" | "Deep" | "Recovery";

export type AdultsSessionMode = {
  id: AdultsSessionModeId;
  label: string;
  duration: string;
  intent: string;
  description: string;
  cognitiveLoad: string;
  timerDefault: string;
  hintStyle: string;
};

export const adultsSessionModes: AdultsSessionMode[] = [
  {
    id: "QuickFocus",
    label: "Quick Focus",
    duration: "3-5 min",
    intent: "Short focused adult session",
    description: "A short focused session for a clear mental reset.",
    cognitiveLoad: "Low to moderate",
    timerDefault: "Optional",
    hintStyle: "Light nudge"
  },
  {
    id: "Standard",
    label: "Standard",
    duration: "8-12 min",
    intent: "Balanced training session",
    description: "A balanced session for steady adult cognitive training.",
    cognitiveLoad: "Moderate",
    timerDefault: "Optional",
    hintStyle: "Layered hints"
  },
  {
    id: "Deep",
    label: "Deep",
    duration: "15-25 min",
    intent: "Longer reasoning and mastery session",
    description: "A longer session for strategy, reasoning, and mastery.",
    cognitiveLoad: "Moderate to high",
    timerDefault: "Off by default",
    hintStyle: "Strategy cue, then structure cue"
  },
  {
    id: "Recovery",
    label: "Recovery",
    duration: "3-8 min",
    intent: "Calm low-pressure session after friction or fatigue",
    description: "A calm lower-pressure session when you want a lighter path.",
    cognitiveLoad: "Low",
    timerDefault: "Off",
    hintStyle: "Supportive stepwise hints"
  }
];

export const defaultAdultsSessionMode: AdultsSessionModeId = "QuickFocus";

export function getDefaultAdultsSessionMode(): AdultsSessionMode {
  return adultsSessionModes.find((mode) => mode.id === defaultAdultsSessionMode) ?? adultsSessionModes[0];
}
