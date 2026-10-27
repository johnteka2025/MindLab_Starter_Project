import * as React from "react";
import MasteryProgressPanel from "../shared/MasteryProgressPanel";
import {
  createMasterySessionId, masteryDomainFor, readMasteryState, saveMasterySession
} from "../shared/masteryProgression";
import {
  getKidsGameplayItemsForSession,
  type KidsGameplayItem
} from "./kidsGameplayContent";
import KidsPostSessionInsightPanel from "./KidsPostSessionInsightPanel";
import {
  loadKidsSessionHistory,
  recordKidsSessionProgress,
  type KidsSessionHistoryEntry
} from "./kidsPersistence";
import {
  buildFreshSequenceChallenge,
  getAdaptiveSequenceDifficulty
} from "../shared/sequenceChallengeEngine";
import {
  buildFreshFocusChallenge,
  getAdaptiveFocusDifficulty
} from "../shared/focusChallengeEngine";
import {
  buildFreshPatternChallenge,
  getAdaptivePatternDifficulty
} from "../shared/patternChallengeEngine";
import {
  buildFreshPlanningChallenge,
  getAdaptivePlanningDifficulty
} from "../shared/planningChallengeEngine";
import {
  buildFreshSpatialChallenge,
  getAdaptiveSpatialDifficulty
} from "../shared/spatialChallengeEngine";
import {
  calculateKidsScore,
  type KidsScoreResult
} from "./kidsScoring";

const KIDS_SESSION_LENGTH = 3;

type KidsGameplayPanelProps = {
  selectedMode: string;
  onProgressUpdated?: () => void;
};

type KidsRoundResult = {
  certifiedId: string;
  categoryName: string;
  hintUsed: boolean;
  isCorrect: boolean;
  score: number;
};

export function buildKidsSessionItems(
  items: KidsGameplayItem[],
  cycle: number,
  sessionLength = KIDS_SESSION_LENGTH
): KidsGameplayItem[] {
  if (items.length === 0 || sessionLength <= 0) {
    return [];
  }

  const length = Math.min(sessionLength, items.length);
  const startIndex = Math.abs(cycle) % items.length;

  return Array.from({ length }, (_, index) => items[(startIndex + index) % items.length]!);
}

export function buildKidsSequenceExplorerSession(
  items: KidsGameplayItem[],
  cycle: number,
  history: KidsSessionHistoryEntry[]
): KidsGameplayItem[] {
  const recentPerformance = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect,
    score: entry.score
  }));
  const difficulty = getAdaptiveSequenceDifficulty("kids", recentPerformance);
  const sequenceChallenge = buildFreshSequenceChallenge({
    lane: "kids",
    baseSeed: `kids-sequence-explorer-${cycle}-${history.length}`,
    difficulty,
    recentConfigurationIds: history
      .map((entry) => entry.certifiedId)
      .filter((id) => id.startsWith("SEQ-K-"))
  });
  const sequenceItem: KidsGameplayItem = {
    certifiedId: sequenceChallenge.configurationId,
    category: "KC6",
    categoryName: "Sequence Explorer",
    stage: difficulty >= 3 ? "K3" : difficulty >= 2 ? "K2" : "K1",
    sessionMode: "Challenge",
    prompt: sequenceChallenge.prompt,
    options: sequenceChallenge.options,
    correctAnswer: sequenceChallenge.correctAnswer,
    hint: sequenceChallenge.hint,
    insight: sequenceChallenge.insight,
    difficulty: `Adaptive ${difficulty}`
  };
  const staticItems = buildKidsSessionItems(
    items,
    cycle,
    Math.max(0, KIDS_SESSION_LENGTH - 1)
  );

  return [sequenceItem, ...staticItems].slice(0, KIDS_SESSION_LENGTH);
}

