import { resolveAppFlowAgeMode } from './appFlowAgeModes';

export function AdultsModeVisiblePanel() {
  const { selectedAgeMode, config } = resolveAppFlowAgeMode('adults');
  const pillars = config.gameplayPillars;

  return (
    <section
      data-testid="adults-mode-visible-panel"
      aria-label="Adults mode active"
      style={{
        border: '1px solid #d1d5db',
        borderRadius: '16px',
        padding: '16px',
        margin: '16px',
        background: '#ffffff',
      }}
    >
      <p style={{ margin: 0, fontSize: '12px', fontWeight: 700, letterSpacing: '0.08em', textTransform: 'uppercase' }}>
        Adults Mode
      </p>
      <h2 style={{ margin: '6px 0 8px' }}>Strategic cognitive challenge</h2>
      <p style={{ margin: '0 0 12px' }}>
        Focus, memory, strategy, adaptive challenge, and replayability are active for the selected Adults experience.
      </p>
      <div data-testid="adults-mode-selected-key">Selected age mode: {selectedAgeMode}</div>
      <div data-testid="adults-mode-theme">Theme: {config.coreTheme}</div>
      <div data-testid="adults-mode-difficulty">Difficulty: {config.difficultyModel}</div>
      <ul aria-label="Adults gameplay pillars">
        {pillars.map((pillar) => (
          <li key={pillar}>{pillar.replaceAll('_', ' ')}</li>
        ))}
      </ul>
    </section>
  );
}
