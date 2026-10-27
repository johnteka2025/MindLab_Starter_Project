import { describe, expect, it } from "vitest";
import { buildKidsShapeNavigatorSession } from "../features/kids/KidsGameplayPanel";
import { buildAdultsSpatialReasoningSession } from "../features/adults/AdultsGameplayPanel";
import { buildSeniorsEverydayNavigationSession } from "../features/seniors/SeniorsGameplayPanel";

// Internal prototype only: correct family-specific calibration and preserve fresh play.
describe("Three-age spatial quality and freshness - targeted regression", () => {
  const unrelated = (prefix: string) => Array.from({ length: 5 }, (_, i) => ({
    certifiedId: `${prefix}-${i}`, challengeId: `${prefix}-${i}`,
    isCorrect: true, score: 100, hintUsed: false
  }));
  const spatial = (prefix: string) => Array.from({ length: 3 }, (_, i) => ({
    certifiedId: `${prefix}-${i}`, challengeId: `${prefix}-${i}`,
    isCorrect: true, score: 100, hintUsed: false
  }));

  it("does not escalate a new spatial skill based on unrelated perfect pattern games", () => {
    const kids = buildKidsShapeNavigatorSession(1,
      unrelated("PAT-K") as unknown as Parameters<typeof buildKidsShapeNavigatorSession>[1]);
    const adults = buildAdultsSpatialReasoningSession(1,
      unrelated("PAT-A") as unknown as Parameters<typeof buildAdultsSpatialReasoningSession>[1]);
    const seniors = buildSeniorsEverydayNavigationSession(1,
      unrelated("PAT-S") as unknown as Parameters<typeof buildSeniorsEverydayNavigationSession>[1]);
    expect(kids.every(x => x.difficulty === "Adaptive 1")).toBe(true);
    expect(adults.every(x => x.difficulty === "Adaptive 1")).toBe(true);
    expect(seniors.every(x => x.stage === "S1")).toBe(true);
  });

  it("uses spatial evidence even when five unrelated games are more recent", () => {
    const kids = buildKidsShapeNavigatorSession(1,
      [...unrelated("PAT-K"), ...spatial("SPC-K")] as unknown as Parameters<typeof buildKidsShapeNavigatorSession>[1]);
    const adults = buildAdultsSpatialReasoningSession(1,
      [...unrelated("PAT-A"), ...spatial("SPC-A")] as unknown as Parameters<typeof buildAdultsSpatialReasoningSession>[1]);
    const seniors = buildSeniorsEverydayNavigationSession(1,
      [...unrelated("PAT-S"), ...spatial("SPC-S")] as unknown as Parameters<typeof buildSeniorsEverydayNavigationSession>[1]);
    expect(kids.every(x => x.difficulty === "Adaptive 3")).toBe(true);
    expect(adults.every(x => x.difficulty === "Adaptive 3")).toBe(true);
    expect(seniors.every(x => x.stage === "S3")).toBe(true);
  });

  it("does not replay the exact spatial configuration from an immediately preceding session", () => {
    const firstKids = buildKidsShapeNavigatorSession(1, []);
    const firstAdults = buildAdultsSpatialReasoningSession(1, []);
    const firstSeniors = buildSeniorsEverydayNavigationSession(1, []);
    const hist = (ids: string[], key: "certifiedId" | "challengeId") => ids.map(id => ({
      [key]: id, isCorrect: false, score: 0, hintUsed: false
    }));
    const secondKids = buildKidsShapeNavigatorSession(1,
      hist(firstKids.map(x => x.certifiedId), "certifiedId") as unknown as Parameters<typeof buildKidsShapeNavigatorSession>[1]);
    const secondAdults = buildAdultsSpatialReasoningSession(1,
      hist(firstAdults.map(x => x.certifiedId), "certifiedId") as unknown as Parameters<typeof buildAdultsSpatialReasoningSession>[1]);
    const secondSeniors = buildSeniorsEverydayNavigationSession(1,
      hist(firstSeniors.map(x => x.challengeId), "challengeId") as unknown as Parameters<typeof buildSeniorsEverydayNavigationSession>[1]);
    expect(firstKids.filter(x => secondKids.some(y => y.certifiedId === x.certifiedId))).toHaveLength(0);
    expect(firstAdults.filter(x => secondAdults.some(y => y.certifiedId === x.certifiedId))).toHaveLength(0);
    expect(firstSeniors.filter(x => secondSeniors.some(y => y.challengeId === x.challengeId))).toHaveLength(0);
  });
});
