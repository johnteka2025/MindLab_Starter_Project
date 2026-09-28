export type SeniorsSessionModeId =
  | "GuidedMemory"
  | "FocusAttention"
  | "PatternConfidence"
  | "CalmReview";

export type SeniorsSessionMode = {
  id: SeniorsSessionModeId;
  label: string;
  duration: string;
  intent: string;
  description: string;
  supportStyle: string;
};

export const seniorsSessionModes: SeniorsSessionMode[] = [
  {
    id: "GuidedMemory",
    label: "Guided Memory",
    duration: "4-7 min",
    intent: "Practice short, manageable memory steps",
    description: "Use clear prompts and familiar information to support steady recall.",
    supportStyle: "Guided and reassuring"
  },
  {
    id: "FocusAttention",
    label: "Focus & Attention",
    duration: "4-7 min",
    intent: "Practice careful attention without rushing",
    description: "Use one clear rule at a time to strengthen focus and accurate selection.",
    supportStyle: "Clear and unhurried"
  },
  {
    id: "PatternConfidence",
    label: "Pattern Confidence",
    duration: "5-8 min",
    intent: "Practice patterns with a gentle difficulty ramp",
    description: "Recognize useful number, sequence, and relationship patterns at a comfortable pace.",
    supportStyle: "Steady challenge"
  },
  {
    id: "CalmReview",
    label: "Calm Review",
    duration: "3-6 min",
    intent: "Rebuild confidence with familiar reasoning",
    description: "Use supportive review when you want a lighter session with clear steps.",
    supportStyle: "Calm and supportive"
  }
];

export const defaultSeniorsSessionMode: SeniorsSessionModeId = "GuidedMemory";
