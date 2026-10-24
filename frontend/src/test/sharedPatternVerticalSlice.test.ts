import { describe, expect, it } from "vitest";
import {
  buildFreshPatternChallenge,
  buildPatternChallenge,
  getAdaptivePatternDifficulty
} from "../features/shared/patternChallengeEngine";
import {
  buildKidsPatternBuilderSession
} from "../features/kids/KidsGameplayPanel";
import {
  getKidsGameplayItemsForSession
} from "../features/kids/kidsGameplayContent";
import {
  buildAdultsPatternLogicSession
} from "../features/adults/AdultsGameplayPanel";
import {
  getAdultsGameplayItemsForSession
} from "../features/adults/adultsGameplayContent";
import {
  buildSeniorsPatternConfidenceSession
} from "../features/seniors/SeniorsGameplayPanel";
import {
  getSeniorsGameplayItemsForSession
} from "../features/seniors/seniorsGameplayContent";

describe("shared pattern engine three-age vertical slice", () => {
  it("generates deterministic valid pattern configurations", () => {
    const first = buildPatternChallenge("adults", "deterministic-pattern-proof", 3);
    const second = buildPatternChallenge("adults", "deterministic-pattern-proof", 3);

    expect(second).toEqual(first);
    expect(first.options).toContain(first.correctAnswer);
    expect(new Set(first.options).size).toBe(first.options.length);
    expect(first.configurationId.startsWith("PAT-A-D3-")).toBe(true);
  });

  it("avoids a recently exposed exact pattern configuration", () => {
    const first = buildFreshPatternChallenge({
      lane: "kids",
      baseSeed: "pattern-freshness-proof",
      difficulty: 2
    });
    const second = buildFreshPatternChallenge({
      lane: "kids",
      baseSeed: "pattern-freshness-proof",
      difficulty: 2,
      recentConfigurationIds: [first.configurationId]
    });

    expect(second.configurationId).not.toBe(first.configurationId);
  });

  it("uses conservative pattern difficulty with age-specific ceilings", () => {
    const strong = Array.from({ length: 5 }, () => ({
      isCorrect: true,
      score: 98,
      hintUsed: false
    }));
    const struggling = Array.from({ length: 5 }, () => ({
      isCorrect: false,
      score: 45,
      hintUsed: true
    }));

    expect(getAdaptivePatternDifficulty("adults", strong)).toBe(4);
    expect(getAdaptivePatternDifficulty("kids", strong)).toBe(3);
    expect(getAdaptivePatternDifficulty("seniors", strong)).toBe(3);
    expect(getAdaptivePatternDifficulty("adults", struggling)).toBe(1);
  });

  it("keeps Sequence Explorer and adds Pattern Builder to Kids Challenge", () => {
    const session = buildKidsPatternBuilderSession(
      getKidsGameplayItemsForSession("Challenge"),
      0,
      []
    );

    expect(session).toHaveLength(3);
    expect(session[0]?.certifiedId.startsWith("PAT-K-")).toBe(true);
    expect(session[0]?.categoryName).toBe("Pattern Builder");
    expect(session[1]?.certifiedId.startsWith("SEQ-K-")).toBe(true);
    expect(session[1]?.categoryName).toBe("Sequence Explorer");
    expect(new Set(session.map((item) => item.certifiedId)).size).toBe(3);
  });

  it("injects Pattern Logic into the Adults Deep session", () => {
    const session = buildAdultsPatternLogicSession(
      getAdultsGameplayItemsForSession("Deep"),
      0,
      []
    );

    expect(session).toHaveLength(3);
    expect(session[0]?.certifiedId.startsWith("PAT-A-")).toBe(true);
    expect(session[0]?.categoryName).toBe("Pattern Logic");
    expect(session[0]?.sessionProfile).toBe("Deep");
    expect(new Set(session.map((item) => item.certifiedId)).size).toBe(3);
  });

  it("injects Pattern Confidence into Seniors without speed pressure", () => {
    const session = buildSeniorsPatternConfidenceSession(
      getSeniorsGameplayItemsForSession("PatternConfidence"),
      0,
      []
    );

    expect(session).toHaveLength(3);
    expect(session[0]?.challengeId.startsWith("PAT-S-")).toBe(true);
    expect(session[0]?.categoryName).toBe("Pattern Confidence");
    expect(session[0]?.objective).toContain("without speed pressure");
    expect(session[0]?.prompt).toContain("take your time");
    expect(new Set(session.map((item) => item.challengeId)).size).toBe(3);
  });

  it("rotates three distinct reasoning structures per age and difficulty", () => {
    for (const lane of ["kids", "adults", "seniors"] as const) {
      for (const difficulty of [1, 2, 3] as const) {
        const challenges = [0, 1, 2].map((variationIndex) =>
          buildFreshPatternChallenge({
            lane, difficulty, variationIndex,
            baseSeed: `${lane}-${difficulty}-${variationIndex}`
          })
        );
        expect(new Set(challenges.map((item) => item.patternKind)).size).toBe(3);
        expect(new Set(challenges.map((item) => item.configurationId)).size).toBe(3);
        for (const item of challenges) {
          expect(item.options).toContain(item.correctAnswer);
          expect(new Set(item.options).size).toBe(item.options.length);
          expect(item.sequence.length).toBeGreaterThanOrEqual(4);
        }
      }
    }
    const advanced = [0, 1, 2].map((variationIndex) =>
      buildPatternChallenge("adults", `advanced-${variationIndex}`, 4, variationIndex)
    );
    expect(new Set(advanced.map((item) => item.patternKind)).size).toBe(3);
  });

  it("preserves one Sequence Explorer and avoids recent exact pattern configurations", () => {
    const sessionIds: string[] = [];
    const kinds: string[] = [];
    for (let cycle = 0; cycle < 3; cycle += 1) {
      const history = sessionIds.map((certifiedId) => ({
        certifiedId, isCorrect: false, score: 50
      })) as Parameters<typeof buildKidsPatternBuilderSession>[2];
      const session = buildKidsPatternBuilderSession(
        getKidsGameplayItemsForSession("Challenge"), cycle, history
      );
      expect(session[0]?.categoryName).toBe("Pattern Builder");
      expect(session[1]?.categoryName).toBe("Sequence Explorer");
      const id = session[0]!.certifiedId;
      expect(sessionIds).not.toContain(id);
      const expected = buildFreshPatternChallenge({
        lane: "kids", difficulty: 1,
        baseSeed: `kids-pattern-builder-${cycle}-${history.length}`,
        variationIndex: sessionIds.length + cycle,
        recentConfigurationIds: sessionIds
      });
      expect(id).toBe(expected.configurationId);
      kinds.push(expected.patternKind);
      sessionIds.push(id);
    }
    expect(new Set(kinds).size).toBe(3);
  });

  it("does not overlap static Deep and Pattern Confidence items across three cycles with sufficient pools", () => {
    const adults = getAdultsGameplayItemsForSession("Deep");
    const seniors = getSeniorsGameplayItemsForSession("PatternConfidence");
    if (adults.length >= 6) {
      const ids = [0, 1, 2].flatMap((cycle) =>
        buildAdultsPatternLogicSession(adults, cycle, []).slice(1).map((item) => item.certifiedId)
      );
      expect(new Set(ids).size).toBe(ids.length);
    }
    if (seniors.length >= 6) {
      const ids = [0, 1, 2].flatMap((cycle) =>
        buildSeniorsPatternConfidenceSession(seniors, cycle, []).slice(1).map((item) => item.challengeId)
      );
      expect(new Set(ids).size).toBe(ids.length);
    }
  });

});
