import { describe, expect, it } from "vitest";
import {
  buildFocusChallenge,
  buildFreshFocusChallenge,
  getAdaptiveFocusDifficulty
} from "../features/shared/focusChallengeEngine";
import {
  buildKidsFocusFinderSession
} from "../features/kids/KidsGameplayPanel";
import {
  getKidsGameplayItemsForSession
} from "../features/kids/kidsGameplayContent";
import {
  buildAdultsQuickFocusEnhancedSession
} from "../features/adults/AdultsGameplayPanel";
import {
  getAdultsGameplayItemsForSession
} from "../features/adults/adultsGameplayContent";
import {
  buildSeniorsFocusFilterSession
} from "../features/seniors/SeniorsGameplayPanel";
import {
  getSeniorsGameplayItemsForSession
} from "../features/seniors/seniorsGameplayContent";

describe("shared focus engine three-age vertical slice", () => {
  it("generates deterministic valid focus configurations", () => {
    const first = buildFocusChallenge("adults", "deterministic-focus-proof", 3);
    const second = buildFocusChallenge("adults", "deterministic-focus-proof", 3);

    expect(second).toEqual(first);
    expect(first.options).toContain(first.correctAnswer);
    expect(new Set(first.options).size).toBe(first.options.length);
    expect(first.configurationId.startsWith("FOC-A-D3-")).toBe(true);
  });

  it("avoids a recently exposed exact focus configuration", () => {
    const first = buildFreshFocusChallenge({
      lane: "kids",
      baseSeed: "focus-freshness-proof",
      difficulty: 2
    });
    const second = buildFreshFocusChallenge({
      lane: "kids",
      baseSeed: "focus-freshness-proof",
      difficulty: 2,
      recentConfigurationIds: [first.configurationId]
    });

    expect(second.configurationId).not.toBe(first.configurationId);
  });

  it("uses conservative focus difficulty with age-specific ceilings", () => {
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

    expect(getAdaptiveFocusDifficulty("adults", strong)).toBe(4);
    expect(getAdaptiveFocusDifficulty("kids", strong)).toBe(3);
    expect(getAdaptiveFocusDifficulty("seniors", strong)).toBe(3);
    expect(getAdaptiveFocusDifficulty("adults", struggling)).toBe(1);
  });

  it("injects Focus Finder into the Kids PlayFocus session", () => {
    const session = buildKidsFocusFinderSession(
      getKidsGameplayItemsForSession("PlayFocus"),
      0,
      []
    );

    expect(session).toHaveLength(3);
    expect(session[0]?.certifiedId.startsWith("FOC-K-")).toBe(true);
    expect(session[0]?.categoryName).toBe("Focus Finder");
    expect(new Set(session.map((item) => item.certifiedId)).size).toBe(3);
  });

  it("keeps Working Memory and adds Selective Attention to Adults QuickFocus", () => {
    const session = buildAdultsQuickFocusEnhancedSession(
      getAdultsGameplayItemsForSession("QuickFocus"),
      0,
      []
    );

    expect(session).toHaveLength(3);
    expect(session[0]?.certifiedId.startsWith("SEQ-A-")).toBe(true);
    expect(session[0]?.categoryName).toBe("Working Memory");
    expect(session[1]?.certifiedId.startsWith("FOC-A-")).toBe(true);
    expect(session[1]?.categoryName).toBe("Selective Attention");
    expect(new Set(session.map((item) => item.certifiedId)).size).toBe(3);
  });

  it("injects Focus & Filter into the Seniors FocusAttention session", () => {
    const session = buildSeniorsFocusFilterSession(
      getSeniorsGameplayItemsForSession("FocusAttention"),
      0,
      []
    );

    expect(session).toHaveLength(3);
    expect(session[0]?.challengeId.startsWith("FOC-S-")).toBe(true);
    expect(session[0]?.categoryName).toBe("Focus & Filter");
    expect(session[0]?.objective).toContain("without speed pressure");
    expect(new Set(session.map((item) => item.challengeId)).size).toBe(3);
  });
});
