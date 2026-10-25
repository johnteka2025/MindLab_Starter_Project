import * as React from "react";
import MasteryProgressPanel from "../shared/MasteryProgressPanel";
import {
  createMasterySessionId, masteryDomainFor, readMasteryState, saveMasterySession
} from "../shared/masteryProgression";
import {
  getSeniorsGameplayItemsForSession,
  type SeniorsGameplayItem
} from "./seniorsGameplayContent";
import {
  readSeniorsSessionHistory,
  recordSeniorsChallengeResult,
  type SeniorsPersistenceRecord
} from "./seniorsPersistence";
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
  calculateSeniorsScore,
  type SeniorsScoreResult
} from "./seniorsScoring";
import {
  getSeniorsSessionSummary,
  type SeniorsSessionRoundResult
} from "./seniorsPostSessionInsights";
import SeniorsPostSessionInsightPanel from "./SeniorsPostSessionInsightPanel";
import type { SeniorsSessionModeId } from "./seniorsSessionModes";

const SENIORS_SESSION_LENGTH = 3;
type MasterySeniorsRoundResult = SeniorsSessionRoundResult & { hintUsed: boolean };

function nowMilliseconds(): number {
  if (typeof performance !== "undefined" && typeof performance.now === "function") {
    return performance.now();
  }

  return Date.now();
}

export function shouldAcceptSeniorsAnswer(answerLocked: boolean): boolean {
  return !answerLocked;
}

export function buildSeniorsSessionItems(
  items: SeniorsGameplayItem[],
  cycle: number,
  sessionLength = SENIORS_SESSION_LENGTH
): SeniorsGameplayItem[] {
  if (items.length === 0 || sessionLength <= 0) {
    return [];
  }

  const length = Math.min(sessionLength, items.length);
  const startIndex = Math.abs(cycle) % items.length;

  return Array.from({ length }, (_, index) => items[(startIndex + index) % items.length]!);
}

export function buildSeniorsGuidedRecallSession(
  items: SeniorsGameplayItem[],
  cycle: number,
  history: SeniorsPersistenceRecord[]
): SeniorsGameplayItem[] {
  const recentPerformance = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect,
    score: entry.score,
    hintUsed: entry.hintUsed
  }));
  const difficulty = getAdaptiveSequenceDifficulty("seniors", recentPerformance);
  const sequenceChallenge = buildFreshSequenceChallenge({
    lane: "seniors",
    baseSeed: `seniors-guided-recall-${cycle}-${history.length}`,
    difficulty,
    recentConfigurationIds: history
      .map((entry) => entry.challengeId)
      .filter((id) => id.startsWith("SEQ-S-"))
  });
  const sequenceItem: SeniorsGameplayItem = {
    challengeId: sequenceChallenge.configurationId,
    category: "memory_support",
    categoryName: "Guided Recall",
    stage: difficulty >= 2 ? "S2" : "S1",
    sessionProfile: "GuidedMemory",
    objective: "Practice ordered recall with clear pacing and no speed penalty",
    prompt: sequenceChallenge.prompt,
    options: sequenceChallenge.options,
    correctAnswer: sequenceChallenge.correctAnswer,
    hint: sequenceChallenge.hint,
    insight: sequenceChallenge.insight
  };
  const staticItems = buildSeniorsSessionItems(
    items,
    cycle,
    Math.max(0, SENIORS_SESSION_LENGTH - 1)
  );

  return [sequenceItem, ...staticItems].slice(0, SENIORS_SESSION_LENGTH);
}

export function buildSeniorsFocusFilterSession(
  items: SeniorsGameplayItem[],
  cycle: number,
  history: SeniorsPersistenceRecord[]
): SeniorsGameplayItem[] {
  const recentPerformance = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect,
    score: entry.score,
    hintUsed: entry.hintUsed
  }));
  const difficulty = getAdaptiveFocusDifficulty("seniors", recentPerformance);
  const focusChallenge = buildFreshFocusChallenge({
    lane: "seniors",
    baseSeed: `seniors-focus-filter-${cycle}-${history.length}`,
    difficulty,
    recentConfigurationIds: history
      .map((entry) => entry.challengeId)
      .filter((id) => id.startsWith("FOC-S-"))
  });
  const focusItem: SeniorsGameplayItem = {
    challengeId: focusChallenge.configurationId,
    category: "focus_attention",
    categoryName: "Focus & Filter",
    stage: difficulty >= 2 ? "S2" : "S1",
    sessionProfile: "FocusAttention",
    objective: "Apply a clear attention rule carefully without speed pressure",
    prompt: focusChallenge.prompt,
    options: focusChallenge.options,
    correctAnswer: focusChallenge.correctAnswer,
    hint: focusChallenge.hint,
    insight: focusChallenge.insight
  };
  const staticItems = buildSeniorsSessionItems(
    items,
    cycle,
    Math.max(0, SENIORS_SESSION_LENGTH - 1)
  );

  return [focusItem, ...staticItems].slice(0, SENIORS_SESSION_LENGTH);
}

