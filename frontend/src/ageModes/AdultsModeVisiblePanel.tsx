import { resolveAppFlowAgeMode } from './appFlowAgeModes';
import { adultsGameplayRouting } from './adultsGameplayRouting';
import { adultsGameplayDepthProgress } from './adultsGameplayDepthProgress';

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
        {adultsGameplayRouting.routeLabel}
      </p>
      <h2 style={{ margin: '6px 0 8px' }}>{adultsGameplayRouting.entryTitle}</h2>
      <p style={{ margin: '0 0 12px' }}>{adultsGameplayRouting.entryDescription}</p>
      <p data-testid="adults-depth-progress-summary" style={{ margin: '0 0 12px' }}>
        {adultsGameplayDepthProgress.progressSummary}
      </p>
      <div data-testid="adults-mode-selected-key">Selected age mode: {selectedAgeMode}</div>
      <div data-testid="adults-mode-theme">Theme: {config.coreTheme}</div>
      <div data-testid="adults-mode-difficulty">Difficulty: {config.difficultyModel}</div>
      <ul aria-label="Adults gameplay pillars">
        {pillars.map((pillar) => (
          <li key={pillar}>{pillar.replaceAll('_', ' ')}</li>
        ))}
      </ul>
      <ol aria-label="Adults gameplay loop">
        {adultsGameplayRouting.gameplayLoop.map((step) => (
          <li key={step}>{step.replaceAll('_', ' ')}</li>
        ))}
      </ol>
      <ol aria-label="Adults depth milestones">
        {adultsGameplayDepthProgress.depthMilestones.map((milestone) => (
          <li key={milestone.id}>{milestone.label}: {milestone.target.replaceAll('_', ' ')}</li>
        ))}
      </ol>
    </section>
  );
}
