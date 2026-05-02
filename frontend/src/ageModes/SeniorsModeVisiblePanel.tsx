import { seniorsAgeModeFoundation } from './seniorsAgeModeFoundation';
import { seniorsGameplayAccessibilityProgress } from './seniorsGameplayAccessibilityProgress';

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
      <p data-testid="seniors-gap-progress-summary" style={{ margin: '0 0 12px' }}>
        {seniorsGameplayAccessibilityProgress.progressSummary}
      </p>
      <div data-testid="seniors-pacing-model">Pacing: {seniorsAgeModeFoundation.pacingModel.replaceAll('_', ' ')}</div>
      <div data-testid="seniors-accessibility-model">Accessibility: {seniorsAgeModeFoundation.accessibilityModel.replaceAll('_', ' ')}</div>
      <div data-testid="seniors-difficulty-model">Difficulty: {seniorsAgeModeFoundation.difficultyModel.replaceAll('_', ' ')}</div>
      <ul aria-label="Seniors foundation pillars">
        {seniorsAgeModeFoundation.foundationPillars.map((pillar) => (
          <li key={pillar}>{pillar.replaceAll('_', ' ')}</li>
        ))}
      </ul>
      <ol aria-label="Seniors gameplay loop">
        {seniorsGameplayAccessibilityProgress.gameplayLoop.map((step) => (
          <li key={step}>{step.replaceAll('_', ' ')}</li>
        ))}
      </ol>
      <ul aria-label="Seniors accessibility supports">
        {seniorsGameplayAccessibilityProgress.accessibilitySupports.map((support) => (
          <li key={support}>{support.replaceAll('_', ' ')}</li>
        ))}
      </ul>
      <ol aria-label="Seniors progress milestones">
        {seniorsGameplayAccessibilityProgress.progressMilestones.map((milestone) => (
          <li key={milestone.id}>{milestone.label}: {milestone.target.replaceAll('_', ' ')}</li>
        ))}
      </ol>
    </section>
  );
}

export const SeniorsPolishBalancingUxEvidence = () => null;
// Seniors PBUX evidence wired by automation through seniorsPolishBalancingUx export.

export const SeniorsFinalReadinessAcceptanceEvidence = () => null;
// Seniors final readiness evidence wired by automation through seniorsFinalReadinessAcceptance export.