export function buildSeniorsPatternConfidenceSession(
  items: SeniorsGameplayItem[],
  cycle: number,
  history: SeniorsPersistenceRecord[]
): SeniorsGameplayItem[] {
  const recentPerformance = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect,
    score: entry.score,
    hintUsed: entry.hintUsed
  }));
  const difficulty = getAdaptivePatternDifficulty("seniors", recentPerformance);
  const patternHistory = history
    .map((entry) => entry.challengeId)
    .filter((id) => id.startsWith("PAT-S-"));
  const patternChallenge = buildFreshPatternChallenge({
    lane: "seniors",
    baseSeed: `seniors-pattern-confidence-${cycle}-${history.length}`,
    difficulty,
    variationIndex: patternHistory.length + cycle,
    recentConfigurationIds: patternHistory
  });
  const patternItem: SeniorsGameplayItem = {
    challengeId: patternChallenge.configurationId,
    category: "pattern_recognition",
    categoryName: "Pattern Confidence",
    stage: difficulty >= 2 ? "S2" : "S1",
    sessionProfile: "PatternConfidence",
    objective: "Recognize a clear pattern carefully without speed pressure",
    prompt: patternChallenge.prompt,
    options: patternChallenge.options,
    correctAnswer: patternChallenge.correctAnswer,
    hint: patternChallenge.hint,
    insight: patternChallenge.insight
  };
  const staticItems = buildSeniorsSessionItems(
    items,
    cycle * (SENIORS_SESSION_LENGTH - 1),
    Math.max(0, SENIORS_SESSION_LENGTH - 1)
  );

  return [patternItem, ...staticItems].slice(0, SENIORS_SESSION_LENGTH);
}


export function buildSeniorsEverydayPlanningSession(
  items: SeniorsGameplayItem[],
  cycle: number,
  history: SeniorsPersistenceRecord[]
): SeniorsGameplayItem[] {
  const accepted = buildSeniorsPatternConfidenceSession(items, cycle, history);
  const recent = history.slice(0, 5).map((entry) => ({
    isCorrect: entry.isCorrect, score: entry.score, hintUsed: entry.hintUsed
  }));
  const difficulty = getAdaptivePlanningDifficulty("seniors", recent);
  const exposed = history.map((entry) => entry.challengeId).filter((id) => id.startsWith("PLN-S-"));
  const challenge = buildFreshPlanningChallenge({
    lane: "seniors",
    baseSeed: `seniors-everyday-planning-${cycle}-${history.length}`,
    difficulty, variationIndex: exposed.length + cycle,
    recentConfigurationIds: exposed
  });
  const planner: SeniorsGameplayItem = {
    challengeId: challenge.configurationId,
    category: "planning",
    categoryName: "Everyday Planning",
    stage: difficulty >= 2 ? "S2" : "S1",
    sessionProfile: "PatternConfidence",
    objective: "Plan familiar tasks confidently without speed pressure",
    prompt: challenge.prompt,
    options: challenge.options,
    correctAnswer: challenge.correctAnswer,
    hint: challenge.hint,
    insight: challenge.insight
  };
  // Keep accepted Pattern Confidence first; no forced timer or speed control.
  return [accepted[0], planner, accepted[1]].filter(
    (item): item is SeniorsGameplayItem => Boolean(item)
  ).slice(0, SENIORS_SESSION_LENGTH);
}


type SeniorsGameplayPanelProps = {
  selectedMode: SeniorsSessionModeId;
};

export function buildSeniorsEverydayNavigationSession(
  cycle: number,
  history: SeniorsPersistenceRecord[]
): SeniorsGameplayItem[] {
  const recent = history.slice(0,5).map((entry) => ({
    isCorrect: entry.isCorrect, score: entry.score, hintUsed: entry.hintUsed
  }));
  const difficulty = getAdaptiveSpatialDifficulty("seniors", recent);
  const exposed = history.map((entry) => entry.challengeId).filter((id) => id.startsWith("SPC-S-"));
  return Array.from({length:3}, (_,index) => {
    const challenge = buildFreshSpatialChallenge({
      lane: "seniors", baseSeed: `seniors-spatial-${cycle}-${history.length}-${index}`,
      difficulty, variationIndex: cycle*3+index, recentConfigurationIds: exposed
    });
    return {
    challengeId: challenge.configurationId, category: "spatial", categoryName: "Everyday Navigation",
    stage: difficulty >= 3 ? "S3" : difficulty >= 2 ? "S2" : "S1",
    sessionProfile: "PatternConfidence", objective: "Spatial navigation without speed pressure",
    prompt: challenge.prompt, options: challenge.options, correctAnswer: challenge.correctAnswer,
    hint: challenge.hint, insight: challenge.insight
    };
  });
}

