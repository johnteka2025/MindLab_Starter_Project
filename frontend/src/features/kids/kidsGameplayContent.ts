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
  },
  {
    certifiedId: "K-KC06-K1-P06",
    category: "KC6",
    categoryName: "Memory and Sequencing",
    stage: "K1",
    sessionMode: "PlayFocus",
    prompt: "Remember the order: sun, moon. What came first?",
    options: ["Sun", "Moon", "Star"],
    correctAnswer: "Sun",
    hint: "Say the order again slowly.",
    insight: "Sun came first in the order.",
    difficulty: "Starter"
  },
  {
    certifiedId: "K-KC06-K2-P07",
    category: "KC6",
    categoryName: "Memory and Sequencing",
    stage: "K2",
    sessionMode: "Challenge",
    prompt: "Remember the order: apple, ball, cup. What came after apple?",
    options: ["Ball", "Cup", "Apple"],
    correctAnswer: "Ball",
    hint: "Think about the second item.",
    insight: "Ball came after apple.",
    difficulty: "Builder"
  },
  {
    certifiedId: "K-KC07-K1-P08",
    category: "KC7",
    categoryName: "Early Reasoning",
    stage: "K1",
    sessionMode: "StoryPractice",
    prompt: "Sam has a wet umbrella. What probably happened?",
    options: ["It rained", "It snowed inside", "The sun was hot"],
    correctAnswer: "It rained",
    hint: "Umbrellas help when water falls from the sky.",
    insight: "A wet umbrella is a clue that it rained.",
    difficulty: "Starter"
  },
  {
    certifiedId: "K-KC07-K2-P09",
    category: "KC7",
    categoryName: "Early Reasoning",
    stage: "K2",
    sessionMode: "Challenge",
    prompt: "A toy car has no wheels. What will be hard for it to do?",
    options: ["Roll", "Smile", "Sleep"],
    correctAnswer: "Roll",
    hint: "Wheels help things move along the floor.",
    insight: "A car needs wheels to roll.",
    difficulty: "Solver"
  },
  {
    certifiedId: "K-KC08-K1-P10",
    category: "KC8",
    categoryName: "Visual Attention",
    stage: "K1",
    sessionMode: "PlayFocus",
    prompt: "Find the thing that can fly.",
    options: ["Bird", "Chair", "Shoe"],
    correctAnswer: "Bird",
    hint: "Look for the living thing with wings.",
    insight: "A bird can fly.",
    difficulty: "Starter"
  },
  {
    certifiedId: "K-KC08-K2-P11",
    category: "KC8",
    categoryName: "Visual Attention",
    stage: "K2",
    sessionMode: "Challenge",
    prompt: "Which one does not belong with fruits?",
    options: ["Carrot", "Apple", "Banana"],
    correctAnswer: "Carrot",
    hint: "Look for the one that is usually a vegetable.",
    insight: "Carrot does not belong with apple and banana.",
    difficulty: "Builder"
  },
  {
    certifiedId: "K-KC09-K1-P12",
    category: "KC9",
    categoryName: "Language Meaning",
    stage: "K1",
    sessionMode: "StoryPractice",
    prompt: "Which item do you use to write?",
    options: ["Pencil", "Pillow", "Plate"],
    correctAnswer: "Pencil",
    hint: "Think about what makes marks on paper.",
    insight: "A pencil is used to write.",
    difficulty: "Starter"
  },
  {
    certifiedId: "K-KC09-K2-P13",
    category: "KC9",
    categoryName: "Language Meaning",
    stage: "K2",
    sessionMode: "StoryPractice",
    prompt: "Lena whispered because the baby was sleeping. Why did Lena whisper?",
    options: ["To stay quiet", "To run fast", "To eat lunch"],
    correctAnswer: "To stay quiet",
    hint: "Sleeping babies need quiet.",
    insight: "Whispering helps keep the room quiet.",
    difficulty: "Solver"
  },
  {
    certifiedId: "K-KC10-K1-P14",
    category: "KC10",
    categoryName: "Calm Review",
    stage: "K1",
    sessionMode: "CalmReview",
    prompt: "Take a calm review step. Which answer is a color?",
    options: ["Blue", "Jump", "Table"],
    correctAnswer: "Blue",
    hint: "A color tells how something looks.",
    insight: "Blue is a color.",
    difficulty: "Review"
  },
  {
    certifiedId: "K-KC10-K2-P15",
    category: "KC10",
    categoryName: "Calm Review",
    stage: "K2",
    sessionMode: "CalmReview",
    prompt: "Which choice shows a calm next step after a mistake?",
    options: ["Try again slowly", "Throw the game", "Stop learning forever"],
    correctAnswer: "Try again slowly",
    hint: "Choose the kind and helpful action.",
    insight: "Trying again slowly is a calm learning step.",
    difficulty: "Review"
  },
  {
    certifiedId: "K-KC06-K3-P16",
    category: "KC6",
    categoryName: "Memory and Sequencing",
    stage: "K3",
    sessionMode: "Challenge",
    prompt: "Remember: red, blue, green. Which color was last?",
    options: ["Green", "Red", "Blue"],
    correctAnswer: "Green",
    hint: "Last means the final item in the order.",
    insight: "Green was last in the sequence.",
    difficulty: "Explorer"
  },
  {
    certifiedId: "K-KC07-K3-P17",
    category: "KC7",
    categoryName: "Early Reasoning",
    stage: "K3",
    sessionMode: "Challenge",
    prompt: "The plant is drooping and the soil is dry. What does it likely need?",
    options: ["Water", "A blanket", "A pencil"],
    correctAnswer: "Water",
    hint: "Dry soil is a clue.",
    insight: "A drooping plant with dry soil likely needs water.",
    difficulty: "Builder"
  },
  {
    certifiedId: "K-KC08-K3-P18",
    category: "KC8",
    categoryName: "Visual Attention",
    stage: "K3",
    sessionMode: "Challenge",
    prompt: "Which pair matches by use?",
    options: ["Key and lock", "Sock and spoon", "Book and ball"],
    correctAnswer: "Key and lock",
    hint: "Think about two things that work together.",
    insight: "A key and a lock work together.",
    difficulty: "Solver"
  },
  {
    certifiedId: "K-KC09-K3-P19",
    category: "KC9",
    categoryName: "Language Meaning",
    stage: "K3",
    sessionMode: "StoryPractice",
    prompt: "A chef stirs soup in a pot. What is the chef doing?",
    options: ["Cooking", "Sleeping", "Painting"],
    correctAnswer: "Cooking",
    hint: "Soup in a pot is made in the kitchen.",
    insight: "The chef is cooking soup.",
    difficulty: "Builder"
  },
  {
    certifiedId: "K-KC10-K3-P20",
    category: "KC10",
    categoryName: "Calm Review",
    stage: "K3",
    sessionMode: "CalmReview",
    prompt: "Which sentence is kind self-talk?",
    options: ["I can try one more time", "I am bad at everything", "Learning is never possible"],
    correctAnswer: "I can try one more time",
    hint: "Kind self-talk helps you keep learning.",
    insight: "I can try one more time is kind and helpful.",
    difficulty: "Mastery Spark"
  }
];

