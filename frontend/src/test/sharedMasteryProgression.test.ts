import { describe, expect, it } from "vitest";
import {
  applyMasterySession, coerceMasteryState, describeMastery, masteryDomainFor,
  masteryStorageKey, newMasteryState, readMasteryState, saveMasterySession
} from "../features/shared/masteryProgression";

describe("Three-age earned mastery, provisional internal prototype", () => {
  const subjects = ["kids", "adults", "seniors"] as const;
  const labels = ["Shape Navigator", "Spatial Reasoning", "Everyday Navigation"] as const;
  const prefix = ["SPC-K", "SPC-A", "SPC-S"] as const;

  it("keeps all lanes separate with all five original skill domains", () => {
    for (const lane of subjects) {
      const state = newMasteryState(lane);
      expect(state.lane).toBe(lane);
      expect(describeMastery(state)).toHaveLength(5);
      expect(describeMastery(state).every(x => x.level === "Foundation")).toBe(true);
      expect(masteryStorageKey(lane)).toContain(lane);
    }
  });

  it("matches only known accepted families; no invented legacy domain", () => {
    expect(masteryDomainFor("Working Memory", "SEQ-A-1")).toBe("memory");
    expect(masteryDomainFor("Focus & Filter", "FOC-S-1")).toBe("attention");
    expect(masteryDomainFor("Pattern Builder", "PAT-K-1")).toBe("pattern");
    expect(masteryDomainFor("Everyday Planning", "PLN-S-1")).toBe("planning");
    expect(masteryDomainFor("Shape Navigator", "SPC-K-1")).toBe("spatial");
    expect(masteryDomainFor("Unmapped content", "legacy-1")).toBeNull();
  });

  it("does not promote from one perfect round and promotes only after repeated distinct sessions", () => {
    subjects.forEach((lane, index) => {
      let state = newMasteryState(lane);
      for (let session = 1; session <= 3; session++) {
        const trials = Array.from({ length: 3 }, (_, n) => ({
          configurationId: `${prefix[index]}-${session}-${n}`,
          categoryName: labels[index], isCorrect: true, hintUsed: false
        }));
        state = applyMasterySession(state, `${lane}-session-${session}`, trials);
        expect(state.domains.spatial?.level).toBe(session === 3 ? 1 : 0);
      }
      expect(state.domains.spatial?.uniqueCorrectIds).toHaveLength(9);
      expect(state.domains.memory).toBeUndefined();
      expect(describeMastery(state).find(x => x.domain === "spatial")?.level).toBe("Developing");
    });
  });

  it("demands multisession evidence for the next skill tier", () => {
    let state = newMasteryState("adults");
    for (let s = 0; s < 6; s++) {
      state = applyMasterySession(state, `session-${s}`, Array.from({ length: 3 }, (_, i) => ({
        configurationId: `PAT-A-${s}-${i}`, categoryName: "Pattern Logic", isCorrect: true, hintUsed: false
      })));
    }
    expect(state.domains.pattern?.level).toBe(2);
    expect(describeMastery(state).find(x => x.domain === "pattern")?.level).toBe("Skilled");
    expect(state.domains.pattern?.sessions).toBe(6);
  });

  it("hint-only success does not establish independent mastery", () => {
    let state = newMasteryState("seniors");
    for (let s = 0; s < 6; s++) {
      state = applyMasterySession(state, `s-${s}`, Array.from({ length: 3 }, (_, i) => ({
        configurationId: `SPC-S-${s}-${i}`, categoryName: "Everyday Navigation", isCorrect: true, hintUsed: true
      })));
    }
    expect(state.domains.spatial?.level).toBe(0);
  });

  it("one poor session never removes a previously earned level", () => {
    let state = newMasteryState("kids");
    for (let s = 0; s < 3; s++) {
      state = applyMasterySession(state, `k-${s}`, Array.from({ length: 3 }, (_, i) => ({
        configurationId: `SPC-K-${s}-${i}`, categoryName: "Shape Navigator", isCorrect: true, hintUsed: false
      })));
    }
    const before = state.domains.spatial?.level;
    state = applyMasterySession(state, "poor-session", [{
      configurationId: "SPC-K-poor", categoryName: "Shape Navigator", isCorrect: false, hintUsed: true
    }]);
    expect(state.domains.spatial?.level).toBe(before);
  });

  it("does not duplicate a replayed receipt or promote on a repeated configuration", () => {
    const trial = { configurationId:"SEQ-K-1", categoryName:"Sequence Explorer", isCorrect:true, hintUsed:false };
    const once = applyMasterySession(newMasteryState("kids"), "the-same-session", [trial]);
    const twice = applyMasterySession(once, "the-same-session", [trial]);
    expect(twice).toEqual(once);
    const separate = applyMasterySession(twice, "another-session", [trial]);
    expect(separate.domains.memory?.uniqueCorrectIds).toHaveLength(1);
  });

  it("counts a mixed session once per domain, not per trial", () => {
    const result = applyMasterySession(newMasteryState("adults"), "mixed", [
      {configurationId:"PAT-A-1",categoryName:"Pattern Logic",isCorrect:true,hintUsed:false},
      {configurationId:"PAT-A-2",categoryName:"Pattern Logic",isCorrect:true,hintUsed:false},
      {configurationId:"SEQ-A-1",categoryName:"Working Memory",isCorrect:true,hintUsed:false}
    ]);
    expect(result.domains.pattern?.sessions).toBe(1);
    expect(result.domains.memory?.sessions).toBe(1);
  });

  it("does not auto-unlock Exceptional even after extended strong practice", () => {
    let state = newMasteryState("adults");
    for (let s = 0; s < 25; s++) {
      state = applyMasterySession(state, `a-${s}`, Array.from({length:3}, (_,i)=>({
        configurationId:`SPC-A-${s}-${i}`,categoryName:"Spatial Reasoning",isCorrect:true,hintUsed:false
      })));
    }
    expect(state.domains.spatial?.level).toBe(4);
    expect(describeMastery(state).find(x => x.domain === "spatial")?.level).toBe("Master");
  });

  it("handles legacy or malformed local state without granting mastery", () => {
    const state = coerceMasteryState("kids", { version: 88, lane:"kids", domains:{spatial:{level:5}} });
    expect(state.domains.spatial).toBeUndefined();
    expect(coerceMasteryState("adults",{version:1,lane:"kids",domains:{}})).toEqual(newMasteryState("adults"));
  });

  it("does not depend on external services or browser storage in node", () => {
    expect(readMasteryState("seniors")).toEqual(newMasteryState("seniors"));
    expect(saveMasterySession("kids","local-only",[]).saved).toBe(false);
  });
});
