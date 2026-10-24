import { describe, expect, it } from "vitest";
import {
  buildPlanningChallenge,
  buildFreshPlanningChallenge,
  getAdaptivePlanningDifficulty
} from "../features/shared/planningChallengeEngine";
import { buildKidsPathPlannerSession } from "../features/kids/KidsGameplayPanel";
import { getKidsGameplayItemsForSession } from "../features/kids/kidsGameplayContent";
import { buildAdultsStrategicDecisionsSession } from "../features/adults/AdultsGameplayPanel";
import { getAdultsGameplayItemsForSession } from "../features/adults/adultsGameplayContent";
import { buildSeniorsEverydayPlanningSession } from "../features/seniors/SeniorsGameplayPanel";
import { getSeniorsGameplayItemsForSession } from "../features/seniors/seniorsGameplayContent";

describe("Family 4 planning, three-age vertical slice", () => {
  it("creates deterministic, valid choices for each age", () => {
    for (const lane of ["kids", "adults", "seniors"] as const) {
      const first = buildPlanningChallenge(lane, `${lane}-deterministic`, 2, 1);
      const again = buildPlanningChallenge(lane, `${lane}-deterministic`, 2, 1);
      expect(again).toEqual(first);
      expect(first.configurationId).toMatch(/^PLN-[KAS]-D2-[A-F0-9]{8}$/);
      expect(first.options).toHaveLength(3);
      expect(new Set(first.options).size).toBe(first.options.length);
      expect(first.options).toContain(first.correctAnswer);
      expect(first.timed).toBe(false);
    }
  });

  it("rotates six distinct planning scenarios per age rather than reshuffling one question", () => {
    for (const lane of ["kids", "adults", "seniors"] as const) {
      const scenarios = Array.from({ length: 6 }, (_, index) =>
        buildPlanningChallenge(lane, `${lane}-var-${index}`, 1, index)
      );
      expect(new Set(scenarios.map((item) => item.scenarioKind)).size).toBe(6);
      expect(new Set(scenarios.map((item) => item.configurationId)).size).toBe(6);
      expect(scenarios.every((item) => item.options.includes(item.correctAnswer))).toBe(true);
    }
  });

  it("avoids recently exposed exact configurations", () => {
    const first = buildFreshPlanningChallenge({ lane: "kids", baseSeed: "stable", difficulty: 2, variationIndex: 2 });
    const second = buildFreshPlanningChallenge({
      lane: "kids", baseSeed: "stable", difficulty: 2, variationIndex: 2,
      recentConfigurationIds: [first.configurationId]
    });
    expect(second.configurationId).not.toBe(first.configurationId);
  });

  it("adapts number of choices and age-lane difficulty ceilings", () => {
    for (const lane of ["kids", "adults", "seniors"] as const) {
      expect(buildPlanningChallenge(lane, "easy", 1).options).toHaveLength(2);
      expect(buildPlanningChallenge(lane, "medium", 2).options).toHaveLength(3);
      expect(buildPlanningChallenge(lane, "hard", 3).options).toHaveLength(4);
    }
    const high = Array.from({ length: 5 }, () => ({ isCorrect: true, score: 99, hintUsed: false }));
    const low = Array.from({ length: 5 }, () => ({ isCorrect: false, score: 20, hintUsed: true }));
    expect(getAdaptivePlanningDifficulty("adults", high)).toBe(4);
    expect(getAdaptivePlanningDifficulty("kids", high)).toBe(3);
    expect(getAdaptivePlanningDifficulty("seniors", high)).toBe(3);
    expect(getAdaptivePlanningDifficulty("adults", low)).toBe(1);
    expect(buildPlanningChallenge("kids", "clamped", 4).difficulty).toBe(3);
  });

  it("adds Kids Path Planner after accepted Pattern Builder and Sequence Explorer", () => {
    const session = buildKidsPathPlannerSession(getKidsGameplayItemsForSession("Challenge"), 0, []);
    expect(session).toHaveLength(3);
    expect(session.map((item) => item.categoryName)).toEqual([
      "Pattern Builder", "Sequence Explorer", "Path Planner"
    ]);
    expect(session[0]?.certifiedId).toMatch(/^PAT-K-/);
    expect(session[1]?.certifiedId).toMatch(/^SEQ-K-/);
    expect(session[2]?.certifiedId).toMatch(/^PLN-K-/);
    expect(session[2]?.options).toContain(session[2]?.correctAnswer);
  });

  it("adds Adults Strategic Decisions to Deep while keeping Pattern Logic first", () => {
    const session = buildAdultsStrategicDecisionsSession(getAdultsGameplayItemsForSession("Deep"), 0, []);
    expect(session).toHaveLength(3);
    expect(session[0]?.categoryName).toBe("Pattern Logic");
    expect(session[1]?.categoryName).toBe("Strategic Decisions");
    expect(session[1]?.sessionProfile).toBe("Deep");
    expect(session[1]?.certifiedId).toMatch(/^PLN-A-/);
    expect(session[1]?.timerPolicy).toBe("OffByDefault");
  });

  it("adds Seniors Everyday Planning without forced speed", () => {
    const session = buildSeniorsEverydayPlanningSession(
      getSeniorsGameplayItemsForSession("PatternConfidence"), 0, []
    );
    expect(session).toHaveLength(3);
    expect(session[0]?.categoryName).toBe("Pattern Confidence");
    expect(session[1]?.categoryName).toBe("Everyday Planning");
    expect(session[1]?.sessionProfile).toBe("PatternConfidence");
    expect(session[1]?.challengeId).toMatch(/^PLN-S-/);
    expect(session[1]?.objective).toContain("without speed pressure");
    expect(session[1]?.prompt).toContain("Take your time");
  });

  it("rotates Family 4 scenario structures during three consecutive replays", () => {
    for (const lane of ["kids", "adults", "seniors"] as const) {
      const generated = Array.from({ length: 3 }, (_, cycle) =>
        buildFreshPlanningChallenge({
          lane, baseSeed: `${lane}-session-${cycle}`, difficulty: 1, variationIndex: cycle
        })
      );
      expect(new Set(generated.map((item) => item.configurationId)).size).toBe(3);
      expect(new Set(generated.map((item) => item.scenarioKind)).size).toBe(3);
    }
  });

  it("maintains a unique correct choice across sampled seeds, difficulties and ages", () => {
    for (const lane of ["kids", "adults", "seniors"] as const) {
      for (const level of [1, 2, 3] as const) {
        for (let cycle = 0; cycle < 24; cycle++) {
          const item = buildPlanningChallenge(lane, `varied-seed-${cycle}`, level, cycle);
          expect(item.options.filter((option) => option === item.correctAnswer)).toHaveLength(1);
          expect(new Set(item.options).size).toBe(item.options.length);
        }
      }
    }
  });
});