export const defaultKidsGameplayItemId = "K-KC01-K1-P01";

export const kidsExpansionCategoryIds = ["KC6", "KC7", "KC8", "KC9", "KC10"] as const;

export const kidsExceptionalLevelLabels = ["Explorer", "Builder", "Solver", "Mastery Spark"] as const;

export function getKidsGameplayItemById(certifiedId: string): KidsGameplayItem {
  return kidsGameplayItems.find((item) => item.certifiedId === certifiedId) ?? kidsGameplayItems[0]!;
}

export function getKidsGameplayItemsForSession(sessionMode: string): KidsGameplayItem[] {
  return kidsGameplayItems.filter((item) => item.sessionMode === sessionMode);
}

export function getKidsGameplayItemsForCategory(category: string): KidsGameplayItem[] {
  return kidsGameplayItems.filter((item) => item.category === category);
}

export function getKidsExpansionGameplayItems(): KidsGameplayItem[] {
  return kidsGameplayItems.filter((item) => kidsExpansionCategoryIds.includes(item.category as typeof kidsExpansionCategoryIds[number]));
}

export function getDefaultKidsGameplayItemForSession(sessionMode: string): KidsGameplayItem {
  const items = getKidsGameplayItemsForSession(sessionMode);
  return items[0] ?? getKidsGameplayItemById(defaultKidsGameplayItemId);
}
