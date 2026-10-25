import * as React from "react";
import MasteryProgressPanel from "../shared/MasteryProgressPanel";
import {
  createMasterySessionId, masteryDomainFor, readMasteryState, saveMasterySession
} from "../shared/masteryProgression";
import {
  getAdultsGameplayItemsForSession,
  type AdultsGameplayItem
} from "./adultsGameplayContent";
import AdultsPostSessionInsightPanel from "./AdultsPostSessionInsightPanel";
import {
  readAdultSessionHistory,
  recordAdultSessionResult,
  type AdultSessionHistoryItem
} from "./adultsPersistence";
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
  calculateAdultsScore,
  type AdultsScoreResult
} from "./adultsScoring";

const ADULTS_SESSION_LENGTH = 3;

type AdultsGameplayPanelProps = {
  selectedMode: string;
};

type AdultsRoundResult = {
  certifiedId: string;
  categoryName: string;
  hintUsed: boolean;
  isCorrect: boolean;
  score: number;
  elapsedSeconds: number;
};

function nowMilliseconds(): number {
  if (typeof performance !== "undefined" && typeof performance.now === "function") {
    return performance.now();
  }

  return Date.now();
}

export function getExpectedAdultsTimeSeconds(selectedMode: string): number {
  if (selectedMode === "QuickFocus") return 45;
  if (selectedMode === "Standard") return 75;
  if (selectedMode === "Deep") return 120;
  if (selectedMode === "Recovery") return 180;
  return 75;
}

export function buildAdultsSessionItems(
  items: AdultsGameplayItem[],
  cycle: number,
  sessionLength = ADULTS_SESSION_LENGTH
): AdultsGameplayItem[] {
  if (items.length === 0 || sessionLength <= 0) {
    return [];
  }

  const length = Math.min(sessionLength, items.length);
  const startIndex = Math.abs(cycle) % items.length;

  return Array.from({ length }, (_, index) => items[(startIndex + index) % items.length]!);
}

export function buildAdultsWorkingMemorySession(
  items: AdultsGameplayItem[],
  cycle: number,
  history: AdultSessionHistoryItem[]
): AdultsGameplayItem[] {
  const recentPerformance = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect,
    score: entry.score
  }));
  const difficulty = getAdaptiveSequenceDifficulty("adults", recentPerformance);
  const sequenceChallenge = buildFreshSequenceChallenge({
    lane: "adults",
    baseSeed: `adults-working-memory-${cycle}-${history.length}`,
    difficulty,
    recentConfigurationIds: history
      .map((entry) => entry.certifiedId)
      .filter((id) => id.startsWith("SEQ-A-"))
  });
  const sequenceItem: AdultsGameplayItem = {
    certifiedId: sequenceChallenge.configurationId,
    category: "AC2",
    categoryName: "Working Memory",
    stage: difficulty >= 3 ? "A3" : difficulty >= 2 ? "A2" : "A1",
    sessionProfile: "QuickFocus",
    promptType: "WorkingMemorySequence",
    objective: "Hold an ordered sequence and retrieve one position accurately",
    prompt: sequenceChallenge.prompt,
    options: sequenceChallenge.options,
    correctAnswer: sequenceChallenge.correctAnswer,
    answerFormat: "SingleChoice",
    difficulty: `Adaptive ${difficulty}`,
    timerPolicy: "Optional",
    hintPolicy: "LightNudge",
    hint: sequenceChallenge.hint,
    insight: sequenceChallenge.insight
  };
  const staticItems = buildAdultsSessionItems(
    items,
    cycle,
    Math.max(0, ADULTS_SESSION_LENGTH - 1)
  );

  return [sequenceItem, ...staticItems].slice(0, ADULTS_SESSION_LENGTH);
}

