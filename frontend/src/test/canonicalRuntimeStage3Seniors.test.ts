import { describe, expect, it } from "vitest";
import { getMindLabRouteTarget } from "../MindLabModeRouter";
import { seniorsAgeModeFoundation } from "../ageModes/seniorsAgeModeFoundation";
import { seniorsGameplayAccessibilityProgress } from "../ageModes/seniorsGameplayAccessibilityProgress";
import {
  getSeniorsGameplayItemsForSession,
  seniorsGameplayItems
} from "../features/seniors/seniorsGameplayContent";
import {
  buildSeniorsSessionItems,
  shouldAcceptSeniorsAnswer
} from "../features/seniors/SeniorsGameplayPanel";
import {
  buildSeniorsPersistenceRecord
} from "../features/seniors/seniorsPersistence";
import {
  calculateSeniorsScore
} from "../features/seniors/seniorsScoring";
import {
  getSeniorsSessionSummary
} from "../features/seniors/seniorsPostSessionInsights";
import { seniorsSessionModes } from "../features/seniors/seniorsSessionModes";

describe("canonical runtime stage 3 seniors", () => {
  it("routes Seniors to the canonical feature lane", () => {
    expect(getMindLabRouteTarget("seniors")).toBe("seniors-feature");
  });

  it("preserves the accepted Kids and Adults canonical routes", () => {
    expect(getMindLabRouteTarget("kids")).toBe("kids-feature");
    expect(getMindLabRouteTarget("adults")).toBe("adults-feature");
    expect(getMindLabRouteTarget("unknown")).toBe("invalid");
  });

  it("provides exactly three items for each of the four Seniors modes", () => {
    expect(seniorsSessionModes).toHaveLength(4);
    expect(seniorsGameplayItems).toHaveLength(12);

    for (const mode of seniorsSessionModes) {
      expect(getSeniorsGameplayItemsForSession(mode.id)).toHaveLength(3);
    }
  });

  it("builds a three-challenge Seniors session without duplicate challenge ids", () => {
    const items = getSeniorsGameplayItemsForSession("GuidedMemory");
    const session = buildSeniorsSessionItems(items, 0);
    const ids = session.map((item) => item.challengeId);

    expect(session).toHaveLength(3);
    expect(new Set(ids).size).toBe(3);
  });

  it("rotates the first Seniors challenge on replay", () => {
    const items = getSeniorsGameplayItemsForSession("PatternConfidence");
    const firstSession = buildSeniorsSessionItems(items, 0);
    const replaySession = buildSeniorsSessionItems(items, 1);

    expect(firstSession[0]?.challengeId).not.toBe(replaySession[0]?.challengeId);
  });

  it("blocks a second answer after the answer lock is set", () => {
    expect(shouldAcceptSeniorsAnswer(false)).toBe(true);
    expect(shouldAcceptSeniorsAnswer(true)).toBe(false);
  });

  it("weights accuracy while keeping elapsed time informational only", () => {
    const fastCorrect = calculateSeniorsScore({
      isCorrect: true,
      completed: true,
      elapsedSeconds: 10
    });

    const slowCorrect = calculateSeniorsScore({
      isCorrect: true,
      completed: true,
      elapsedSeconds: 300
    });

    const incorrect = calculateSeniorsScore({
      isCorrect: false,
      completed: true,
      elapsedSeconds: 10
    });

    expect(fastCorrect.overallScore).toBe(slowCorrect.overallScore);
    expect(fastCorrect.overallScore).toBeGreaterThan(incorrect.overallScore);
  });

  it("builds the required minimal persistence record only", () => {
    const record = buildSeniorsPersistenceRecord({
      sessionMode: "GuidedMemory",
      challengeId: "S-MEM-S1-001",
      isCorrect: true,
      score: 100,
      hintUsed: false,
      elapsedSeconds: 24,
      practiceCategory: "Memory Support",
      completedAt: "2026-09-27T20:00:00.000Z"
    });

    expect(Object.keys(record).sort()).toEqual([
      "challengeId",
      "completedAt",
      "elapsedSeconds",
      "hintUsed",
      "isCorrect",
      "practiceCategory",
      "score",
      "sessionMode"
    ].sort());
  });

  it("creates a complete session summary after three challenges", () => {
    const summary = getSeniorsSessionSummary([
      {
        challengeId: "1",
        isCorrect: true,
        score: 100,
        elapsedSeconds: 20,
        practiceCategory: "Memory Support"
      },
      {
        challengeId: "2",
        isCorrect: false,
        score: 70,
        elapsedSeconds: 30,
        practiceCategory: "Focus & Attention"
      },
      {
        challengeId: "3",
        isCorrect: true,
        score: 100,
        elapsedSeconds: 25,
        practiceCategory: "Pattern Confidence"
      }
    ]);

    expect(summary.challengesCompleted).toBe(3);
    expect(summary.correctAnswers).toBe(2);
    expect(summary.confidenceMilestone.length).toBeGreaterThan(0);
    expect(summary.practiceArea).toBe("Focus & Attention");
    expect(summary.recommendedNextStep.length).toBeGreaterThan(0);
  });

  it("preserves the Seniors accessibility and supportive-content contract", () => {
    expect(seniorsAgeModeFoundation.uxTone).toBe("encouraging_clear_respectful_non_childlike");
    expect(seniorsGameplayAccessibilityProgress.accessibilitySupports).toEqual(
      expect.arrayContaining([
        "larger_readable_text",
        "clear_plain_labels",
        "reduced_visual_clutter",
        "low_pressure_guided_pacing",
        "respectful_encouraging_copy"
      ])
    );
    expect(seniorsGameplayItems.every((item) => item.hint.trim().length > 0)).toBe(true);
    expect(getSeniorsGameplayItemsForSession("CalmReview")).toHaveLength(3);
  });
});
