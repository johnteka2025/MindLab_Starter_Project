import React, { useMemo, useState } from 'react';

const MODES = {
  Kids: {
    title: 'Kids Mode',
    subtitle: 'Bright, simple, and confidence-building questions.',
    questions: [
      { prompt: 'Which shape has three sides?', choices: ['Circle', 'Triangle', 'Square'], answer: 'Triangle' },
      { prompt: 'What comes after 4?', choices: ['3', '5', '8'], answer: '5' },
      { prompt: 'Which word means happy?', choices: ['Glad', 'Tiny', 'Fast'], answer: 'Glad' }
    ]
  },
  Adults: {
    title: 'Adults Mode',
    subtitle: 'Balanced focus, reasoning, and recall challenges.',
    questions: [
      { prompt: 'Which item is the best first step in a plan?', choices: ['Define the goal', 'Ignore risks', 'Skip testing'], answer: 'Define the goal' },
      { prompt: 'What improves decision quality?', choices: ['Clear evidence', 'Random guessing', 'More confusion'], answer: 'Clear evidence' },
      { prompt: 'Which task should be prioritized?', choices: ['High impact and urgent', 'Lowest value', 'Unclear work'], answer: 'High impact and urgent' }
    ]
  },
  Seniors: {
    title: 'Seniors Mode',
    subtitle: 'Clear, readable, steady-paced memory and reasoning prompts.',
    questions: [
      { prompt: 'Which activity supports daily organization?', choices: ['Using a checklist', 'Losing notes', 'Skipping reminders'], answer: 'Using a checklist' },
      { prompt: 'Which word is most related to memory?', choices: ['Recall', 'Window', 'Cloud'], answer: 'Recall' },
      { prompt: 'Which choice is safest before acting?', choices: ['Read instructions', 'Rush quickly', 'Guess blindly'], answer: 'Read instructions' }
    ]
  }
};

export default function App() {
  const [mode, setMode] = useState('Kids');
  const [index, setIndex] = useState(0);
  const [selected, setSelected] = useState('');
  const [score, setScore] = useState(0);
  const [finished, setFinished] = useState(false);

  const currentMode = MODES[mode];
  const question = currentMode.questions[index];

  const progressText = useMemo(() => {
    return finished ? 'Complete' : `Question ${index + 1} of ${currentMode.questions.length}`;
  }, [finished, index, currentMode.questions.length]);

  function chooseMode(nextMode) {
    setMode(nextMode);
    setIndex(0);
    setSelected('');
    setScore(0);
    setFinished(false);
  }

  function submitAnswer() {
    if (!selected) {
      return;
    }

    const nextScore = selected === question.answer ? score + 1 : score;
    const nextIndex = index + 1;

    setScore(nextScore);
    setSelected('');

    if (nextIndex >= currentMode.questions.length) {
      setFinished(true);
    } else {
      setIndex(nextIndex);
    }
  }

  function restartMode() {
    setIndex(0);
    setSelected('');
    setScore(0);
    setFinished(false);
  }

  return (
    <main className="app-shell">
      <section className="hero-card">
        <p className="eyebrow">MindLab</p>
        <h1>MindLab Game Modes</h1>
        <p className="hero-copy">
          Choose a focused game mode for Kids, Adults, or Seniors. MindLab is not a medical,
          diagnostic, treatment, prevention, or guaranteed cognitive-improvement product.
        </p>

        <div className="mode-grid" aria-label="Age category selection">
          {Object.keys(MODES).map((modeName) => (
            <button
              key={modeName}
              type="button"
              className={modeName === mode ? 'mode-card active' : 'mode-card'}
              onClick={() => chooseMode(modeName)}
            >
              <span>{modeName}</span>
              <small>{MODES[modeName].subtitle}</small>
            </button>
          ))}
        </div>
      </section>

      <section className="game-card" aria-live="polite">
        <div className="game-header">
          <div>
            <p className="eyebrow">{progressText}</p>
            <h2>{currentMode.title}</h2>
            <p>{currentMode.subtitle}</p>
          </div>
          <div className="score-pill">Score: {score}</div>
        </div>

        {!finished ? (
          <div className="question-panel">
            <h3>{question.prompt}</h3>
            <div className="choice-list">
              {question.choices.map((choice) => (
                <button
                  key={choice}
                  type="button"
                  className={selected === choice ? 'choice selected' : 'choice'}
                  onClick={() => setSelected(choice)}
                >
                  {choice}
                </button>
              ))}
            </div>
            <button type="button" className="primary-action" onClick={submitAnswer}>
              Submit Answer
            </button>
          </div>
        ) : (
          <div className="result-panel">
            <h3>Results</h3>
            <p>
              You completed {currentMode.title} with a score of {score} out of{' '}
              {currentMode.questions.length}.
            </p>
            <button type="button" className="primary-action" onClick={restartMode}>
              Play Again
            </button>
          </div>
        )}
      </section>

      <footer className="footer-links">
        <a href="./privacy.html">Privacy Policy</a>
        <a href="./support.html">Support</a>
      </footer>
    </main>
  );
}
