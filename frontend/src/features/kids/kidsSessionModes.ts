export type KidsSessionModeId = "PlayFocus" | "StoryPractice" | "Challenge" | "CalmReview";

export type KidsSessionMode = {
  id: KidsSessionModeId;
  label: string;
  duration: string;
  cognitiveLoad: string;
  purpose: string;
  hintStyle: string;
  defaultMode: boolean;
  childSafety: string;
};

export const kidsSessionModes: KidsSessionMode[] = [
  {
    id: "PlayFocus",
    label: "Play Focus",
    duration: "3-5 min",
    cognitiveLoad: "Low",
    purpose: "Short playful attention practice",
    hintStyle: "Gentle clue",
    defaultMode: true,
    childSafety: "Low pressure"
  },
  {
    id: "StoryPractice",
    label: "Story Practice",
    duration: "5-8 min",
    cognitiveLoad: "Low to moderate",
    purpose: "Language and meaning practice",
    hintStyle: "Story clue",
    defaultMode: false,
    childSafety: "Encouraging"
  },
  {
    id: "Challenge",
    label: "Challenge",
    duration: "5-10 min",
    cognitiveLoad: "Moderate",
    purpose: "Optional stronger puzzle practice",
    hintStyle: "Step clue",
    defaultMode: false,
    childSafety: "No penalty language"
  },
  {
    id: "CalmReview",
    label: "Calm Review",
    duration: "3-6 min",
    cognitiveLoad: "Low",
    purpose: "Recovery-style review after mistakes",
    hintStyle: "Supportive step",
    defaultMode: false,
    childSafety: "Calm and supportive"
  }
];

export const defaultKidsSessionMode: KidsSessionModeId = "PlayFocus";

export function getDefaultKidsSessionMode(): KidsSessionMode {
  return kidsSessionModes.find((mode) => mode.defaultMode) ?? kidsSessionModes[0]!;
}
