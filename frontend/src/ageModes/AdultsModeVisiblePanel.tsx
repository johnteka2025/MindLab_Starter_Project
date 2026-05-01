import { resolveAppFlowAgeMode } from './appFlowAgeModes';
import { adultsGameplayRouting } from './adultsGameplayRouting';
import { adultsGameplayDepthProgress } from './adultsGameplayDepthProgress';
import { adultsPolishBalancingUx } from './adultsPolishBalancingUx';

export function AdultsModeVisiblePanel() {
  const { selectedAgeMode, config } = resolveAppFlowAgeMode('adults');
  const pillars = config.gameplayPillars;

  return (
    <section
      data-testid="adults-mode-visible-panel"
      aria-label={adultsPolishBalancingUx.accessibility.panelLabel}
      style={{
        border: '1px solid #d1d5db',
        borderRadius: '18px',
        padding: '18px',
        margin: '16px',
        background: '#ffffff',
      }}
    >
      <p style={{ margin: 0, fontSize: '12px', fontWeight: 700, letterSpacing: '0.08em', textTransform: 'uppercase' }}>
        {adultsPolishBalancingUx.uxCopy.eyebrow}
      </p>
      <h2 style={{ margin: '6px 0 8px' }}>{adultsPolishBalancingUx.uxCopy.headline}</h2>
      <p data-testid="adults-polish-ux-helper" style={{ margin: '0 0 12px' }}>
        {adultsPolishBalancingUx.uxCopy.helperText}
      </p>
      <p style={{ margin: '0 0 12px' }}>{adultsGameplayRouting.entryDescription}</p>
      <p data-testid="adults-depth-progress-summary" style={{ margin: '0 0 12px' }}>
        {adultsGameplayDepthProgress.progressSummary}
      </p>
      <div data-testid="adults-mode-selected-key">Selected age mode: {selectedAgeMode}</div>
      <div data-testid="adults-mode-theme">Theme: {config.coreTheme}</div>
      <div data-testid="adults-mode-difficulty">Difficulty: {config.difficultyModel}</div>
      <div data-testid="adults-balancing-tuning">
        Balance: {adultsPolishBalancingUx.balanceTuning.startingDifficulty} / {adultsPolishBalancingUx.balanceTuning.adaptiveRamp}
      </div>
      <ul aria-label="Adults gameplay pillars">
        {pillars.map((pillar) => (
          <li key={pillar}>{pillar.replaceAll('_', ' ')}</li>
        ))}
      </ul>
      <ol aria-label={adultsPolishBalancingUx.accessibility.gameplayLabel}>
        {adultsGameplayRouting.gameplayLoop.map((step) => (
          <li key={step}>{step.replaceAll('_', ' ')}</li>
        ))}
      </ol>
      <ol aria-label={adultsPolishBalancingUx.accessibility.progressLabel}>
        {adultsGameplayDepthProgress.depthMilestones.map((milestone) => (
          <li key={milestone.id}>{milestone.label}: {milestone.target.replaceAll('_', ' ')}</li>
        ))}
      </ol>
    </section>
  );
}
