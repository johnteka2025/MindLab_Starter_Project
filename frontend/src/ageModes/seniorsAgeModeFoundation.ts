export const seniorsAgeModeFoundation = {
  ageModeKey: 'seniors',
  ageModeLabel: 'Seniors Mode',
  foundationStatus: 'foundation_ready_for_validation',
  cognitiveGoal: 'memory_support_focus_attention_pattern_recognition',
  pacingModel: 'slower_guided_low_pressure_progression',
  accessibilityModel: 'larger_text_clear_labels_high_readability_reduced_clutter',
  difficultyModel: 'adaptive_gentle_ramp_with_optional_challenge',
  progressModel: 'confidence_milestones_consistency_streaks_and_replay_mastery',
  uxTone: 'encouraging_clear_respectful_non_childlike',
  separationRule: 'separate_from_adults_and_kids',
  foundationPillars: [
    'memory_support',
    'focus_attention',
    'pattern_recognition',
    'guided_progression',
    'readable_accessibility',
    'confidence_milestones',
  ],
  validationTags: [
    'seniors_foundation_ready',
    'seniors_separate_lane',
    'seniors_accessibility_ready',
  ],
} as const;

export type SeniorsAgeModeFoundation = typeof seniorsAgeModeFoundation;
