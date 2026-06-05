import { useEffect, useMemo, useState } from "react";

const STORAGE_KEY = "mindlab.localProfile.v1";
const EVENT_NAME = "mindlab-profile-changed";

const MODES = [
  {
    id: "kids",
    label: "Kids",
    title: "Kids Mode",
    description: "Bright, simple, and confidence-building questions.",
    questions: [
      {
        prompt: "Which shape has three sides?",
        options: ["Circle", "Triangle", "Square"],
        answer: "Triangle"
      },
      {
        prompt: "Which number comes after 4?",
        options: ["3", "5", "9"],
        answer: "5"
      },
      {
        prompt: "Which color is the sky often on a clear day?",
        options: ["Blue", "Orange", "Black"],
        answer: "Blue"
      }
    ]
  },
  {
    id: "adults",
    label: "Adults",
    title: "Adults Mode",
    description: "Balanced focus, reasoning, and recall challenges.",
    questions: [
      {
        prompt: "If a train leaves at 2:00 and arrives at 4:30, how long was the trip?",
        options: ["2 hours", "2.5 hours", "3 hours"],
        answer: "2.5 hours"
      },
      {
        prompt: "Which word best means careful planning?",
        options: ["Strategy", "Accident", "Guess"],
        answer: "Strategy"
      },
      {
        prompt: "What is 15% of 200?",
        options: ["15", "30", "45"],
        answer: "30"
      }
    ]
  },
  {
    id: "seniors",
    label: "Seniors",
    title: "Seniors Mode",
    description: "Clear, readable, steady-paced memory and reasoning prompts.",
    questions: [
      {
        prompt: "Remember this word: Garden. Which word were you asked to remember?",
        options: ["Window", "Garden", "River"],
        answer: "Garden"
      },
      {
        prompt: "Which item is usually used to tell time?",
        options: ["Clock", "Plate", "Pillow"],
        answer: "Clock"
      },
      {
        prompt: "Which number is larger?",
        options: ["18", "12", "9"],
        answer: "18"
      }
    ]
  }
];

function isModeId(value) {
  return value === "kids" || value === "adults" || value === "seniors";
}

function readProfileState() {
  try {
    const rawProfile = window.localStorage.getItem(STORAGE_KEY);
    const parsedProfile = rawProfile ? JSON.parse(rawProfile) : null;
    const storedCategory = window.localStorage.getItem("mindlab.selectedAgeCategory");
    const allowExplore = window.localStorage.getItem("mindlab.allowExploreOtherCategories") === "true";

    const profileCategory = parsedProfile && isModeId(parsedProfile.ageCategory)
      ? parsedProfile.ageCategory
      : null;

    const selectedAgeCategory = profileCategory || (isModeId(storedCategory) ? storedCategory : "kids");

    return {
      profileName: parsedProfile?.name || "MindLab Player",
      selectedAgeCategory,
      allowExploreOtherCategories: allowExplore
    };
  } catch {
    return {
      profileName: "MindLab Player",
      selectedAgeCategory: "kids",
      allowExploreOtherCategories: false
    };
  }
}

