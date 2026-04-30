export const adultsAgeMode = {
  ageCategory: 'Adults',
  status: 'BASELINE_READY',
  coreTheme: 'Strategic cognitive challenge',
  gameplayPillars: [
    'strategy',
    'focus',
    'memory',
    'adaptive_challenge',
    'replayability',
  ],
  difficultyModel: 'adaptive_adult_progression',
  marketPosition: 'adult_brain_training_and_productivity_adjacent_play',
  boundaries: {
    doNotRepeatKidsCreation: true,
    doNotCombineSeniors: true,
    adultsOnly: true,
  },
} as const;

export type AdultsAgeMode = typeof adultsAgeMode;