export function buildAdultsQuickFocusEnhancedSession(
  items: AdultsGameplayItem[],
  cycle: number,
  history: AdultSessionHistoryItem[]
): AdultsGameplayItem[] {
  const recentPerformance = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect,
    score: entry.score
  }));
  const difficulty = getAdaptiveFocusDifficulty("adults", recentPerformance);
  const focusChallenge = buildFreshFocusChallenge({
    lane: "adults",
    baseSeed: `adults-selective-attention-${cycle}-${history.length}`,
    difficulty,
    recentConfigurationIds: history
      .map((entry) => entry.certifiedId)
      .filter((id) => id.startsWith("FOC-A-"))
  });
  const focusItem: AdultsGameplayItem = {
    certifiedId: focusChallenge.configurationId,
    category: "AC1",
    categoryName: "Selective Attention",
    stage: difficulty >= 3 ? "A3" : difficulty >= 2 ? "A2" : "A1",
    sessionProfile: "QuickFocus",
    promptType: "SelectiveAttentionFilter",
    objective: "Hold the target rule steady while rejecting near matches",
    prompt: focusChallenge.prompt,
    options: focusChallenge.options,
    correctAnswer: focusChallenge.correctAnswer,
    answerFormat: "SingleChoice",
    difficulty: `Adaptive ${difficulty}`,
    timerPolicy: "Optional",
    hintPolicy: "LightNudge",
    hint: focusChallenge.hint,
    insight: focusChallenge.insight
  };
  const sequenceSession = buildAdultsWorkingMemorySession(items, cycle, history);
  const sequenceItem = sequenceSession[0];
  const staticItem = sequenceSession[1];

  return [sequenceItem, focusItem, staticItem].filter(
    (item): item is AdultsGameplayItem => Boolean(item)
  ).slice(0, ADULTS_SESSION_LENGTH);
}

export function buildAdultsPatternLogicSession(
  items: AdultsGameplayItem[],
  cycle: number,
  history: AdultSessionHistoryItem[]
): AdultsGameplayItem[] {
  const recentPerformance = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect,
    score: entry.score
  }));
  const difficulty = getAdaptivePatternDifficulty("adults", recentPerformance);
  const patternHistory = history
    .map((entry) => entry.certifiedId)
    .filter((id) => id.startsWith("PAT-A-"));
  const patternChallenge = buildFreshPatternChallenge({
    lane: "adults",
    baseSeed: `adults-pattern-logic-${cycle}-${history.length}`,
    difficulty,
    variationIndex: patternHistory.length + cycle,
    recentConfigurationIds: patternHistory
  });
  const patternItem: AdultsGameplayItem = {
    certifiedId: patternChallenge.configurationId,
    category: "AC3",
    categoryName: "Pattern Logic",
    stage: difficulty >= 3 ? "A3" : difficulty >= 2 ? "A2" : "A1",
    sessionProfile: "Deep",
    promptType: "AdaptivePatternLogic",
    objective: "Identify a consistent transformation and predict the next value",
    prompt: patternChallenge.prompt,
    options: patternChallenge.options,
    correctAnswer: patternChallenge.correctAnswer,
    answerFormat: "SingleChoice",
    difficulty: `Adaptive ${difficulty}`,
    timerPolicy: "OffByDefault",
    hintPolicy: "StrategyCueThenStructureCue",
    hint: patternChallenge.hint,
    insight: patternChallenge.insight
  };
  const staticItems = buildAdultsSessionItems(
    items,
    cycle * (ADULTS_SESSION_LENGTH - 1),
    Math.max(0, ADULTS_SESSION_LENGTH - 1)
  );

  return [patternItem, ...staticItems].slice(0, ADULTS_SESSION_LENGTH);
}


export function buildAdultsStrategicDecisionsSession(
  items: AdultsGameplayItem[],
  cycle: number,
  history: AdultSessionHistoryItem[]
): AdultsGameplayItem[] {
  const accepted = buildAdultsPatternLogicSession(items, cycle, history);
  const recent = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect, score: entry.score
  }));
  const difficulty = getAdaptivePlanningDifficulty("adults", recent);
  const exposed = history.map((entry) => entry.certifiedId).filter((id) => id.startsWith("PLN-A-"));
  const challenge = buildFreshPlanningChallenge({
    lane: "adults",
    baseSeed: `adults-strategic-decisions-${cycle}-${history.length}`,
    difficulty, variationIndex: exposed.length + cycle,
    recentConfigurationIds: exposed
  });
  const planner: AdultsGameplayItem = {
    certifiedId: challenge.configurationId,
    category: "AC3",
    categoryName: "Strategic Decisions",
    stage: difficulty >= 3 ? "A3" : difficulty >= 2 ? "A2" : "A1",
    sessionProfile: "Deep",
    promptType: "ConstrainedPlanning",
    objective: "Choose a sound plan under dependencies and resource constraints",
    prompt: challenge.prompt,
    options: challenge.options,
    correctAnswer: challenge.correctAnswer,
    answerFormat: "SingleChoice",
    difficulty: `Adaptive ${difficulty}`,
    timerPolicy: "OffByDefault",
    hintPolicy: "StrategyCueThenStructureCue",
    hint: challenge.hint,
    insight: challenge.insight
  };
  // Keep accepted Pattern Logic first and one existing Deep challenge.
  return [accepted[0], planner, accepted[1]].filter(
    (item): item is AdultsGameplayItem => Boolean(item)
  ).slice(0, ADULTS_SESSION_LENGTH);
}