export function buildKidsFocusFinderSession(
  items: KidsGameplayItem[],
  cycle: number,
  history: KidsSessionHistoryEntry[]
): KidsGameplayItem[] {
  const recentPerformance = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect,
    score: entry.score
  }));
  const difficulty = getAdaptiveFocusDifficulty("kids", recentPerformance);
  const focusChallenge = buildFreshFocusChallenge({
    lane: "kids",
    baseSeed: `kids-focus-finder-${cycle}-${history.length}`,
    difficulty,
    recentConfigurationIds: history
      .map((entry) => entry.certifiedId)
      .filter((id) => id.startsWith("FOC-K-"))
  });
  const focusItem: KidsGameplayItem = {
    certifiedId: focusChallenge.configurationId,
    category: "KC8",
    categoryName: "Focus Finder",
    stage: difficulty >= 3 ? "K3" : difficulty >= 2 ? "K2" : "K1",
    sessionMode: "PlayFocus",
    prompt: focusChallenge.prompt,
    options: focusChallenge.options,
    correctAnswer: focusChallenge.correctAnswer,
    hint: focusChallenge.hint,
    insight: focusChallenge.insight,
    difficulty: `Adaptive ${difficulty}`
  };
  const staticItems = buildKidsSessionItems(
    items,
    cycle,
    Math.max(0, KIDS_SESSION_LENGTH - 1)
  );

  return [focusItem, ...staticItems].slice(0, KIDS_SESSION_LENGTH);
}

export function buildKidsPatternBuilderSession(
  items: KidsGameplayItem[],
  cycle: number,
  history: KidsSessionHistoryEntry[]
): KidsGameplayItem[] {
  const recentPerformance = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect,
    score: entry.score
  }));
  const difficulty = getAdaptivePatternDifficulty("kids", recentPerformance);
  const patternHistory = history
    .map((entry) => entry.certifiedId)
    .filter((id) => id.startsWith("PAT-K-"));
  const patternChallenge = buildFreshPatternChallenge({
    lane: "kids",
    baseSeed: `kids-pattern-builder-${cycle}-${history.length}`,
    difficulty,
    variationIndex: patternHistory.length + cycle,
    recentConfigurationIds: patternHistory
  });
  const patternItem: KidsGameplayItem = {
    certifiedId: patternChallenge.configurationId,
    category: "KC4",
    categoryName: "Pattern Builder",
    stage: difficulty >= 3 ? "K3" : difficulty >= 2 ? "K2" : "K1",
    sessionMode: "Challenge",
    prompt: patternChallenge.prompt,
    options: patternChallenge.options,
    correctAnswer: patternChallenge.correctAnswer,
    hint: patternChallenge.hint,
    insight: patternChallenge.insight,
    difficulty: `Adaptive ${difficulty}`
  };
  const sequenceSession = buildKidsSequenceExplorerSession(items, cycle, history);
  const sequenceItem = sequenceSession[0];
  const staticItem = sequenceSession[1];

  return [patternItem, sequenceItem, staticItem].filter(
    (item): item is KidsGameplayItem => Boolean(item)
  ).slice(0, KIDS_SESSION_LENGTH);
}


export function buildKidsPathPlannerSession(
  items: KidsGameplayItem[],
  cycle: number,
  history: KidsSessionHistoryEntry[]
): KidsGameplayItem[] {
  const accepted = buildKidsPatternBuilderSession(items, cycle, history);
  const recent = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect, score: entry.score
  }));
  const difficulty = getAdaptivePlanningDifficulty("kids", recent);
  const exposed = history.map((entry) => entry.certifiedId).filter((id) => id.startsWith("PLN-K-"));
  const challenge = buildFreshPlanningChallenge({
    lane: "kids",
    baseSeed: `kids-path-planner-${cycle}-${history.length}`,
    difficulty, variationIndex: exposed.length + cycle,
    recentConfigurationIds: exposed
  });
  const planner: KidsGameplayItem = {
    certifiedId: challenge.configurationId,
    category: "KC4",
    categoryName: "Path Planner",
    stage: difficulty >= 3 ? "K3" : difficulty >= 2 ? "K2" : "K1",
    sessionMode: "Challenge",
    prompt: challenge.prompt,
    options: challenge.options,
    correctAnswer: challenge.correctAnswer,
    hint: challenge.hint,
    insight: challenge.insight,
    difficulty: `Adaptive ${difficulty}`
  };
  // Preserve accepted Pattern Builder and Sequence Explorer as questions 1 and 2.
  return [accepted[0], accepted[1], planner].filter(
    (item): item is KidsGameplayItem => Boolean(item)
  ).slice(0, KIDS_SESSION_LENGTH);
}


