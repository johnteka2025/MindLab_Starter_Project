import { describe, expect, it } from "vitest";
import { buildFreshSpatialChallenge, buildSpatialChallenge, getAdaptiveSpatialDifficulty } from "../features/shared/spatialChallengeEngine";
import { buildKidsShapeNavigatorSession } from "../features/kids/KidsGameplayPanel";
import { buildAdultsSpatialReasoningSession } from "../features/adults/AdultsGameplayPanel";
import { buildSeniorsEverydayNavigationSession } from "../features/seniors/SeniorsGameplayPanel";

describe("Family 5 visual spatial reasoning, three age lanes", () => {
  it("generates three visual questions per optional age-specific session", () => {
    const children = buildKidsShapeNavigatorSession(0, []);
    const adults = buildAdultsSpatialReasoningSession(0, []);
    const seniors = buildSeniorsEverydayNavigationSession(0, []);
    expect(children).toHaveLength(3);
    expect(adults).toHaveLength(3);
    expect(seniors).toHaveLength(3);
    expect(children.every(x => x.certifiedId.startsWith("SPC-K-") && x.categoryName === "Shape Navigator")).toBe(true);
    expect(adults.every(x => x.certifiedId.startsWith("SPC-A-") && x.categoryName === "Spatial Reasoning")).toBe(true);
    expect(seniors.every(x => x.challengeId.startsWith("SPC-S-") && x.categoryName === "Everyday Navigation")).toBe(true);
    expect(seniors.every(x => x.objective.includes("without speed pressure"))).toBe(true);
  });
  it("preserves visual diagrams and unambiguous options for six structures across ages", () => {
    for (const lane of ["kids","adults","seniors"] as const) {
      const seen = new Set<string>();
      for (let i=0;i<6;i++) {
        const x=buildSpatialChallenge(lane,`${lane}-${i}`,3,i);
        seen.add(x.scenarioKind);
        expect(x.prompt).toContain("\n");
        expect(x.options).toHaveLength(4);
        expect(new Set(x.options).size).toBe(4);
        expect(x.options.filter(o=>o===x.correctAnswer)).toHaveLength(1);
        expect(x.timed).toBe(false);
      }
      expect(seen.size).toBe(6);
    }
  });
  it("produces deterministic puzzles and distinct scenarios in consecutive plays", () => {
    for (const lane of ["kids","adults","seniors"] as const) {
      const challenges=Array.from({length:9}, (_,n)=> buildSpatialChallenge(lane,`${lane}-${n}`,2,n));
      expect(new Set(challenges.slice(0,6).map(x=>x.scenarioKind)).size).toBe(6);
      expect(new Set(challenges.map(x=>x.configurationId)).size).toBe(9);
      expect(buildSpatialChallenge(lane,`${lane}-same`,2,1)).toEqual(buildSpatialChallenge(lane,`${lane}-same`,2,1));
    }
  });
  it("does not repeat recent exact configurations", () => {
    const first=buildFreshSpatialChallenge({lane:"kids",baseSeed:"stable",difficulty:2,variationIndex:0});
    const next=buildFreshSpatialChallenge({lane:"kids",baseSeed:"stable",difficulty:2,variationIndex:0,recentConfigurationIds:[first.configurationId]});
    expect(next.configurationId).not.toBe(first.configurationId);
  });
  it("preserves four visually distinct choices at all difficulty levels without a timer", () => {
    for (const lane of ["kids","adults","seniors"] as const) {
      for (const level of [1,2,3] as const) {
        const x=buildSpatialChallenge(lane,"test",level,0);
        expect(x.options).toHaveLength(4);
        expect(x.timed).toBe(false);
      }
    }
    const strong=Array.from({length:5},()=>({isCorrect:true,score:100,hintUsed:false}));
    expect(getAdaptiveSpatialDifficulty("adults",strong)).toBe(4);
    expect(getAdaptiveSpatialDifficulty("seniors",strong)).toBe(3);
    expect(getAdaptiveSpatialDifficulty("kids",[{isCorrect:false,score:0}])).toBe(1);
  });
  it("starts optional sessions with distinct age-specific cognitive tasks", () => {
    // UI increments sessionCycle before starting the first spatial session.
    const kids = buildKidsShapeNavigatorSession(1, []);
    const adults = buildAdultsSpatialReasoningSession(1, []);
    const seniors = buildSeniorsEverydayNavigationSession(1, []);
    expect(kids[0]!.prompt).toContain("directly to the RIGHT of the circle");
    expect(adults[0]!.prompt).toContain("reflect it left-to-right, THEN rotate");
    expect(seniors[0]!.prompt).toContain("Home ● to the Park ◆ and then the Clinic ★");
    expect(seniors[0]!.prompt).toContain("no speed penalty");
    const prompts = [kids[0]!.prompt, adults[0]!.prompt, seniors[0]!.prompt];
    expect(new Set(prompts).size).toBe(3);
    for (const session of [kids,adults,seniors]) {
      expect(session.every(x => x.options.length === 4)).toBe(true);
      expect(session.every(x => new Set(x.options).size === 4)).toBe(true);
    }
  });
  it("uses six lane-specific scenario kinds and never assigns a mirror puzzle to Kids or Seniors", () => {
    for (const lane of ["kids","adults","seniors"] as const) {
      const prefix = lane === "kids" ? "KID_" : lane === "adults" ? "ADULT_" : "SENIOR_";
      const six = Array.from({length:6},(_,i) => buildSpatialChallenge(lane,`age-${i}`,2,i));
      expect(new Set(six.map(x => x.scenarioKind)).size).toBe(6);
      expect(six.every(x => x.scenarioKind.startsWith(prefix))).toBe(true);
      if (lane !== "adults") {
        expect(six.every(x => !x.prompt.toLowerCase().includes("mirror"))).toBe(true);
      }
      if (lane === "seniors") expect(six.every(x => /Home|Park|Library|Pharmacy|Bus Stop/.test(x.prompt))).toBe(true);
    }
  });
  it("adult rotation and reflection answers match independently transformed grid diagrams", () => {
    type Grid = string[][];
    const quarter = (grid: Grid):Grid => grid.map((_,c)=>grid.map(row=>row[c]!).reverse());
    const vertical = (grid: Grid):Grid => grid.map(row=>[...row].reverse());
    const horizontal = (grid: Grid):Grid => [...grid].reverse();
    const text = (grid: Grid) => grid.map(row => row.join(" ")).join("\n");
    for (let i=0;i<30;i++) {
      const kind=i%6;
      const x=buildSpatialChallenge("adults",`oracle-${i}`,3,i);
      const original=x.prompt.split("Original:\n")[1]!.split("\n").map(row=>row.split(" "));
      const rotate=(g:Grid,n:number) => { for(let j=0;j<n;j++) g=quarter(g);return g;};
      const transformed=[
        rotate(original,1),vertical(original),rotate(original,2),
        rotate(vertical(original),1),rotate(original,3),horizontal(original)
      ][kind]!;
      expect(x.correctAnswer).toBe(text(transformed));
    }
  });
  it("validates every spatial challenge option under sampled seeds", () => {
    for (const lane of ["kids","adults","seniors"] as const) {
      for (let i=0;i<144;i++) {
        const difficulty=((i%4)+1) as 1|2|3|4;
        const challenge=buildSpatialChallenge(lane,`spatial-${i}`,difficulty,i);
        expect(challenge.options.includes(challenge.correctAnswer)).toBe(true);
        expect(new Set(challenge.options).size).toBe(challenge.options.length);
      }
    }
  });
});
