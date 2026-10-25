// Internal prototype: game progress, not a measure of real-world cognitive ability.
// v0.3 mastery gates are intentionally provisional pending representative playtest.
export type MasteryLane = "kids" | "adults" | "seniors";
export type MasteryDomain = "memory" | "attention" | "pattern" | "planning" | "spatial";
export const MASTERY_DOMAINS: readonly MasteryDomain[] = ["memory", "attention", "pattern", "planning", "spatial"];
export const MASTERY_LEVELS = ["Foundation", "Developing", "Skilled", "Advanced", "Master", "Exceptional"] as const;

export type MasteryTrial = {
  configurationId: string;
  categoryName: string;
  isCorrect: boolean;
  hintUsed: boolean;
};

type MasterySample = { isCorrect: boolean; independentCorrect: boolean };
export type DomainMastery = {
  level: number;
  sessions: number;
  attempts: number;
  correct: number;
  independentCorrect: number;
  uniqueCorrectIds: string[];
  recent: MasterySample[];
};
export type MasteryState = {
  version: 1;
  lane: MasteryLane;
  domains: Partial<Record<MasteryDomain, DomainMastery>>;
  processedSessionIds: string[];
};

type Gate = { sessions: number; distinct: number; recentAccuracy: number; independentRate: number };
// Provisional prototype thresholds, not approved external benchmarks.
// Exceptional stays locked until its separate validated advanced-lane gate.
const GATES: readonly Gate[] = [
  { sessions: 3, distinct: 6, recentAccuracy: 0.75, independentRate: 0.60 },
  { sessions: 6, distinct: 12, recentAccuracy: 0.78, independentRate: 0.67 },
  { sessions: 10, distinct: 20, recentAccuracy: 0.82, independentRate: 0.72 },
  { sessions: 15, distinct: 30, recentAccuracy: 0.85, independentRate: 0.78 }
];

export function newMasteryState(lane: MasteryLane): MasteryState {
  return { version: 1, lane, domains: {}, processedSessionIds: [] };
}

export function masteryDomainFor(categoryName: string, configurationId: string): MasteryDomain | null {
  const prefix = configurationId.toUpperCase();
  if (prefix.startsWith("SEQ-")) return "memory";
  if (prefix.startsWith("FOC-")) return "attention";
  if (prefix.startsWith("PAT-")) return "pattern";
  if (prefix.startsWith("PLN-")) return "planning";
  if (prefix.startsWith("SPC-")) return "spatial";
  const name = categoryName.trim().toLowerCase();
  if (/recall|memory|sequence explorer|working memory/.test(name)) return "memory";
  if (/focus|attention|filter/.test(name)) return "attention";
  if (/pattern/.test(name)) return "pattern";
  if (/plan|strategic decision/.test(name)) return "planning";
  if (/shape navigator|spatial|navigation|visual match/.test(name)) return "spatial";
  return null; // Unsupported legacy content does not create unearned mastery.
}

function emptyDomain(): DomainMastery {
  return { level: 0, sessions: 0, attempts: 0, correct: 0, independentCorrect: 0, uniqueCorrectIds: [], recent: [] };
}

function safeDomain(value: unknown): DomainMastery {
  if (!value || typeof value !== "object") return emptyDomain();
  const d = value as Partial<DomainMastery>;
  const num = (n: unknown) => typeof n === "number" && Number.isFinite(n) && n >= 0 ? Math.floor(n) : 0;
  return {
    level: Math.min(4, num(d.level)), // No automatic Exceptional classification.
    sessions: num(d.sessions), attempts: num(d.attempts),
    correct: num(d.correct), independentCorrect: num(d.independentCorrect),
    uniqueCorrectIds: Array.isArray(d.uniqueCorrectIds) ? d.uniqueCorrectIds.filter((x): x is string => typeof x === "string").slice(-100) : [],
    recent: Array.isArray(d.recent) ? d.recent.filter((x): x is MasterySample =>
      !!x && typeof x === "object" && typeof x.isCorrect === "boolean" && typeof x.independentCorrect === "boolean").slice(-40) : []
  };
}

export function coerceMasteryState(lane: MasteryLane, value: unknown): MasteryState {
  if (!value || typeof value !== "object") return newMasteryState(lane);
  const raw = value as Partial<MasteryState>;
  if (raw.version !== 1 || raw.lane !== lane || !raw.domains || typeof raw.domains !== "object") return newMasteryState(lane);
  const domains: MasteryState["domains"] = {};
  for (const domain of MASTERY_DOMAINS) {
    if (raw.domains[domain]) domains[domain] = safeDomain(raw.domains[domain]);
  }
  const processedSessionIds = Array.isArray(raw.processedSessionIds)
    ? raw.processedSessionIds.filter((x): x is string => typeof x === "string").slice(-100)
    : [];
  return { version: 1, lane, domains, processedSessionIds };
}

