import { adultsAgeMode } from './adultsAgeMode';

export const ageModeRegistry = {
  adults: adultsAgeMode,
} as const;

export type AgeModeKey = keyof typeof ageModeRegistry;
export type AgeModeRegistry = typeof ageModeRegistry;

export function getAgeModeConfig(ageMode: AgeModeKey) {
  return ageModeRegistry[ageMode];
}

export function getAvailableAgeModes(): AgeModeKey[] {
  return Object.keys(ageModeRegistry) as AgeModeKey[];
}
