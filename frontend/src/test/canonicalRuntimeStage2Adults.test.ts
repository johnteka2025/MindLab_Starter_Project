import { describe, expect, it } from "vitest";
import { getMindLabRouteTarget } from "../MindLabModeRouter";
import {
  adultsGameplayItems,
  getAdultsGameplayItemsForSession
} from "../features/adults/adultsGameplayContent";
import {
  buildAdultsSessionItems,
  getExpectedAdultsTimeSeconds
} from "../features/adults/AdultsGameplayPanel";
import { calculateAdultsScore } from "../features/adults/adultsScoring";
import { adultsSessionModes } from "../features/adults/adultsSessionModes";

describe("canonical runtime stage 2 adults", () => {
  it("preserves Adults routing while Seniors activates its canonical feature lane", () => {
    expect(getMindLabRouteTarget("kids")).toBe("kids-feature");
    expect(getMindLabRouteTarget("adults")).toBe("adults-feature");
    expect(getMindLabRouteTarget("seniors")).toBe("seniors-feature");
  });

  it("provides at least three gameplay items for every Adults session mode", () => {
    for (const mode of adultsSessionModes) {
      expect(getAdultsGameplayItemsForSession(mode.id).length).toBeGreaterThanOrEqual(3);
    }
  });

  it("builds a three-challenge Adults session without duplicate challenge ids", () => {
    const items = getAdultsGameplayItemsForSession("QuickFocus");
    const session = buildAdultsSessionItems(items, 0);
    const ids = session.map((item) => item.certifiedId);

    expect(session).toHaveLength(3);
    expect(new Set(ids).size).toBe(3);
  });

  it("rotates the first Adults challenge on replay", () => {
    const items = getAdultsGameplayItemsForSession("Standard");
    const firstSession = buildAdultsSessionItems(items, 0);
    const replaySession = buildAdultsSessionItems(items, 1);

    expect(firstSession[0]?.certifiedId).not.toBe(replaySession[0]?.certifiedId);
  });

  it("provides usable hints and a complete Recovery content lane", () => {
    const recoveryItems = getAdultsGameplayItemsForSession("Recovery");

    expect(recoveryItems).toHaveLength(3);
    expect(adultsGameplayItems.every((item) => item.hint.trim().length > 0)).toBe(true);
  });

  it("uses measured elapsed time as an input to scoring", () => {
    const fastScore = calculateAdultsScore({
      isCorrect: true,
      selectedAnswer: "A",
      correctAnswer: "A",
      expectedTimeSeconds: 60,
      actualTimeSeconds: 30,
      completed: true,
      firstTrySuccess: true
    });

    const slowScore = calculateAdultsScore({
      isCorrect: true,
      selectedAnswer: "A",
      correctAnswer: "A",
      expectedTimeSeconds: 60,
      actualTimeSeconds: 120,
      completed: true,
      firstTrySuccess: true
    });

    expect(fastScore.efficiencyScore).toBeGreaterThan(slowScore.efficiencyScore);
    expect(getExpectedAdultsTimeSeconds("Deep")).toBeGreaterThan(getExpectedAdultsTimeSeconds("QuickFocus"));
  });
});
