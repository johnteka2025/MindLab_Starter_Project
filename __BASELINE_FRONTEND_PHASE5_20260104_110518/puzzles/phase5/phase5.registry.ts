// frontend/src/puzzles/phase5/phase5.registry.ts
// Phase 5: Game expansion puzzles.
// Golden rule: puzzleId must be stable and never change once released.

export type Puzzle = {
  id: string;
  question: string;
  answer: string;
  category?: string;
};

export const PHASE5_PUZZLES: Puzzle[] = [
  {
    id: "p5-logic-01",
    question: "What number comes next: 2, 4, 8, 16, ?",
    answer: "32",
    category: "Logic",
  },
  {
    id: "p5-geo-01",
    question: "What is the capital of Japan?",
    answer: "Tokyo",
    category: "Geography",
  },
  {
    id: "p5-word-01",
    question: "Unscramble the word: LPAEPP",
    answer: "APPLE",
    category: "Word",
  },
];