export function buildAdultsSpatialReasoningSession(
  cycle: number,
  history: AdultSessionHistoryItem[]
): AdultsGameplayItem[] {
  const recent = history.slice(0,5).map((entry) => ({
    isCorrect: entry.isCorrect, score: entry.score
  }));
  const difficulty = getAdaptiveSpatialDifficulty("adults", recent);
  const exposed = history.map((entry) => entry.certifiedId).filter((id) => id.startsWith("SPC-A-"));
  return Array.from({length:3}, (_,index) => {
    const challenge = buildFreshSpatialChallenge({
      lane: "adults", baseSeed: `adults-spatial-${cycle}-${history.length}-${index}`,
      difficulty, variationIndex: cycle*3+index, recentConfigurationIds: exposed
    });
    return {
    certifiedId: challenge.configurationId, category: "AC3", categoryName: "Spatial Reasoning",
    stage: difficulty >= 3 ? "A3" : difficulty >= 2 ? "A2" : "A1",
    sessionProfile: "Deep", promptType: "VisualSpatial",
    objective: "Reason about geometry and navigate visual maps",
    prompt: challenge.prompt, options: challenge.options,
    correctAnswer: challenge.correctAnswer, answerFormat: "SingleChoice",
    difficulty: `Adaptive ${difficulty}`, timerPolicy: "OffByDefault",
    hintPolicy: "StrategyCueThenStructureCue", hint: challenge.hint, insight: challenge.insight
    };
  });
}

