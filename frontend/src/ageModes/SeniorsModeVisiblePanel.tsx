import { seniorsAgeModeFoundation } from './seniorsAgeModeFoundation';

export function SeniorsModeVisiblePanel() {
  return (
    <section
      data-testid="seniors-mode-visible-panel"
      aria-label="Seniors mode foundation active"
      style={{
        border: '1px solid #d1d5db',
        borderRadius: '18px',
        padding: '18px',
        margin: '16px',
        background: '#ffffff',
        fontSize: '18px',
        lineHeight: 1.5,
      }}
    >
      <p style={{ margin: 0, fontSize: '13px', fontWeight: 700, letterSpacing: '0.08em', textTransform: 'uppercase' }}>
        {seniorsAgeModeFoundation.ageModeLabel}
      </p>
      <h2 style={{ margin: '8px 0 10px' }}>Guided cognitive confidence</h2>
      <p data-testid="seniors-foundation-summary" style={{ margin: '0 0 12px' }}>
        Seniors mode supports memory, focus, attention, pattern recognition, accessible pacing, and confidence-building progress.
      </p>
      <div data-testid="seniors-pacing-model">Pacing: {seniorsAgeModeFoundation.pacingModel.replaceAll('_', ' ')}</div>
      <div data-testid="seniors-accessibility-model">Accessibility: {seniorsAgeModeFoundation.accessibilityModel.replaceAll('_', ' ')}</div>
      <div data-testid="seniors-difficulty-model">Difficulty: {seniorsAgeModeFoundation.difficultyModel.replaceAll('_', ' ')}</div>
      <ul aria-label="Seniors foundation pillars">
        {seniorsAgeModeFoundation.foundationPillars.map((pillar) => (
          <li key={pillar}>{pillar.replaceAll('_', ' ')}</li>
        ))}
      </ul>
    </section>
  );
}
