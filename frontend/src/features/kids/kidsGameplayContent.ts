import type { KidsSessionModeId } from "./kidsSessionModes";

export type KidsGameplayItem = {
  certifiedId: string;
  category: string;
  categoryName: string;
  stage: string;
  sessionMode: KidsSessionModeId;
  prompt: string;
  options: string[];
  correctAnswer: string;
  hint: string;
  insight: string;
  difficulty: string;
};

export const kidsGameplayItems: KidsGameplayItem[] = [
  {
    certifiedId: "K-KC01-K1-P01",
    category: "KC1",
    categoryName: "Colors and Attention",
    stage: "K1",
    sessionMode: "PlayFocus",
    prompt: "Which one is red?",
    options: ["Red", "Leaf", "Dog"],
    correctAnswer: "Red",
    hint: "Look for the color word.",
    insight: "Great noticing. Red is the color word.",
    difficulty: "Starter"
  },
  {
    certifiedId: "K-KC02-K1-P02",
    category: "KC2",
    categoryName: "Shapes and Matching",
    stage: "K1",
    sessionMode: "PlayFocus",
    prompt: "Which shape has three sides?",
    options: ["Triangle", "Circle", "Square"],
    correctAnswer: "Triangle",
    hint: "Count the sides.",
    insight: "A triangle has three sides.",
    difficulty: "Starter"
  },
  {
    certifiedId: "K-KC03-K1-P03",
    category: "KC3",
    categoryName: "Story Understanding",
    stage: "K1",
    sessionMode: "StoryPractice",
    prompt: "Mia put on boots because it was raining. Why did Mia wear boots?",
    options: ["To keep feet dry", "To swim", "To sleep"],
    correctAnswer: "To keep feet dry",
    hint: "Think about rain.",
    insight: "Boots help keep feet dry in rain.",
    difficulty: "Starter"
  },
  {
    certifiedId: "K-KC04-K2-P04",
    category: "KC4",
    categoryName: "Simple Patterns",
    stage: "K2",
    sessionMode: "Challenge",
    prompt: "What comes next: star, moon, star, moon, star, ?",
    options: ["Moon", "Star", "Sun"],
    correctAnswer: "Moon",
    hint: "The pattern repeats.",
    insight: "The pattern is star then moon.",
    difficulty: "Early Challenge"
  },
  {
    certifiedId: "K-KC05-K1-P05",
    category: "KC5",
    categoryName: "Calm Review",
    stage: "K1",
    sessionMode: "CalmReview",
    prompt: "Which answer is an animal?",
    options: ["Dog", "Table", "Blue"],
    correctAnswer: "Dog",
    hint: "An animal can move and breathe.",
    insight: "Dog is an animal.",
    difficulty: "Review"
  }
];

export const defaultKidsGameplayItemId = "K-KC01-K1-P01";

export function getKidsGameplayItemById(certifiedId: string): KidsGameplayItem {
  return kidsGameplayItems.find((item) => item.certifiedId === certifiedId) ?? kidsGameplayItems[0]!;
}

export function getKidsGameplayItemsForSession(sessionMode: string): KidsGameplayItem[] {
  return kidsGameplayItems.filter((item) => item.sessionMode === sessionMode);
}

export function getDefaultKidsGameplayItemForSession(sessionMode: string): KidsGameplayItem {
  const items = getKidsGameplayItemsForSession(sessionMode);
  return items[0] ?? getKidsGameplayItemById(defaultKidsGameplayItemId);
}