export default function AdultsGameplayPanel({ selectedMode }: AdultsGameplayPanelProps) {
  const [sessionCycle, setSessionCycle] = React.useState(0);
  const [spatialMode, setSpatialMode] = React.useState(false);
  const [questionIndex, setQuestionIndex] = React.useState(0);
  const [selectedAnswer, setSelectedAnswer] = React.useState("");
  const [hintVisible, setHintVisible] = React.useState(false);
  const [hintUse, setHintUse] = React.useState(0);
  const [roundScore, setRoundScore] = React.useState<AdultsScoreResult | null>(null);
  const [savedProfileLabel, setSavedProfileLabel] = React.useState("");
  const [sessionResults, setSessionResults] = React.useState<AdultsRoundResult[]>([]);
  const [sessionComplete, setSessionComplete] = React.useState(false);
  const [mastery, setMastery] = React.useState(() => readMasteryState("adults"));
  const [masterySaved, setMasterySaved] = React.useState(true);
  const masterySessionIdRef = React.useRef(createMasterySessionId("adults"));
  const masteryCommittedRef = React.useRef(false);
  const answerLockedRef = React.useRef(false);
  const questionStartedAtRef = React.useRef(nowMilliseconds());

  const availableItems = React.useMemo(
    () => getAdultsGameplayItemsForSession(selectedMode),
    [selectedMode]
  );

  const sessionItems = React.useMemo(() => {
    if (spatialMode && selectedMode === "Deep") {
      return buildAdultsSpatialReasoningSession(sessionCycle, readAdultSessionHistory());
    }
    if (selectedMode === "QuickFocus") {
      return buildAdultsQuickFocusEnhancedSession(
        availableItems,
        sessionCycle,
        readAdultSessionHistory()
      );
    }

    if (selectedMode === "Deep") {
      return buildAdultsStrategicDecisionsSession(
        availableItems,
        sessionCycle,
        readAdultSessionHistory()
      );
    }

    return buildAdultsSessionItems(availableItems, sessionCycle);
  }, [availableItems, selectedMode, sessionCycle, spatialMode]);

  const activeItem = sessionItems[questionIndex] ?? null;
  const hasAnswered = selectedAnswer.length > 0;
  const isCorrect = Boolean(activeItem && selectedAnswer === activeItem.correctAnswer);

  React.useEffect(() => {
    masterySessionIdRef.current = createMasterySessionId("adults");
    masteryCommittedRef.current = false;
    setMastery(readMasteryState("adults"));
    setSpatialMode(false);
    setSessionCycle(0);
    setQuestionIndex(0);
    setSelectedAnswer("");
    setHintVisible(false);
    setHintUse(0);
    setRoundScore(null);
    setSavedProfileLabel("");
    setSessionResults([]);
    setSessionComplete(false);
    answerLockedRef.current = false;
    questionStartedAtRef.current = nowMilliseconds();
  }, [selectedMode]);

  function resetQuestionState() {
    setSelectedAnswer("");
    setHintVisible(false);
    setHintUse(0);
    setRoundScore(null);
    setSavedProfileLabel("");
    answerLockedRef.current = false;
    questionStartedAtRef.current = nowMilliseconds();
  }

  function handleHint() {
    if (hasAnswered) {
      return;
    }

    if (!hintVisible) {
      setHintUse(1);
    }

    setHintVisible((current) => !current);
  }

  function handleAnswer(option: string) {
    if (!activeItem || answerLockedRef.current) {
      return;
    }

    answerLockedRef.current = true;

    const answerIsCorrect = option === activeItem.correctAnswer;
    const elapsedSeconds = Math.max(
      1,
      Math.round((nowMilliseconds() - questionStartedAtRef.current) / 1000)
    );

    const score = calculateAdultsScore({
      isCorrect: answerIsCorrect,
      selectedAnswer: option,
      correctAnswer: activeItem.correctAnswer,
      hintUse,
      retryCount: 0,
      completed: true,
      expectedTimeSeconds: getExpectedAdultsTimeSeconds(selectedMode),
      actualTimeSeconds: elapsedSeconds,
      firstTrySuccess: answerIsCorrect
    });

    const savedProfile = recordAdultSessionResult({
      certifiedId: activeItem.certifiedId,
      category: activeItem.category,
      stage: activeItem.stage,
      sessionMode: selectedMode,
      selectedAnswer: option,
      correctAnswer: activeItem.correctAnswer,
      isCorrect: answerIsCorrect,
      scoreResult: score
    });

    setSelectedAnswer(option);
    setRoundScore(score);
    setSavedProfileLabel(`${savedProfile.currentStage} - ${savedProfile.currentCategory}`);
    setSessionResults((current) => [
      ...current,
      {
        certifiedId: activeItem.certifiedId,
        categoryName: activeItem.categoryName,
        hintUsed: hintUse > 0,
        isCorrect: answerIsCorrect,
        score: score.overallScore,
        elapsedSeconds
      }
    ]);
  }

  function handleContinue() {
    if (!activeItem || !roundScore) {
      return;
    }

    if (questionIndex >= sessionItems.length - 1) {
      if (!masteryCommittedRef.current) {
        masteryCommittedRef.current = true;
        const result = saveMasterySession("adults", masterySessionIdRef.current, sessionResults.map(result => ({
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
    masterySessionIdRef.current = createMasterySessionId("adults");
    masteryCommittedRef.current = false;
    setSpatialMode(true);
    setSessionCycle((current) => current + 1);
    setQuestionIndex(0);
    setSessionResults([]);
    setSessionComplete(false);
    resetQuestionState();
  }

  function handleReplay() {
    masterySessionIdRef.current = createMasterySessionId("adults");
    masteryCommittedRef.current = false;
    setSessionCycle((current) => current + 1);
    setQuestionIndex(0);
    setSessionResults([]);
    setSessionComplete(false);
    resetQuestionState();
  }

  if (sessionItems.length === 0) {
    return (
      <section aria-labelledby="adults-gameplay-heading" style={{ marginTop: "28px" }}>
        <h2 id="adults-gameplay-heading">Training session</h2>
        <p>No gameplay items are available for this session mode.</p>
      </section>
    );
  }

  if (sessionComplete) {
    const correctCount = sessionResults.filter((result) => result.isCorrect).length;
    const averageScore = sessionResults.length > 0
      ? Math.round(sessionResults.reduce((sum, result) => sum + result.score, 0) / sessionResults.length)
      : 0;
    const totalSeconds = sessionResults.reduce((sum, result) => sum + result.elapsedSeconds, 0);

    return (
      <section aria-labelledby="adults-session-result-heading" style={{ marginTop: "28px" }}>
        {!spatialMode && selectedMode === "Deep" && (
          <button type="button" onClick={startSpatialSession}
            style={{ margin: "12px 0", padding: "13px 18px", borderRadius: "12px",
              border: "2px solid #1e40af", background: "#eff6ff", color: "#1e3a8a",
              fontWeight: 700, cursor: "pointer" }}>
            Start Spatial Reasoning (3 visual puzzles)
          </button>
        )}
        <article
          style={{
            border: "1px solid #c7d2fe",
            borderRadius: "22px",
            padding: "22px",
            background: "#eef2ff"
          }}
        >
          <p style={{ margin: "0 0 6px", color: "#3730a3", fontSize: "14px" }}>
            Session complete - {selectedMode}
          </p>
          <h2 id="adults-session-result-heading" style={{ margin: "0 0 14px", fontSize: "28px" }}>
            Training round complete.
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
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
              <div style={{ color: "#64748b", fontSize: "13px" }}>Measured time</div>
              <strong style={{ fontSize: "22px" }}>{totalSeconds}s</strong>
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
    <section aria-labelledby="adults-gameplay-heading" style={{ marginTop: "28px" }}>
        {!spatialMode && selectedMode === "Deep" && (
          <button type="button" onClick={startSpatialSession}
            style={{ margin: "12px 0", padding: "13px 18px", borderRadius: "12px",
              border: "2px solid #1e40af", background: "#eff6ff", color: "#1e3a8a",
              fontWeight: 700, cursor: "pointer" }}>
            Start Spatial Reasoning (3 visual puzzles)
          </button>
        )}
      <div style={{ marginBottom: "16px" }}>
        <p style={{ margin: "0 0 6px", color: "#64748b", fontSize: "14px" }}>
          Challenge {questionIndex + 1} of {sessionItems.length} - {activeItem.categoryName} - {activeItem.stage}
        </p>
        <h2 id="adults-gameplay-heading" style={{ margin: 0, fontSize: "26px" }}>
          Training round
        </h2>
      </div>

      <article
        style={{
          border: "1px solid #e5e7eb",
          borderRadius: "20px",
          padding: "22px",
          background: "#ffffff"
        }}
      >
        <p style={{ margin: "0 0 10px", color: "#475569", lineHeight: 1.6 }}>
          {activeItem.objective}
        </p>
        <h3 style={{ whiteSpace: spatialMode ? "pre-wrap" : "normal", fontFamily: spatialMode ? "ui-monospace, monospace" : "inherit", margin: "0 0 18px", fontSize: "22px", lineHeight: 1.3 }}>
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
                  borderRadius: "14px",
                  padding: "14px 16px",
                  background: isSelected ? "#e0e7ff" : "#f9fafb",
                  color: "#111827",
                  cursor: hasAnswered ? "default" : "pointer"
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
          onClick={handleHint}
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
          {hintVisible ? "Hide hint" : "Show hint"}
        </button>

        {hintVisible && !hasAnswered && (
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
            Choose one answer when you are ready.
          </p>
        )}

        {hasAnswered && roundScore && (
          <>
            <div
              aria-live="polite"
              style={{
                marginTop: "18px",
                padding: "14px 16px",
                borderRadius: "14px",
                background: isCorrect ? "#ecfdf5" : "#fff7ed",
                color: isCorrect ? "#065f46" : "#9a3412"
              }}
            >
              <strong>{isCorrect ? "Correct." : "Review recommended."}</strong>{" "}
              {isCorrect
                ? activeItem.insight
                : `${activeItem.hint} Correct answer: ${activeItem.correctAnswer}.`}
              {savedProfileLabel && (
                <div style={{ marginTop: "10px", color: "#334155" }}>
                  Progress saved: <strong>{savedProfileLabel}</strong>
                </div>
              )}
            </div>

            <AdultsPostSessionInsightPanel
              scoreResult={roundScore}
              isCorrect={isCorrect}
              itemInsight={activeItem.insight}
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
