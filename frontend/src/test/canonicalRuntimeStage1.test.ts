import { describe, expect, it } from "vitest";
import { getMindLabRouteTarget } from "../MindLabModeRouter";
import { getKidsGameplayItemsForSession } from "../features/kids/kidsGameplayContent";
import { buildKidsSessionItems } from "../features/kids/KidsGameplayPanel";
import { kidsSessionModes } from "../features/kids/kidsSessionModes";

describe("canonical runtime stage 1", () => {
  it("preserves the accepted Kids feature lane while later stages activate additional age lanes", () => {
    expect(getMindLabRouteTarget("kids")).toBe("kids-feature");
    expect(getMindLabRouteTarget("adults")).toBe("adults-feature");
    expect(getMindLabRouteTarget("seniors")).toBe("seniors-feature");
    expect(getMindLabRouteTarget("unknown")).toBe("invalid");
  });

  it("has at least three Kids gameplay items for every selectable mode", () => {
    for (const mode of kidsSessionModes) {
      expect(getKidsGameplayItemsForSession(mode.id).length).toBeGreaterThanOrEqual(3);
    }
  });

  it("builds a three-challenge Kids session without duplicate challenge ids", () => {
    const items = getKidsGameplayItemsForSession("PlayFocus");
    const session = buildKidsSessionItems(items, 0);
    const ids = session.map((item) => item.certifiedId);

    expect(session).toHaveLength(3);
    expect(new Set(ids).size).toBe(3);
  });

  it("rotates the first challenge on replay when more than three items exist", () => {
    const items = getKidsGameplayItemsForSession("PlayFocus");
    const firstSession = buildKidsSessionItems(items, 0);
    const replaySession = buildKidsSessionItems(items, 1);

    expect(firstSession[0]?.certifiedId).not.toBe(replaySession[0]?.certifiedId);
  });
});
