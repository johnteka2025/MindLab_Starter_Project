export const adultsGameplayRouting = {
  routeKey: 'adults',
  routeLabel: 'Adults Mode',
  entryTitle: 'Strategic cognitive challenge',
  entryDescription:
    'Train focus, memory, strategy, and adaptive decision-making through replayable Adults challenges.',
  gameplayLoop: [
    'choose_strategy',
    'complete_focus_challenge',
    'review_memory_result',
    'increase_adaptive_difficulty',
    'replay_for_mastery',
  ],
  validationTags: [
    'adults_mode',
    'gameplay_ready',
    'routing_ready',
  ],
} as const;

export type AdultsGameplayRouting = typeof adultsGameplayRouting;