export function masteryStorageKey(lane: MasteryLane): string {
  return `mindlab.${lane}.earnedMastery.v1`;
}

export function readMasteryState(lane: MasteryLane): MasteryState {
  try {
    if (typeof window === "undefined" || !window.localStorage) return newMasteryState(lane);
    const raw = window.localStorage.getItem(masteryStorageKey(lane));
    return raw ? coerceMasteryState(lane, JSON.parse(raw) as unknown) : newMasteryState(lane);
  } catch {
    return newMasteryState(lane);
  }
}

export function applyMasterySession(state: MasteryState, sessionId: string, trials: readonly MasteryTrial[]): MasteryState {
  const start = coerceMasteryState(state.lane, state);
  if (!sessionId || start.processedSessionIds.includes(sessionId) || trials.length === 0) return start;
  const domains: MasteryState["domains"] = { ...start.domains };
  const grouped = new Map<MasteryDomain, MasteryTrial[]>();
  for (const trial of trials) {
    if (!trial || typeof trial.configurationId !== "string" || !trial.configurationId.trim()) continue;
    const domain = masteryDomainFor(trial.categoryName ?? "", trial.configurationId);
    if (!domain) continue;
    grouped.set(domain, [...(grouped.get(domain) ?? []), trial]);
  }
  if (grouped.size === 0) return start;
  for (const [domain, group] of grouped) {
    const current = safeDomain(domains[domain]);
    const ids = new Set(current.uniqueCorrectIds);
    const recent = [...current.recent];
    let correct = current.correct, independentCorrect = current.independentCorrect;
    for (const trial of group) {
      const independentlyCorrect = trial.isCorrect && !trial.hintUsed;
      if (trial.isCorrect) { correct++; ids.add(trial.configurationId); }
      if (independentlyCorrect) independentCorrect++;
      recent.push({ isCorrect: trial.isCorrect, independentCorrect: independentlyCorrect });
    }
    const next: DomainMastery = {
      level: current.level, sessions: current.sessions + 1,
      attempts: current.attempts + group.length, correct, independentCorrect,
      uniqueCorrectIds: [...ids].slice(-100), recent: recent.slice(-40)
    };
    const gate = GATES[next.level];
    if (gate && meetsMasteryGate(next, gate)) next.level += 1; // At most one level per session.
    domains[domain] = next;
  }
  return {
    ...start, domains,
    processedSessionIds: [...start.processedSessionIds, sessionId].slice(-100)
  };
}

function meetsMasteryGate(d: DomainMastery, gate: Gate): boolean {
  if (d.sessions < gate.sessions || d.uniqueCorrectIds.length < gate.distinct) return false;
  const size = d.recent.length;
  if (!size) return false;
  return d.recent.filter(x => x.isCorrect).length / size >= gate.recentAccuracy &&
    d.recent.filter(x => x.independentCorrect).length / size >= gate.independentRate;
}

export function saveMasterySession(lane: MasteryLane, sessionId: string, trials: readonly MasteryTrial[]): { state: MasteryState; saved: boolean } {
  const next = applyMasterySession(readMasteryState(lane), sessionId, trials);
  try {
    if (typeof window === "undefined" || !window.localStorage) return { state: next, saved: false };
    window.localStorage.setItem(masteryStorageKey(lane), JSON.stringify(next));
    return { state: next, saved: true };
  } catch {
    return { state: next, saved: false };
  }
}

export function masteryObjective(domain: DomainMastery | undefined): string {
  if (!domain || domain.attempts === 0) return "Try this skill in a game session.";
  const gate = GATES[domain.level];
  if (!gate) return "Master milestone earned. Advanced eligibility is reviewed separately.";
  const sessions = Math.max(0, gate.sessions - domain.sessions);
  const distinct = Math.max(0, gate.distinct - domain.uniqueCorrectIds.length);
  if (sessions || distinct) return `Next: ${sessions} more skill sessions and ${distinct} new correct puzzles; keep practicing accurately with fewer hints.`;
  return "Next: keep practicing accurately across different puzzles with fewer hints.";
}

export function describeMastery(state: MasteryState) {
  return MASTERY_DOMAINS.map(domain => {
    const record = state.domains[domain];
    return {
      domain,
      label: ({memory:"Memory",attention:"Attention",pattern:"Pattern",planning:"Planning",spatial:"Spatial"} as const)[domain],
      level: MASTERY_LEVELS[record?.level ?? 0],
      sessions: record?.sessions ?? 0,
      uniqueCorrect: record?.uniqueCorrectIds.length ?? 0,
      objective: masteryObjective(record)
    };
  });
}

export function createMasterySessionId(lane: MasteryLane): string {
  // An opaque local deduplication key; it contains no player identity.
  return `${lane}-${Date.now()}-${Math.random().toString(36).slice(2)}`;
}
