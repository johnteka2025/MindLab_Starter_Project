import { useMemo, useState } from "react";
import "./MindLabOriginalApp.css";

const STORAGE_KEY = "mindlab.localProfile.v1";

const GAME_MODES = {
  kids: {
    label: "Kids",
    title: "Kids Mode",
    subtitle: "Bright, simple, and confidence-building questions.",
    lockedText: "Kids profile is locked to Kids Mode. Only Kids activities are shown.",
    questions: [
      {
        prompt: "Which shape has three sides?",
        answers: ["Circle", "Triangle", "Square"],
        correctAnswer: "Triangle"
      },
      {
        prompt: "What number comes after 4?",
        answers: ["3", "5", "8"],
        correctAnswer: "5"
      },
      {
        prompt: "Which animal says meow?",
        answers: ["Dog", "Cat", "Bird"],
        correctAnswer: "Cat"
      }
    ]
  },
  adults: {
    label: "Adults",
    title: "Adults Mode",
    subtitle: "Focused questions for quick reasoning practice.",
    lockedText: "Adults profile is locked to Adults Mode. Only Adults activities are shown.",
    questions: [
      {
        prompt: "Which option is the strongest planning step?",
        answers: ["Guess first", "Define the goal", "Ignore limits"],
        correctAnswer: "Define the goal"
      },
      {
        prompt: "What improves decision quality?",
        answers: ["Clear tradeoffs", "More confusion", "No review"],
        correctAnswer: "Clear tradeoffs"
      },
      {
        prompt: "Which habit supports learning?",
        answers: ["Review mistakes", "Avoid feedback", "Rush every task"],
        correctAnswer: "Review mistakes"
      }
    ]
  },
  seniors: {
    label: "Seniors",
    title: "Seniors Mode",
    subtitle: "Clear, comfortable questions with easy navigation.",
    lockedText: "Seniors profile is locked to Seniors Mode. Only Seniors activities are shown.",
    questions: [
      {
        prompt: "Which item is used to tell time?",
        answers: ["Clock", "Plate", "Pillow"],
        correctAnswer: "Clock"
      },
      {
        prompt: "Which word means the same as calm?",
        answers: ["Peaceful", "Loud", "Sharp"],
        correctAnswer: "Peaceful"
      },
      {
        prompt: "Which activity helps organize a day?",
        answers: ["Making a list", "Losing notes", "Skipping plans"],
        correctAnswer: "Making a list"
      }
    ]
  }
};

function isValidCategory(value) {
  return value === "kids" || value === "adults" || value === "seniors";
}

function loadLocalProfile() {
  try {
    const rawProfile = window.localStorage.getItem(STORAGE_KEY);
    if (!rawProfile) {
      return null;
    }

    const parsedProfile = JSON.parse(rawProfile);

    if (!parsedProfile || !isValidCategory(parsedProfile.ageCategory)) {
      return null;
    }

    return {
      name: parsedProfile.name || "MindLab Player",
      ageCategory: parsedProfile.ageCategory
    };
  } catch {
    return null;
  }
}

export default function MindLabOriginalApp() {
  const localProfile = useMemo(() => loadLocalProfile(), []);
  const lockedCategory = isValidCategory(localProfile?.ageCategory) ? localProfile.ageCategory : "kids";
  const activeMode = GAME_MODES[lockedCategory];

  const [questionIndex, setQuestionIndex] = useState(0);
  const [score, setScore] = useState(0);
  const [answerState, setAnswerState] = useState(null);

  const currentQuestion = activeMode.questions[questionIndex];
  const totalQuestions = activeMode.questions.length;

  function handleAnswer(answer) {
    if (answerState) {
      return;
    }

    const isCorrect = answer === currentQuestion.correctAnswer;

    setAnswerState({
      selectedAnswer: answer,
      isCorrect
    });

    if (isCorrect) {
      setScore((currentScore) => currentScore + 1);
    }
  }

  function goToNextQuestion() {
    setQuestionIndex((currentIndex) => (currentIndex + 1) % totalQuestions);
    setAnswerState(null);
  }

  function restartMode() {
    setQuestionIndex(0);
    setScore(0);
    setAnswerState(null);
  }

  return (
    <div className="mindlab-game-shell" role="main">
      <section className="mindlab-game-hero" aria-labelledby="mindlab-title">
        <div className="mindlab-kicker">MindLab</div>
        <h1 id="mindlab-title">MindLab Game Modes</h1>
        <p className="mindlab-hero-lock">{activeMode.lockedText}</p>
        <p className="mindlab-hero-note">MindLab is a game experience for structured play and practice.</p>

        <div className="mindlab-profile-summary">
          <div>
            <span className="mindlab-summary-label">Current profile</span>
            <strong>{localProfile?.name || "MindLab Player"}</strong>
          </div>
          <div>
            <span className="mindlab-summary-label">Active category</span>
            <strong>{activeMode.label}</strong>
          </div>
        </div>
      </section>

      <section className="mindlab-mode-card mindlab-mode-card-active" aria-label={`${activeMode.label} game area`}>
        <div className="mindlab-mode-header">
          <div>
            <span className="mindlab-mode-pill">{activeMode.label}</span>
            <h2>{activeMode.title}</h2>
            <p>{activeMode.subtitle}</p>
          </div>
          <div className="mindlab-score-card">
            <span>Score</span>
            <strong>{score}</strong>
          </div>
        </div>

        <div className="mindlab-question-card">
          <div className="mindlab-question-meta">
            Question {questionIndex + 1} of {totalQuestions}
          </div>

          <h3>{currentQuestion.prompt}</h3>

          <div className="mindlab-answer-grid">
            {currentQuestion.answers.map((answer) => {
              const selected = answerState?.selectedAnswer === answer;
              const correct = selected && answerState?.isCorrect;
              const incorrect = selected && answerState && !answerState.isCorrect;

              return (
                <button
                  key={answer}
                  type="button"
                  className={[
                    "mindlab-answer-button",
                    correct ? "is-correct" : "",
                    incorrect ? "is-incorrect" : ""
                  ].filter(Boolean).join(" ")}
                  onClick={() => handleAnswer(answer)}
                >
                  {answer}
                </button>
              );
            })}
          </div>

          {answerState && (
            <div className={answerState.isCorrect ? "mindlab-result is-correct" : "mindlab-result is-incorrect"}>
              {answerState.isCorrect ? "Correct." : `Try again. Correct answer: ${currentQuestion.correctAnswer}.`}
            </div>
          )}

          <div className="mindlab-action-row">
            <button type="button" onClick={goToNextQuestion}>Next Question</button>
            <button type="button" onClick={restartMode}>Restart Mode</button>
          </div>
        </div>
      </section>
    </div>
  );
}
