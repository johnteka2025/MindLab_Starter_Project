import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";

type Puzzle = {
  id: number;
  question: string;
  options: string[];
  answerIndex?: number;
};

type Progress = {
  total: number;
  solved: number;
  solvedIds?: Array<number | string>;
};

type DifficultyData = {
  default: "easy" | "medium" | "hard";
  levels: Array<"easy" | "medium" | "hard">;
  map: Record<string, "easy" | "medium" | "hard">;
};

type DifficultyFilter = "all" | "easy" | "medium" | "hard";

const API =
  (import.meta as any).env?.VITE_API_BASE_URL ||
  (import.meta as any).env?.VITE_API_BASE ||
  "http://localhost:8085";

async function fetchJson<T>(path: string): Promise<T> {
  const res = await fetch(`${API}${path}`);
  if (!res.ok) throw new Error(`${path} failed: ${res.status}`);
  return (await res.json()) as T;
}

async function postJson<T>(path: string, body: any): Promise<T> {
  const res = await fetch(`${API}${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body ?? {}),
  });
  if (!res.ok) throw new Error(`${path} failed: ${res.status}`);
  return (await res.json()) as T;
}

function normalizeSolvedIds(ids: Array<number | string> | undefined): Set<number> {
  const set = new Set<number>();
  for (const v of ids ?? []) {
    const n = typeof v === "number" ? v : Number(v);
    if (!Number.isNaN(n)) set.add(n);
  }
  return set;
}

function toDifficultyMap(data: DifficultyData | null): Map<number, "easy" | "medium" | "hard"> {
  const m = new Map<number, "easy" | "medium" | "hard">();
  if (!data?.map) return m;
  for (const [k, v] of Object.entries(data.map)) {
    const id = Number(k);
    if (!Number.isNaN(id)) m.set(id, v);
  }
  return m;
}

export default function SolvePuzzle() {
  const [puzzles, setPuzzles] = useState<Puzzle[]>([]);
  const [progress, setProgress] = useState<Progress | null>(null);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);

  // Difficulty state (frontend-only enrichment)
  const [difficulty, setDifficulty] = useState<DifficultyData | null>(null);
  const [difficultyFilter, setDifficultyFilter] = useState<DifficultyFilter>("all");
  const [difficultyWarn, setDifficultyWarn] = useState<string | null>(null);

  const [pickedPuzzleId, setPickedPuzzleId] = useState<number | "">("");
  const [pickedOptionIndex, setPickedOptionIndex] = useState<number | "">("");
  const [resultMsg, setResultMsg] = useState<string>("");

  const solvedSet = useMemo(() => normalizeSolvedIds(progress?.solvedIds), [progress]);

  const diffMap = useMemo(() => toDifficultyMap(difficulty), [difficulty]);

  const visiblePuzzles = useMemo(() => {
    if (difficultyFilter === "all") return puzzles;

    // If difficulty data isn't available, fail open (show all)
    if (!difficulty) return puzzles;

    return puzzles.filter((p) => {
      const d = diffMap.get(p.id) ?? difficulty.default ?? "medium";
      return d === difficultyFilter;
    });
  }, [puzzles, difficulty, diffMap, difficultyFilter]);

  // If user changes difficulty filter and their selected puzzle is no longer visible,
  // reset selection to avoid confusion.
  useEffect(() => {
    if (pickedPuzzleId === "") return;
    const stillVisible = visiblePuzzles.some((p) => p.id === pickedPuzzleId);
    if (!stillVisible) {
      setPickedPuzzleId("");
      setPickedOptionIndex("");
      setResultMsg("");
      setDifficultyWarn("Selected puzzle was filtered out. Please pick a puzzle again.");
    } else {
      setDifficultyWarn(null);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [difficultyFilter, puzzles.length, difficulty?.default]);

  const selectedPuzzle = useMemo(
    () => (pickedPuzzleId === "" ? null : puzzles.find((p) => p.id === pickedPuzzleId) || null),
    [puzzles, pickedPuzzleId]
  );

  const selectedDifficulty = useMemo(() => {
    if (!selectedPuzzle) return null;
    if (!difficulty) return null;
    return diffMap.get(selectedPuzzle.id) ?? difficulty.default ?? "medium";
  }, [selectedPuzzle, difficulty, diffMap]);

  const isSelectedSolved = useMemo(() => {
    if (!selectedPuzzle) return false;
    return solvedSet.has(selectedPuzzle.id);
  }, [selectedPuzzle, solvedSet]);

  async function loadAll() {
    setLoading(true);
    setErr(null);
    setDifficultyWarn(null);

    try {
      // Keep existing /puzzles behavior intact (supports both array or { puzzles } shape)
      const puzzlesRes = await fetchJson<any>("/puzzles");
      const list = Array.isArray(puzzlesRes)
        ? puzzlesRes
        : Array.isArray(puzzlesRes?.puzzles)
          ? puzzlesRes.puzzles
          : [];
      setPuzzles(list);

      const prog = await fetchJson<Progress>("/progress");
      setProgress(prog);

      // Difficulty is optional: fail open if endpoint isn't available
      try {
        const diff = await fetchJson<DifficultyData>("/difficulty");
        setDifficulty(diff);
      } catch {
        setDifficulty(null);
      }
    } catch (e: any) {
      setErr(e?.message || "Failed to load");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadAll();
  }, []);

  async function solve() {
    setResultMsg("");
    setErr(null);

    if (pickedPuzzleId === "" || pickedOptionIndex === "") {
      setErr("Pick a puzzle and an answer first.");
      return;
    }

    if (isSelectedSolved) {
      setResultMsg("ℹ️ This puzzle is already solved. Pick another one.");
      return;
    }

    try {
      const res = await postJson<any>("/progress/solve", {
        puzzleId: pickedPuzzleId,
        answerIndex: pickedOptionIndex,
      });

      // Refresh progress after submit (source of truth)
      const prog = await fetchJson<Progress>("/progress");
      setProgress(prog);

      if (res?.correct === true) setResultMsg("✅ Correct!");
      else if (res?.correct === false) setResultMsg("❌ Incorrect.");
      else setResultMsg("✅ Submitted.");
    } catch (e: any) {
      setErr(e?.message || "Solve failed");
    }
  }

  if (loading) return <div style={{ padding: "1rem" }}>Loading…</div>;

  return (
    <div style={{ padding: "1rem", maxWidth: 720 }}>
      <h1>Solve a Puzzle</h1>

      <p>
        Backend: <code>{API}</code>
      </p>

      {err && <p style={{ color: "red" }}>{err}</p>}
      {resultMsg && <p>{resultMsg}</p>}
      {difficultyWarn && <p style={{ color: "#8a5a00" }}>{difficultyWarn}</p>}

      <section style={{ marginTop: "1rem" }}>
        <h2>Difficulty</h2>

        <select
          value={difficultyFilter}
          onChange={(e) => setDifficultyFilter(e.target.value as DifficultyFilter)}
          style={{ marginBottom: "0.75rem" }}
        >
          <option value="all">All</option>
          <option value="easy">Easy</option>
          <option value="medium">Medium</option>
          <option value="hard">Hard</option>
        </select>

        {!difficulty && (
          <p style={{ marginTop: "0.25rem", opacity: 0.85 }}>
            ℹ️ Difficulty data not available. Showing all puzzles.
          </p>
        )}
      </section>

      <section style={{ marginTop: "1rem" }}>
        <h2>Pick a puzzle</h2>

        <select
          value={pickedPuzzleId}
          onChange={(e) => {
            const v = e.target.value ? Number(e.target.value) : "";
            setPickedPuzzleId(v);
            setPickedOptionIndex("");
            setResultMsg("");
            setDifficultyWarn(null);
          }}
        >
          <option value="">-- Select --</option>
          {visiblePuzzles.map((p) => {
            const d = difficulty ? diffMap.get(p.id) ?? difficulty.default ?? "medium" : null;
            return (
              <option key={p.id} value={p.id}>
                #{p.id}: {p.question.slice(0, 60)}
                {d ? ` [${d}]` : ""}
              </option>
            );
          })}
        </select>

        {selectedPuzzle && (
          <div style={{ marginTop: "1rem" }}>
            <h3>Question</h3>
            <p>{selectedPuzzle.question}</p>

            {selectedDifficulty && (
              <p style={{ marginTop: "0.25rem", opacity: 0.85 }}>
                Difficulty: <strong>{selectedDifficulty}</strong>
              </p>
            )}

            <h3>Choose an answer</h3>
            {selectedPuzzle.options.map((opt, idx) => (
              <label key={idx} style={{ display: "block", margin: "0.25rem 0" }}>
                <input
                  type="radio"
                  name="answer"
                  checked={pickedOptionIndex === idx}
                  onChange={() => setPickedOptionIndex(idx)}
                  disabled={isSelectedSolved}
                />{" "}
                {opt}
              </label>
            ))}

            {isSelectedSolved && (
              <p style={{ marginTop: "0.5rem" }}>
                ✅ Already solved. Select a different puzzle.
              </p>
            )}

            <button
              style={{ marginTop: "0.75rem" }}
              onClick={solve}
              disabled={isSelectedSolved || pickedOptionIndex === ""}
            >
              Submit Answer
            </button>
          </div>
        )}
      </section>

      <section style={{ marginTop: "1.5rem" }}>
        <h2>Progress</h2>
        <p>
          {progress ? (
            <>
              {progress.solved} of {progress.total} solved
            </>
          ) : (
            "No progress loaded"
          )}
        </p>

        <button onClick={loadAll}>Refresh</button>
      </section>

      <p style={{ marginTop: "1.5rem" }}>
        <Link to="/">← Back to Home</Link>
      </p>
    </div>
  );
}