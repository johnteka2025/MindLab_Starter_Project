export const adultsGameplayDepthProgress = {
  progressionModel: 'adult_depth_progression',
  scoringSignals: [
    'strategy_accuracy',
    'focus_completion',
    'memory_streak',
    'adaptive_difficulty_level',
    'replay_mastery',
  ],
  depthMilestones: [
    {
      id: 'focus-foundation',
      label: 'Focus Foundation',
      target: 'complete_focus_challenge',
    },
    {
      id: 'strategy-builder',
      label: 'Strategy Builder',
      target: 'choose_strategy',
    },
    {
      id: 'memory-review',
      label: 'Memory Review',
      target: 'review_memory_result',
    },
    {
      id: 'adaptive-growth',
      label: 'Adaptive Growth',
      target: 'increase_adaptive_difficulty',
    },
    {
      id: 'mastery-replay',
      label: 'Mastery Replay',
      target: 'replay_for_mastery',
    },
  ],
  progressSummary:
    'Adults progress tracks focus completion, strategy accuracy, memory streaks, adaptive difficulty, and replay mastery.',
} as const;

export type AdultsGameplayDepthProgress = typeof adultsGameplayDepthProgress;
