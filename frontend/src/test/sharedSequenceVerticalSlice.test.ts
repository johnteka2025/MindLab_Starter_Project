import { describe, expect, it } from "vitest";
import {
  buildFreshSequenceChallenge,
  buildSequenceChallenge,
  getAdaptiveSequenceDifficulty
} from "../features/shared/sequenceChallengeEngine";
import {
  buildKidsSequenceExplorerSession
} from "../features/kids/KidsGameplayPanel";
import {
  getKidsGameplayItemsForSession
} from "../features/kids/kidsGameplayContent";
import {
  buildAdultsWorkingMemorySession
} from "../features/adults/AdultsGameplayPanel";
import {
  getAdultsGameplayItemsForSession
} from "../features/adults/adultsGameplayContent";
import {
  buildSeniorsGuidedRecallSession
} from "../features/seniors/SeniorsGameplayPanel";
import {
  getSeniorsGameplayItemsForSession
} from "../features/seniors/seniorsGameplayContent";

describe("shared sequence engine three-age vertical slice", () => {
  it("generates deterministic valid configurations", () => {
    const first = buildSequenceChallenge("adults", "deterministic-proof", 3);
    const second = buildSequenceChallenge("adults", "deterministic-proof", 3);

    expect(second).toEqual(first);
    expect(first.sequence[first.recallIndex]).toBe(first.correctAnswer);
    expect(first.options).toContain(first.correctAnswer);
    expect(new Set(first.options).size).toBe(first.options.length);
  });

  it("avoids a recently exposed exact configuration", () => {
    const first = buildFreshSequenceChallenge({
      lane: "kids",
      baseSeed: "freshness-proof",
      difficulty: 2
    });
    const second = buildFreshSequenceChallenge({
      lane: "kids",
      baseSeed: "freshness-proof",
      difficulty: 2,
      recentConfigurationIds: [first.configurationId]
    });

    expect(second.configurationId).not.toBe(first.configurationId);
  });

  it("uses conservative adaptive difficulty with age-specific ceilings", () => {
    const strong = Array.from({ length: 5 }, () => ({
      isCorrect: true,
      score: 98,
      hintUsed: false
    }));
    const struggling = Array.from({ length: 5 }, () => ({
      isCorrect: false,
      score: 50,
      hintUsed: true
    }));

    expect(getAdaptiveSequenceDifficulty("adults", strong)).toBe(4);
    expect(getAdaptiveSequenceDifficulty("kids", strong)).toBe(3);
    expect(getAdaptiveSequenceDifficulty("seniors", strong)).toBe(3);
    expect(getAdaptiveSequenceDifficulty("adults", struggling)).toBe(1);
  });

  it("injects Sequence Explorer into the Kids Challenge session", () => {
    const session = buildKidsSequenceExplorerSession(
      getKidsGameplayItemsForSession("Challenge"),
      0,
      []
    );

    expect(session).toHaveLength(3);
    expect(session[0]?.certifiedId.startsWith("SEQ-K-")).toBe(true);
    expect(session[0]?.categoryName).toBe("Sequence Explorer");
    expect(new Set(session.map((item) => item.certifiedId)).size).toBe(3);
  });

  it("injects Working Memory into the Adults QuickFocus session", () => {
    const session = buildAdultsWorkingMemorySession(
      getAdultsGameplayItemsForSession("QuickFocus"),
      0,
      []
    );

    expect(session).toHaveLength(3);
    expect(session[0]?.certifiedId.startsWith("SEQ-A-")).toBe(true);
    expect(session[0]?.categoryName).toBe("Working Memory");
    expect(new Set(session.map((item) => item.certifiedId)).size).toBe(3);
  });

  it("injects Guided Recall into the Seniors GuidedMemory session", () => {
    const session = buildSeniorsGuidedRecallSession(
      getSeniorsGameplayItemsForSession("GuidedMemory"),
      0,
      []
    );

    expect(session).toHaveLength(3);
    expect(session[0]?.challengeId.startsWith("SEQ-S-")).toBe(true);
    expect(session[0]?.categoryName).toBe("Guided Recall");
    expect(new Set(session.map((item) => item.challengeId)).size).toBe(3);
  });
});
