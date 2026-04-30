import { getAgeModeConfig, getAvailableAgeModes, type AgeModeKey } from './ageModeRegistry';

export const defaultAppFlowAgeMode: AgeModeKey = 'adults';

export function resolveAppFlowAgeMode(requestedAgeMode?: AgeModeKey) {
  const availableAgeModes = getAvailableAgeModes();
  const selectedAgeMode = requestedAgeMode && availableAgeModes.includes(requestedAgeMode)
    ? requestedAgeMode
    : defaultAppFlowAgeMode;

  return {
    selectedAgeMode,
    availableAgeModes,
    config: getAgeModeConfig(selectedAgeMode),
  };
}
