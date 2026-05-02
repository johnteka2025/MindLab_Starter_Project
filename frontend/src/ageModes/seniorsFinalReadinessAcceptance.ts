export type SeniorsFinalReadinessAcceptanceItem = {
  id: string;
  gate: string;
  acceptanceRule: string;
  requiredEvidence: string;
  status: 'ready' | 'accepted' | 'deferred';
};

export const seniorsFinalReadinessAcceptance: SeniorsFinalReadinessAcceptanceItem[] = [
  {
    id: 'SFR-001',
    gate: 'Accessibility and comfort gate',
    acceptanceRule: 'Seniors experience must remain readable, calm, respectful, and recovery-safe.',
    requiredEvidence: 'Seniors accessibility, gameplay progress, PBUX, and validation evidence.',
    status: 'ready',
  },
  {
    id: 'SFR-002',
    gate: 'Gameplay readiness gate',
    acceptanceRule: 'Seniors lane must support mastery, pacing, replay familiarity, and confidence-oriented completion.',
    requiredEvidence: 'Gameplay/accessibility/progress plus PBUX closeout artifacts.',
    status: 'ready',
  },
  {
    id: 'SFR-003',
    gate: 'Release transition gate',
    acceptanceRule: 'Seniors baseline can transition to whole-game finalization only after validation and clean repository checks pass.',
    requiredEvidence: 'Frontend validation logs, clean git status, final readiness closeout, and transition checklist.',
    status: 'ready',
  },
];

export const seniorsFinalReadinessAcceptanceSummary = {
  lane: 'Seniors final readiness and acceptance',
  status: 'ready_for_validation',
  nextGate: 'Whole-game finalization',
} as const;
