import { resolveAppFlowAgeMode } from './appFlowAgeModes';

export function AdultsModeVisiblePanel() {
  const { selectedAgeMode, config } = resolveAppFlowAgeMode('adults');

  return (
    <section
      data-testid="adults-mode-visible-panel"
      aria-label="Adults mode active"
      style={{
        border: '1px solid #d1d5db',
        borderRadius: '12px',
        padding: '12px',
        margin: '12px',
      }}
    >
      <strong>Adults Mode Active</strong>
      <div>Selected age mode: {selectedAgeMode}</div>
      <div>Theme: {config.coreTheme}</div>
      <div>Difficulty: {config.difficultyModel}</div>
    </section>
  );
}