export default function MindLabOriginalApp() {
  const initialProfileState = useMemo(() => readProfileState(), []);
  const [profileState, setProfileState] = useState(initialProfileState);
  const [activeModeId, setActiveModeId] = useState(initialProfileState.selectedAgeCategory);
  const [questionIndex, setQuestionIndex] = useState(0);
  const [score, setScore] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState("");

  useEffect(() => {
    function syncFromProfileEvent(event) {
      const detail = event.detail || {};
      const nextCategory = detail.activeAgeCategory || detail.profile?.ageCategory || readProfileState().selectedAgeCategory;
      const nextAllowExplore = Boolean(detail.allowExploreOtherCategories);

      if (isModeId(nextCategory)) {
        setProfileState({
          profileName: detail.profile?.name || readProfileState().profileName,
          selectedAgeCategory: nextCategory,
          allowExploreOtherCategories: nextAllowExplore
        });

        setActiveModeId(nextCategory);
        setQuestionIndex(0);
        setSelectedAnswer("");
        setScore(0);
      }
    }

    function syncFromStorage() {
      const nextProfileState = readProfileState();
      setProfileState(nextProfileState);
      setActiveModeId(nextProfileState.selectedAgeCategory);
      setQuestionIndex(0);
      setSelectedAnswer("");
      setScore(0);
    }

    window.addEventListener(EVENT_NAME, syncFromProfileEvent);
    window.addEventListener("storage", syncFromStorage);

    syncFromStorage();

    return () => {
      window.removeEventListener(EVENT_NAME, syncFromProfileEvent);
      window.removeEventListener("storage", syncFromStorage);
    };
  }, []);

  const visibleModes = profileState.allowExploreOtherCategories
    ? MODES
    : MODES.filter((mode) => mode.id === profileState.selectedAgeCategory);

  const activeMode = MODES.find((mode) => mode.id === activeModeId) || MODES.find((mode) => mode.id === profileState.selectedAgeCategory) || MODES[0];
  const currentQuestion = activeMode.questions[questionIndex];

  function selectMode(modeId) {
    setActiveModeId(modeId);
    setQuestionIndex(0);
    setSelectedAnswer("");
    setScore(0);
  }

  function submitAnswer(option) {
    setSelectedAnswer(option);

    if (option === currentQuestion.answer) {
      setScore((value) => value + 1);
    }
  }

  function nextQuestion() {
    setSelectedAnswer("");
    setQuestionIndex((value) => {
      if (value + 1 >= activeMode.questions.length) {
        return 0;
      }

      return value + 1;
    });
  }

  function restartMode() {
    setQuestionIndex(0);
    setScore(0);
    setSelectedAnswer("");
  }

  return (
    <main className="mindlab-app-shell">
      <section className="mindlab-hero-card">
        <p className="mindlab-eyebrow">MINDLAB</p>
        <h1>MindLab Game Modes</h1>
        <p>
          Choose a focused game mode for Kids, Adults, or Seniors. MindLab is not a medical,
          diagnostic, treatment, prevention, or guaranteed cognitive-improvement product.
        </p>

        <div className="mindlab-mode-grid">
          {visibleModes.map((mode) => (
            <button
              key={mode.id}
              type="button"
              className={activeMode.id === mode.id ? "mindlab-mode-card is-active" : "mindlab-mode-card"}
              onClick={() => selectMode(mode.id)}
              data-age-category={mode.id}
            >
              <strong>{mode.label}</strong>
              <span>{mode.description}</span>
            </button>
          ))}
        </div>
      </section>

      <section className="mindlab-question-card" data-active-age-category={activeMode.id}>
        <div className="mindlab-question-header">
          <div>
            <p className="mindlab-eyebrow">QUESTION {questionIndex + 1} OF {activeMode.questions.length}</p>
            <h2>{activeMode.title}</h2>
            <p>{activeMode.description}</p>
          </div>
          <strong className="mindlab-score">Score: {score}</strong>
        </div>

        <h3>{currentQuestion.prompt}</h3>

        <div className="mindlab-answer-list">
          {currentQuestion.options.map((option) => (
            <button
              key={option}
              type="button"
              className={selectedAnswer === option ? "mindlab-answer is-selected" : "mindlab-answer"}
              onClick={() => submitAnswer(option)}
            >
              {option}
            </button>
          ))}
        </div>

        {selectedAnswer && (
          <p className="mindlab-feedback">
            {selectedAnswer === currentQuestion.answer ? "Correct." : `Correct answer: ${currentQuestion.answer}`}
          </p>
        )}

        <div className="mindlab-game-actions">
          <button type="button" onClick={nextQuestion}>Next Question</button>
          <button type="button" onClick={restartMode}>Restart Mode</button>
        </div>
      </section>
    </main>
  );
}