export function buildKidsShapeNavigatorSession(
  cycle: number,
  history: KidsSessionHistoryEntry[]
): KidsGameplayItem[] {
  const spatialHistory = history.filter((entry) => entry.certifiedId.startsWith("SPC-K-"));
  const recent = spatialHistory.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect, score: entry.score
  }));
  const difficulty = getAdaptiveSpatialDifficulty("kids", recent);
  const exposed = spatialHistory.map((entry) => entry.certifiedId);
  return Array.from({length:3}, (_,index) => {
    const challenge = buildFreshSpatialChallenge({
      lane: "kids", baseSeed: `kids-spatial-${cycle}-${history.length}-${index}`,
      difficulty, variationIndex: cycle*3+index, recentConfigurationIds: exposed
    });
    return {
    certifiedId: challenge.configurationId, category: "KC4", categoryName: "Shape Navigator",
    stage: difficulty >= 3 ? "K3" : difficulty >= 2 ? "K2" : "K1",
    sessionMode: "Challenge", prompt: challenge.prompt, options: challenge.options,
    correctAnswer: challenge.correctAnswer, hint: challenge.hint, insight: challenge.insight,
    difficulty: `Adaptive ${difficulty}`
    };
  });
}

export default function KidsGameplayPanel({ selectedMode, onProgressUpdated }: KidsGameplayPanelProps) {
  const [sessionCycle, setSessionCycle] = React.useState(0);
  const [spatialMode, setSpatialMode] = React.useState(false);
  const [questionIndex, setQuestionIndex] = React.useState(0);
  const [selectedAnswer, setSelectedAnswer] = React.useState("");
  const [hintVisible, setHintVisible] = React.useState(false);
  const [roundScore, setRoundScore] = React.useState<KidsScoreResult | null>(null);
  const [sessionResults, setSessionResults] = React.useState<KidsRoundResult[]>([]);
  const [sessionComplete, setSessionComplete] = React.useState(false);
  const [mastery, setMastery] = React.useState(() => readMasteryState("kids"));
  const [masterySaved, setMasterySaved] = React.useState(true);
  const masterySessionIdRef = React.useRef(createMasterySessionId("kids"));
  const masteryCommittedRef = React.useRef(false);
  const answerLockedRef = React.useRef(false);

  const availableItems = React.useMemo(
    () => getKidsGameplayItemsForSession(selectedMode),
    [selectedMode]
  );

  const sessionItems = React.useMemo(() => {
    if (spatialMode && selectedMode === "Challenge") {
      return buildKidsShapeNavigatorSession(sessionCycle, loadKidsSessionHistory());
    }
    if (selectedMode === "Challenge") {
      return buildKidsPathPlannerSession(
        availableItems,
        sessionCycle,
        loadKidsSessionHistory()
      );
    }

    if (selectedMode === "PlayFocus") {
      return buildKidsFocusFinderSession(
        availableItems,
        sessionCycle,
        loadKidsSessionHistory()
      );
    }

    return buildKidsSessionItems(availableItems, sessionCycle);
  }, [availableItems, selectedMode, sessionCycle, spatialMode]);

  const activeItem = sessionItems[questionIndex] ?? null;
  const hasAnswered = selectedAnswer.length > 0;
  const isCorrect = Boolean(activeItem && selectedAnswer === activeItem.correctAnswer);

  React.useEffect(() => {
    masterySessionIdRef.current = createMasterySessionId("kids");
    masteryCommittedRef.current = false;
    setMastery(readMasteryState("kids"));
    setSpatialMode(false);
    setSessionCycle(0);
    setQuestionIndex(0);
    setSelectedAnswer("");
    setHintVisible(false);
    setRoundScore(null);
    setSessionResults([]);
    setSessionComplete(false);
    answerLockedRef.current = false;
  }, [selectedMode]);

  function resetQuestionState() {
    setSelectedAnswer("");
    setHintVisible(false);
    setRoundScore(null);
    answerLockedRef.current = false;
  }

  function handleAnswer(option: string) {
    if (!activeItem || answerLockedRef.current) {
      return;
    }

    answerLockedRef.current = true;

    const answerIsCorrect = option === activeItem.correctAnswer;
    const score = calculateKidsScore({
      isCorrect: answerIsCorrect,
      hintVisible,
      tryCount: 0,
      hasAnswered: true
    });

    setSelectedAnswer(option);
    setRoundScore(score);
    setSessionResults((current) => [
      ...current,
      {
        certifiedId: activeItem.certifiedId,
        categoryName: activeItem.categoryName,
        hintUsed: hintVisible,
        isCorrect: answerIsCorrect,
        score: score.totalScore
      }
    ]);

    recordKidsSessionProgress({
      certifiedId: activeItem.certifiedId,
      category: activeItem.category,
      categoryName: activeItem.categoryName,
      stage: activeItem.stage,
      sessionMode: activeItem.sessionMode,
      selectedAnswer: option,
      correctAnswer: activeItem.correctAnswer,
      isCorrect: answerIsCorrect,
      score: score.totalScore,
      masteryLabel: score.masteryLabel,
      exceptionalLevel: score.exceptionalLevel,
      exceptionalLevelUnlocked: score.exceptionalLevelUnlocked,
      scoreBand: score.scoreBand,
      growthSignal: score.growthSignal,
      recoveryModeSuggestion: score.recoveryModeSuggestion,
      adaptiveNextStep: score.adaptiveNextStep,
      completedAt: new Date().toISOString()
    });

    onProgressUpdated?.();
  }

  function handleContinue() {
    if (!activeItem || !roundScore) {
      return;
    }

    if (questionIndex >= sessionItems.length - 1) {
      if (!masteryCommittedRef.current) {
        masteryCommittedRef.current = true;
        const result = saveMasterySession("kids", masterySessionIdRef.current, sessionResults.map(result => ({
          configurationId: result.certifiedId, categoryName: result.categoryName,
          isCorrect: result.isCorrect, hintUsed: result.hintUsed
        })));
        setMastery(result.state);
        setMasterySaved(result.saved);
      }
      setSessionComplete(true);
      return;
    }

    setQuestionIndex((current) => current + 1);
    resetQuestionState();
  }

  function startSpatialSession() {
    masterySessionIdRef.current = createMasterySessionId("kids");
    masteryCommittedRef.current = false;
    setSpatialMode(true);
    setSessionCycle((current) => current + 1);
    setQuestionIndex(0);
    setSessionResults([]);
    setSessionComplete(false);
    resetQuestionState();
  }

  function handleReplay() {
    masterySessionIdRef.current = createMasterySessionId("kids");
    masteryCommittedRef.current = false;
    setSessionCycle((current) => current + 1);
    setQuestionIndex(0);
    setSessionResults([]);
    setSessionComplete(false);
    resetQuestionState();
  }

  if (sessionItems.length === 0) {
    return (
      <section aria-labelledby="kids-gameplay-heading" style={{ marginTop: "28px" }}>
        <h2 id="kids-gameplay-heading">Play round</h2>
        <p>No gameplay items are available for this play mode.</p>
      </section>
    );
  }

  if (sessionComplete) {
    const correctCount = sessionResults.filter((result) => result.isCorrect).length;
    const averageScore = sessionResults.length > 0
      ? Math.round(sessionResults.reduce((sum, result) => sum + result.score, 0) / sessionResults.length)
      : 0;

    return (
      <section aria-labelledby="kids-session-result-heading" style={{ marginTop: "28px" }}>
        {!spatialMode && selectedMode === "Challenge" && (
          <button type="button" onClick={startSpatialSession}
            style={{ margin: "12px 0", padding: "13px 18px", borderRadius: "12px",
              border: "2px solid #1e40af", background: "#eff6ff", color: "#1e3a8a",
              fontWeight: 700, cursor: "pointer" }}>
            Start Shape Navigator (3 visual puzzles)
          </button>
        )}
        <article
          style={{
            border: "1px solid #bbf7d0",
            borderRadius: "22px",
            padding: "22px",
            background: "#f0fdf4"
          }}
        >
          <p style={{ margin: "0 0 6px", color: "#166534", fontSize: "14px" }}>
            Session complete
          </p>
          <h2 id="kids-session-result-heading" style={{ margin: "0 0 14px", fontSize: "28px" }}>
            Nice work. You finished this play round.
          </h2>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(150px, 1fr))",
              gap: "10px"
            }}
          >
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
              <div style={{ color: "#64748b", fontSize: "13px" }}>Challenges</div>
              <strong style={{ fontSize: "22px" }}>{sessionResults.length}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
              <div style={{ color: "#64748b", fontSize: "13px" }}>Correct</div>
              <strong style={{ fontSize: "22px" }}>{correctCount}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
              <div style={{ color: "#64748b", fontSize: "13px" }}>Average score</div>
              <strong style={{ fontSize: "22px" }}>{averageScore}</strong>
            </div>
          </div>

          <MasteryProgressPanel state={mastery} saved={masterySaved}
            focus={masteryDomainFor(sessionResults[0]?.categoryName ?? "", sessionResults[0]?.certifiedId ?? "")} />

          <button
            type="button"
            onClick={handleReplay}
            style={{
              marginTop: "18px",
              border: "1px solid #111827",
              borderRadius: "999px",
              padding: "12px 18px",
              background: "#111827",
              color: "#ffffff",
              cursor: "pointer"
            }}
          >
            Play another round
          </button>
        </article>
      </section>
    );
  }

  if (!activeItem) {
    return null;
  }

  return (
    <section aria-labelledby="kids-gameplay-heading" style={{ marginTop: "28px" }}>
        {!spatialMode && selectedMode === "Challenge" && (
          <button type="button" onClick={startSpatialSession}
            style={{ margin: "12px 0", padding: "13px 18px", borderRadius: "12px",
              border: "2px solid #1e40af", background: "#eff6ff", color: "#1e3a8a",
              fontWeight: 700, cursor: "pointer" }}>
            Start Shape Navigator (3 visual puzzles)
          </button>
        )}
      <div style={{ marginBottom: "16px" }}>
        <p style={{ margin: "0 0 6px", color: "#64748b", fontSize: "14px" }}>
          Challenge {questionIndex + 1} of {sessionItems.length} - {activeItem.categoryName} - {activeItem.stage}
        </p>
        <h2 id="kids-gameplay-heading" style={{ margin: 0, fontSize: "26px" }}>
          Play round
        </h2>
      </div>

      <article
        style={{
          border: "1px solid #e5e7eb",
          borderRadius: "22px",
          padding: "22px",
          background: "#ffffff"
        }}
      >
        <p style={{ margin: "0 0 10px", color: "#475569", lineHeight: 1.6 }}>
          Pick the best answer. Take your time.
        </p>

        <h3 style={{ whiteSpace: spatialMode ? "pre-wrap" : "normal", fontFamily: spatialMode ? "ui-monospace, monospace" : "inherit", margin: "0 0 18px", fontSize: "22px", lineHeight: 1.35 }}>
          {activeItem.prompt}
        </h3>

        <div style={{ display: "grid", gap: "10px" }}>
          {activeItem.options.map((option) => {
            const isSelected = selectedAnswer === option;

            return (
              <button
                aria-label="MindLab interactive control"
                key={option}
                type="button"
                disabled={hasAnswered}
                onClick={() => handleAnswer(option)}
                style={{
                  textAlign: "left",
                  border: isSelected ? "2px solid #111827" : "1px solid #e5e7eb",
                  borderRadius: "16px",
                  padding: "14px 16px",
                  background: isSelected ? "#fef3c7" : "#f9fafb",
                  color: "#111827",
                  cursor: hasAnswered ? "default" : "pointer",
                  fontSize: "16px"
                }}
              >
                <span style={{ whiteSpace: spatialMode ? "pre" : "normal", fontFamily: spatialMode ? "ui-monospace, monospace" : "inherit", display: "block" }}>{option}</span>
              </button>
            );
          })}
        </div>

        <button
          aria-label="MindLab interactive control"
          type="button"
          disabled={hasAnswered}
          onClick={() => setHintVisible((current) => !current)}
          style={{
            marginTop: "14px",
            border: "1px solid #cbd5e1",
            borderRadius: "999px",
            padding: "10px 14px",
            background: "#ffffff",
            color: "#334155",
            cursor: hasAnswered ? "default" : "pointer"
          }}
        >
          {hintVisible ? "Hide clue" : "Show a small clue"}
        </button>

        {hintVisible && (
          <div
            style={{
              marginTop: "12px",
              padding: "12px 14px",
              borderRadius: "14px",
              background: "#eff6ff",
              color: "#1e3a8a"
            }}
          >
            {activeItem.hint}
          </div>
        )}

        {!hasAnswered && (
          <p style={{ margin: "14px 0 0", color: "#475569" }}>
            Choose an answer when you are ready.
          </p>
        )}

        {hasAnswered && roundScore && (
          <>
            <div
              aria-live="polite"
              style={{
                marginTop: "18px",
                padding: "14px 16px",
                borderRadius: "16px",
                background: isCorrect ? "#ecfdf5" : "#fff7ed",
                color: isCorrect ? "#065f46" : "#9a3412"
              }}
            >
              <strong>{isCorrect ? "Great job. You found it." : "Good try. Review the clue and keep going."}</strong>
              <div style={{ marginTop: "8px" }}>
                {isCorrect
                  ? activeItem.insight
                  : `${activeItem.hint} Correct answer: ${activeItem.correctAnswer}.`}
              </div>
            </div>

            <aside
              aria-label="Kids score, mastery, and adaptive guidance"
              style={{
                marginTop: "18px",
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(170px, 1fr))",
                gap: "10px"
              }}
            >
              <div style={{ borderRadius: "16px", background: "#f8fafc", padding: "14px" }}>
                <div style={{ color: "#64748b", fontSize: "13px" }}>Score</div>
                <strong style={{ fontSize: "22px" }}>{roundScore.totalScore}</strong>
              </div>
              <div style={{ borderRadius: "16px", background: "#f8fafc", padding: "14px" }}>
                <div style={{ color: "#64748b", fontSize: "13px" }}>Mastery</div>
                <strong style={{ fontSize: "22px" }}>{roundScore.masteryLabel}</strong>
              </div>
              <div style={{ borderRadius: "16px", background: "#f8fafc", padding: "14px" }}>
                <div style={{ color: "#64748b", fontSize: "13px" }}>Level</div>
                <strong style={{ fontSize: "22px" }}>{roundScore.exceptionalLevel}</strong>
              </div>
              <div style={{ borderRadius: "16px", background: "#f8fafc", padding: "14px" }}>
                <div style={{ color: "#64748b", fontSize: "13px" }}>Score band</div>
                <strong>{roundScore.scoreBand}</strong>
              </div>
            </aside>

            <section
              aria-label="Adaptive next step"
              style={{
                marginTop: "18px",
                borderRadius: "18px",
                background: "#f8fafc",
                border: "1px solid #e5e7eb",
                padding: "16px"
              }}
            >
              <h3 style={{ margin: "0 0 8px", fontSize: "20px" }}>Adaptive guidance</h3>
              <p style={{ margin: "0 0 8px", color: "#475569", lineHeight: 1.55 }}>
                {roundScore.growthSignal}
              </p>
              <strong style={{ color: "#111827" }}>{roundScore.adaptiveNextStep}</strong>
            </section>

            <KidsPostSessionInsightPanel
              item={activeItem}
              score={roundScore}
              hasAnswered={hasAnswered}
              isCorrect={isCorrect}
            />

            <button
              type="button"
              onClick={handleContinue}
              style={{
                marginTop: "18px",
                border: "1px solid #111827",
                borderRadius: "999px",
                padding: "12px 18px",
                background: "#111827",
                color: "#ffffff",
                cursor: "pointer"
              }}
            >
              {questionIndex >= sessionItems.length - 1 ? "View session result" : "Next challenge"}
            </button>
          </>
        )}
      </article>
    </section>
  );
}

export const KIDS_EXPANSION_ROOT_006_GAMEPLAY_VALIDATION_MARKERS = {
  answerGate: "answerLockedRef",
  scoreBandLabel: "Score band",
  adaptiveNextStepLabel: "Adaptive guidance",
  sessionInsightLabel: "Session insight",
  progressRecorder: "recordKidsSessionProgress",
  sessionCompletion: "View session result"
} as const;
