import type { SeniorsSessionModeId } from "./seniorsSessionModes";

export type SeniorsGameplayItem = {
  challengeId: string;
  category: string;
  categoryName: string;
  stage: string;
  sessionProfile: SeniorsSessionModeId;
  objective: string;
  prompt: string;
  options: string[];
  correctAnswer: string;
  hint: string;
  insight: string;
};

export const seniorsGameplayItems: SeniorsGameplayItem[] = [
  {
    challengeId: "S-MEM-S1-001",
    category: "memory_support",
    categoryName: "Memory Support",
    stage: "S1",
    sessionProfile: "GuidedMemory",
    objective: "Hold a short three-item sequence and recall one position",
    prompt: "Remember these three words in order: garden, key, lamp. Which word was second?",
    options: ["Garden", "Key", "Lamp", "Window"],
    correctAnswer: "Key",
    hint: "Repeat the three words slowly in the same order.",
    insight: "Breaking information into a short sequence can make recall easier."
  },
  {
    challengeId: "S-MEM-S1-002",
    category: "memory_support",
    categoryName: "Memory Support",
    stage: "S1",
    sessionProfile: "GuidedMemory",
    objective: "Recall a simple appointment sequence",
    prompt: "Remember: pharmacy at 10, call Maria at 12, walk at 3. What comes after the call to Maria?",
    options: ["Pharmacy", "Walk", "Breakfast", "Mail"],
    correctAnswer: "Walk",
    hint: "Read the three activities from earliest to latest.",
    insight: "Linking events to a simple order supports everyday memory."
  },
  {
    challengeId: "S-MEM-S2-003",
    category: "memory_support",
    categoryName: "Memory Support",
    stage: "S2",
    sessionProfile: "GuidedMemory",
    objective: "Retain a short mapping and use it once",
    prompt: "Remember: blue folder = bills, green folder = letters, red folder = photos. Where are the letters?",
    options: ["Blue folder", "Green folder", "Red folder", "No folder"],
    correctAnswer: "Green folder",
    hint: "Recall the color paired with letters.",
    insight: "Simple associations can reduce the effort needed to retrieve information."
  },
  {
    challengeId: "S-FOC-S1-001",
    category: "focus_attention",
    categoryName: "Focus & Attention",
    stage: "S1",
    sessionProfile: "FocusAttention",
    objective: "Apply one clear selection rule",
    prompt: "Choose the appointment that is on Tuesday morning.",
    options: ["Monday at 2 PM", "Tuesday at 9 AM", "Tuesday at 4 PM", "Wednesday at 9 AM"],
    correctAnswer: "Tuesday at 9 AM",
    hint: "Match both the day and the time of day.",
    insight: "Holding one clear rule helps attention stay focused on relevant details."
  },
  {
    challengeId: "S-FOC-S1-002",
    category: "focus_attention",
    categoryName: "Focus & Attention",
    stage: "S1",
    sessionProfile: "FocusAttention",
    objective: "Notice a small difference between similar choices",
    prompt: "Which code exactly matches: B7K4?",
    options: ["B7K4", "B7K9", "B4K7", "B7R4"],
    correctAnswer: "B7K4",
    hint: "Compare one character at a time from left to right.",
    insight: "Slow comparison can improve accuracy when choices look very similar."
  },
  {
    challengeId: "S-FOC-S2-003",
    category: "focus_attention",
    categoryName: "Focus & Attention",
    stage: "S2",
    sessionProfile: "FocusAttention",
    objective: "Apply two simple conditions without rushing",
    prompt: "A reminder should be marked only if it is both today and unfinished. Which reminder should be marked?",
    options: [
      "Today, unfinished",
      "Today, finished",
      "Tomorrow, unfinished",
      "Yesterday, finished"
    ],
    correctAnswer: "Today, unfinished",
    hint: "Both conditions must be true at the same time.",
    insight: "Checking each condition separately can make a combined rule easier to apply."
  },
  {
    challengeId: "S-PAT-S1-001",
    category: "pattern_recognition",
    categoryName: "Pattern Confidence",
    stage: "S1",
    sessionProfile: "PatternConfidence",
    objective: "Recognize a steady numerical pattern",
    prompt: "What comes next: 3, 6, 9, 12, ?",
    options: ["13", "14", "15", "18"],
    correctAnswer: "15",
    hint: "The same amount is added each time.",
    insight: "Recognizing a repeated change builds confidence with number patterns."
  },
  {
    challengeId: "S-PAT-S1-002",
    category: "pattern_recognition",
    categoryName: "Pattern Confidence",
    stage: "S1",
    sessionProfile: "PatternConfidence",
    objective: "Recognize an alternating pattern",
    prompt: "The pattern is circle, square, circle, square. What comes next?",
    options: ["Circle", "Square", "Triangle", "Star"],
    correctAnswer: "Circle",
    hint: "The two shapes take turns.",
    insight: "Alternating patterns become easier when you identify the repeating pair."
  },
  {
    challengeId: "S-PAT-S2-003",
    category: "pattern_recognition",
    categoryName: "Pattern Confidence",
    stage: "S2",
    sessionProfile: "PatternConfidence",
    objective: "Recognize a gradually changing number pattern",
    prompt: "What comes next: 5, 8, 12, 17, ?",
    options: ["21", "22", "23", "24"],
    correctAnswer: "23",
    hint: "The increases are 3, then 4, then 5.",
    insight: "Looking at the change between values can reveal a pattern that is not obvious at first."
  },
  {
    challengeId: "S-CALM-S1-001",
    category: "calm_review",
    categoryName: "Calm Review",
    stage: "S1",
    sessionProfile: "CalmReview",
    objective: "Use a familiar everyday concept",
    prompt: "Which item is most useful for checking the time?",
    options: ["Clock", "Plate", "Pillow", "Book"],
    correctAnswer: "Clock",
    hint: "Choose the item designed to show hours and minutes.",
    insight: "A familiar question can provide a comfortable reset before a stronger challenge."
  },
  {
    challengeId: "S-CALM-S1-002",
    category: "calm_review",
    categoryName: "Calm Review",
    stage: "S1",
    sessionProfile: "CalmReview",
    objective: "Choose a word with the same meaning",
    prompt: "Which word is closest in meaning to calm?",
    options: ["Peaceful", "Loud", "Sharp", "Rapid"],
    correctAnswer: "Peaceful",
    hint: "Think of a word that describes a quiet, settled feeling.",
    insight: "Familiar language review supports confidence without adding pressure."
  },
  {
    challengeId: "S-CALM-S2-003",
    category: "calm_review",
    categoryName: "Calm Review",
    stage: "S2",
    sessionProfile: "CalmReview",
    objective: "Choose a practical organization step",
    prompt: "Which action is most helpful for remembering several tasks during the day?",
    options: ["Make a short list", "Ignore the tasks", "Change the plan repeatedly", "Rely on guessing"],
    correctAnswer: "Make a short list",
    hint: "Choose the action that keeps the tasks visible and organized.",
    insight: "Simple external supports can reduce memory load and make daily planning easier."
  }
];

export function getSeniorsGameplayItemsForSession(
  sessionProfile: SeniorsSessionModeId
): SeniorsGameplayItem[] {
  return seniorsGameplayItems.filter((item) => item.sessionProfile === sessionProfile);
}
