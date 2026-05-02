export type SeniorsPolishBalancingUxItem = {
  id: string;
  title: string;
  purpose: string;
  playerBenefit: string;
  implementationStatus: 'ready' | 'active' | 'validated';
};

export const seniorsPolishBalancingUx: SeniorsPolishBalancingUxItem[] = [
  {
    id: 'PBUX-001',
    title: 'Calm mastery pacing',
    purpose: 'Keep Seniors gameplay respectful, readable, and confidence-oriented without removing challenge quality.',
    playerBenefit: 'Players can progress with lower friction, clearer feedback, and stable decision rhythm.',
    implementationStatus: 'active',
  },
  {
    id: 'PBUX-002',
    title: 'Comfort-first balancing',
    purpose: 'Balance challenge escalation with generous timing, readable prompts, and recovery-safe retry loops.',
    playerBenefit: 'Players remain challenged without feeling rushed or punished.',
    implementationStatus: 'active',
  },
  {
    id: 'PBUX-003',
    title: 'Accessible UX confirmation',
    purpose: 'Preserve visible support for larger text, clear contrast, concise steps, and predictable navigation.',
    playerBenefit: 'Players can understand choices quickly and recover from mistakes confidently.',
    implementationStatus: 'active',
  },
  {
    id: 'PBUX-004',
    title: 'Replay familiarity loop',
    purpose: 'Support replay through familiar patterns, gentle variation, and skill reinforcement.',
    playerBenefit: 'Players can return to the game and rebuild confidence without relearning the interface.',
    implementationStatus: 'ready',
  },
];

export const seniorsPolishBalancingUxSummary = {
  lane: 'Seniors polish, balancing, and UX',
  status: 'active',
  nextGate: 'Seniors final readiness and acceptance',
} as const;