export default function SeniorsGameplayPanel({
  selectedMode
}: SeniorsGameplayPanelProps) {
  const [sessionCycle, setSessionCycle] = React.useState(0);
  const [spatialMode, setSpatialMode] = React.useState(false);
  const [questionIndex, setQuestionIndex] = React.useState(0);
  const [selectedAnswer, setSelectedAnswer] = React.useState("");
  const [hintVisible, setHintVisible] = React.useState(false);
  const [roundScore, setRoundScore] = React.useState<SeniorsScoreResult | null>(null);
  const [sessionResults, setSessionResults] = React.useState<MasterySeniorsRoundResult[]>([]);
  const [sessionComplete, setSessionComplete] = React.useState(false);
  const [mastery, setMastery] = React.useState(() => readMasteryState("seniors"));
  const [masterySaved, setMasterySaved] = React.useState(true);
  const masterySessionIdRef = React.useRef(createMasterySessionId("seniors"));
  const masteryCommittedRef = React.useRef(false);

  const answerLockedRef = React.useRef(false);
  const questionStartedAtRef = React.useRef(nowMilliseconds());

  const availableItems = React.useMemo(
    () => getSeniorsGameplayItemsForSession(selectedMode),
    [selectedMode]
  );

  const sessionItems = React.useMemo(() => {
    if (spatialMode && selectedMode === "PatternConfidence") {
      return buildSeniorsEverydayNavigationSession(sessionCycle, readSeniorsSessionHistory());
    }
    if (selectedMode === "GuidedMemory") {
      return buildSeniorsGuidedRecallSession(
        availableItems,
        sessionCycle,
        readSeniorsSessionHistory()
      );
    }

    if (selectedMode === "FocusAttention") {
      return buildSeniorsFocusFilterSession(
        availableItems,
        sessionCycle,
        readSeniorsSessionHistory()
      );
    }

    if (selectedMode === "PatternConfidence") {
      return buildSeniorsEverydayPlanningSession(
        availableItems,
        sessionCycle,
        readSeniorsSessionHistory()
      );
    }

    return buildSeniorsSessionItems(availableItems, sessionCycle);
  }, [availableItems, selectedMode, sessionCycle, spatialMode]);

  const activeItem = sessionItems[questionIndex] ?? null;
  const hasAnswered = selectedAnswer.length > 0;
  const isCorrect = Boolean(activeItem && selectedAnswer === activeItem.correctAnswer);

  React.useEffect(() => {
    masterySessionIdRef.current = createMasterySessionId("seniors");
    masteryCommittedRef.current = false;
    setMastery(readMasteryState("seniors"));
    setSpatialMode(false);
    setSessionCycle(0);
    setQuestionIndex(0);
    setSelectedAnswer("");
    setHintVisible(false);
    setRoundScore(null);
    setSessionResults([]);
    setSessionComplete(false);
    answerLockedRef.current = false;
    questionStartedAtRef.current = nowMilliseconds();
  }, [selectedMode]);

  function resetQuestionState() {
    setSelectedAnswer("");
    setHintVisible(false);
    setRoundScore(null);
    answerLockedRef.current = false;
    questionStartedAtRef.current = nowMilliseconds();
  }

  function handleHint() {
    if (hasAnswered) return;
    setHintVisible((current) => !current);
  }

  function handleAnswer(option: string) {
    if (!activeItem || !shouldAcceptSeniorsAnswer(answerLockedRef.current)) {
      return;
    }

    answerLockedRef.current = true;

    const answerIsCorrect = option === activeItem.correctAnswer;
    const elapsedSeconds = Math.max(
      1,
      Math.round((nowMilliseconds() - questionStartedAtRef.current) / 1000)
    );

    const scoreResult = calculateSeniorsScore({
      isCorrect: answerIsCorrect,
      completed: true,
      elapsedSeconds,
      hintUsed: hintVisible
    });

    recordSeniorsChallengeResult({
      sessionMode: selectedMode,
      challengeId: activeItem.challengeId,
      isCorrect: answerIsCorrect,
      score: scoreResult.overallScore,
      hintUsed: hintVisible,
      elapsedSeconds,
      practiceCategory: activeItem.categoryName
    });

    setSelectedAnswer(option);
    setRoundScore(scoreResult);
    setSessionResults((current) => [
      ...current,
      {
        challengeId: activeItem.challengeId,
        isCorrect: answerIsCorrect,
        score: scoreResult.overallScore,
        elapsedSeconds,
        practiceCategory: activeItem.categoryName,
        hintUsed: hintVisible
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
        const result = saveMasterySession("seniors", masterySessionIdRef.current, sessionResults.map(result => ({
          configurationId: result.challengeId, categoryName: result.practiceCategory,
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
    masterySessionIdRef.current = createMasterySessionId("seniors");
    masteryCommittedRef.current = false;
    setSpatialMode(true);
    setSessionCycle((current) => current + 1);
    setQuestionIndex(0);
    setSessionResults([]);
    setSessionComplete(false);
    resetQuestionState();
  }

  function handleReplay() {
    masterySessionIdRef.current = createMasterySessionId("seniors");
    masteryCommittedRef.current = false;
    setSessionCycle((current) => current + 1);
    setQuestionIndex(0);
    setSessionResults([]);
    setSessionComplete(false);
    resetQuestionState();
  }

  if (sessionItems.length === 0) {
    return (
      <section aria-labelledby="seniors-gameplay-heading" style={{ marginTop: "30px" }}>
        <h2 id="seniors-gameplay-heading" style={{ fontSize: "28px" }}>Practice session</h2>
        <p style={{ fontSize: "19px", lineHeight: 1.6 }}>
          No practice items are available for this session mode.
        </p>
      </section>
    );
  }

  if (sessionComplete) {
    const summary = getSeniorsSessionSummary(sessionResults);

    return (
      <section aria-labelledby="seniors-session-result-heading" style={{ marginTop: "30px" }}>
        {!spatialMode && selectedMode === "PatternConfidence" && (
          <button type="button" onClick={startSpatialSession}
            style={{ margin: "12px 0", padding: "13px 18px", borderRadius: "12px",
              border: "2px solid #1e40af", background: "#eff6ff", color: "#1e3a8a",
              fontWeight: 700, cursor: "pointer" }}>
            Start Everyday Navigation (3 visual puzzles)
          </button>
        )}
        <article
          style={{
            border: "1px solid #bbd7cc",
            borderRadius: "22px",
            padding: "24px",
            background: "#f0fdf8"
          }}
        >
          <p style={{ margin: "0 0 8px", color: "#166534", fontSize: "16px", fontWeight: 700 }}>
            Session complete - {selectedMode}
          </p>
          <h2
            id="seniors-session-result-heading"
            style={{ margin: "0 0 18px", fontSize: "30px", lineHeight: 1.2 }}
          >
            You completed this practice round.
          </h2>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))",
              gap: "12px"
            }}
          >
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Challenges completed</div>
              <strong style={{ fontSize: "24px" }}>{summary.challengesCompleted}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Correct answers</div>
              <strong style={{ fontSize: "24px" }}>{summary.correctAnswers}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Average score</div>
              <strong style={{ fontSize: "24px" }}>{summary.averageScore}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Confidence milestone</div>
              <strong style={{ fontSize: "20px" }}>{summary.confidenceMilestone}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Practice area</div>
              <strong style={{ fontSize: "20px" }}>{summary.practiceArea}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Measured time</div>
              <strong style={{ fontSize: "20px" }}>{summary.measuredSeconds}s</strong>
            </div>
          </div>

          <p style={{ margin: "18px 0 0", fontSize: "19px", lineHeight: 1.6, color: "#334155" }}>
            <strong>Recommended next step:</strong> {summary.recommendedNextStep}
          </p>

          <MasteryProgressPanel state={mastery} saved={masterySaved}
            focus={masteryDomainFor(sessionResults[0]?.practiceCategory ?? "", sessionResults[0]?.challengeId ?? "")} />

          <button
            type="button"
            onClick={handleReplay}
            style={{
              marginTop: "20px",
              minHeight: "52px",
              border: "1px solid #0f172a",
              borderRadius: "14px",
              padding: "12px 20px",
              background: "#0f172a",
              color: "#ffffff",
              fontSize: "18px",
              fontWeight: 700,
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
    <section aria-labelledby="seniors-gameplay-heading" style={{ marginTop: "30px" }}>
        {!spatialMode && selectedMode === "PatternConfidence" && (
          <button type="button" onClick={startSpatialSession}
            style={{ margin: "12px 0", padding: "13px 18px", borderRadius: "12px",
              border: "2px solid #1e40af", background: "#eff6ff", color: "#1e3a8a",
              fontWeight: 700, cursor: "pointer" }}>
            Start Everyday Navigation (3 visual puzzles)
          </button>
        )}
      <div style={{ marginBottom: "16px" }}>
        <p style={{ margin: "0 0 8px", color: "#475569", fontSize: "16px" }}>
          Challenge {questionIndex + 1} of {sessionItems.length} - {activeItem.categoryName}
        </p>
        <h2 id="seniors-gameplay-heading" style={{ margin: 0, fontSize: "28px" }}>
          Guided practice
        </h2>
      </div>

      <article
        style={{
          border: "1px solid #cbd5e1",
          borderRadius: "20px",
          padding: "24px",
          background: "#ffffff"
        }}
      >
        <p style={{ margin: "0 0 12px", color: "#475569", fontSize: "18px", lineHeight: 1.6 }}>
          {activeItem.objective}
        </p>
        <h3 style={{ whiteSpace: spatialMode ? "pre-wrap" : "normal", fontFamily: spatialMode ? "ui-monospace, monospace" : "inherit", margin: "0 0 20px", fontSize: "24px", lineHeight: 1.4 }}>
          {activeItem.prompt}
        </h3>

        <div style={{ display: "grid", gap: "12px" }}>
          {activeItem.options.map((option) => {
            const isSelected = selectedAnswer === option;

            return (
              <button
                key={option}
                type="button"
                disabled={hasAnswered}
                onClick={() => handleAnswer(option)}
                style={{
                  minHeight: "54px",
                  textAlign: "left",
                  border: isSelected ? "2px solid #0f172a" : "1px solid #cbd5e1",
                  borderRadius: "14px",
                  padding: "14px 16px",
                  background: isSelected ? "#e2e8f0" : "#f8fafc",
                  color: "#0f172a",
                  fontSize: "18px",
                  lineHeight: 1.4,
                  cursor: hasAnswered ? "default" : "pointer"
                }}
              >
                <span style={{ whiteSpace: spatialMode ? "pre" : "normal", fontFamily: spatialMode ? "ui-monospace, monospace" : "inherit", display: "block" }}>{option}</span>
              </button>
            );
          })}
        </div>

        <button
          type="button"
          disabled={hasAnswered}
          onClick={handleHint}
          style={{
            marginTop: "16px",
            minHeight: "48px",
            border: "1px solid #94a3b8",
            borderRadius: "14px",
            padding: "10px 16px",
            background: "#ffffff",
            color: "#334155",
            fontSize: "17px",
            cursor: hasAnswered ? "default" : "pointer"
          }}
        >
          {hintVisible ? "Hide hint" : "Show a helpful hint"}
        </button>

        {hintVisible && !hasAnswered && (
          <div
            style={{
              marginTop: "14px",
              padding: "14px 16px",
              borderRadius: "14px",
              background: "#eff6ff",
              color: "#1e3a8a",
              fontSize: "18px",
              lineHeight: 1.6
            }}
          >
            {activeItem.hint}
          </div>
        )}

        {!hasAnswered && (
          <p style={{ margin: "16px 0 0", color: "#475569", fontSize: "18px" }}>
            Take your time. Choose one answer when you are ready.
          </p>
        )}

        {hasAnswered && roundScore && (
          <>
            <div
              aria-live="polite"
              style={{
                marginTop: "20px",
                padding: "16px",
                borderRadius: "14px",
                background: isCorrect ? "#ecfdf5" : "#fff7ed",
                color: isCorrect ? "#065f46" : "#9a3412",
                fontSize: "18px",
                lineHeight: 1.6
              }}
            >
              <strong>{isCorrect ? "Nice work." : "Review and continue when ready."}</strong>{" "}
              {isCorrect
                ? activeItem.insight
                : `${activeItem.hint} Correct answer: ${activeItem.correctAnswer}.`}
            </div>

            <SeniorsPostSessionInsightPanel
              scoreResult={roundScore}
              isCorrect={isCorrect}
              itemInsight={activeItem.insight}
            />

            <button
              type="button"
              onClick={handleContinue}
              style={{
                marginTop: "20px",
                minHeight: "52px",
                border: "1px solid #0f172a",
                borderRadius: "14px",
                padding: "12px 20px",
                background: "#0f172a",
                color: "#ffffff",
                fontSize: "18px",
                fontWeight: 700,
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
