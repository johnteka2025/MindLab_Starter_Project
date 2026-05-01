export const seniorsGameplayAccessibilityProgress = {
  integrationStatus: 'gameplay_accessibility_progress_ready_for_validation',
  gameplayLoop: [
    'start_guided_memory_prompt',
    'complete_focus_attention_step',
    'recognize_pattern_with_support',
    'review_confidence_milestone',
    'replay_for_comfortable_mastery',
  ],
  accessibilitySupports: [
    'larger_readable_text',
    'clear_plain_labels',
    'reduced_visual_clutter',
    'low_pressure_guided_pacing',
    'respectful_encouraging_copy',
  ],
  progressMilestones: [
    { id: 'memory-support', label: 'Memory Support', target: 'start_guided_memory_prompt' },
    { id: 'focus-attention', label: 'Focus Attention', target: 'complete_focus_attention_step' },
    { id: 'pattern-confidence', label: 'Pattern Confidence', target: 'recognize_pattern_with_support' },
    { id: 'steady-progress', label: 'Steady Progress', target: 'review_confidence_milestone' },
    { id: 'comfortable-mastery', label: 'Comfortable Mastery', target: 'replay_for_comfortable_mastery' },
  ],
  progressSummary:
    'Seniors progress emphasizes confidence milestones, consistency, guided replay, and comfortable mastery without pressure.',
} as const;

export type SeniorsGameplayAccessibilityProgress = typeof seniorsGameplayAccessibilityProgress;
