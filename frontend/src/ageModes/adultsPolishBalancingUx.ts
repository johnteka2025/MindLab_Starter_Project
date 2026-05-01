export const adultsPolishBalancingUx = {
  polishStatus: 'production_ready_polish_pass',
  uxCopy: {
    eyebrow: 'Adults Mode',
    headline: 'Strategic cognitive challenge',
    helperText:
      'Balance focus, memory, strategy, adaptive challenge, and replay mastery through a clearer Adults experience.',
  },
  balanceTuning: {
    startingDifficulty: 'focused_adult_baseline',
    adaptiveRamp: 'steady_skill_growth',
    masteryTarget: 'replayable_progression',
  },
  accessibility: {
    panelLabel: 'Adults mode active',
    progressLabel: 'Adults depth milestones',
    gameplayLabel: 'Adults gameplay loop',
  },
  validationTags: [
    'adults_polish_ready',
    'adults_balancing_ready',
    'adults_ux_ready',
  ],
} as const;

export type AdultsPolishBalancingUx = typeof adultsPolishBalancingUx;
