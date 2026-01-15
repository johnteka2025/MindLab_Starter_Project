import React, { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import {
  fetchDaily,
  fetchDailyStatus,
  submitDailyAnswer,
  type DailyChallengeInstance,
  type DailyChallengeStatus,
} from "./dailyChallengeApi";

export default function DailyChallengeDetailPage() {
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [instance, setInstance] = useState<DailyChallengeInstance | null>(null);
  const [status, setStatus] = useState<DailyChallengeStatus | null>(null);

  const [selectedId, setSelectedId] = useState<string>("");
  const [answer, setAnswer] = useState<string>("");

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitOk, setSubmitOk] = useState<string | null>(null);
  const [submitError, setSubmitError] = useState<string | null>(null);

  async function refreshAll() {
    const [dailyRes, statusRes] = await Promise.all([fetchDaily(), fetchDailyStatus()]);
    setInstance(dailyRes);
    setStatus(statusRes);

    // Keep selection stable if possible
    const list = Array.isArray(dailyRes.puzzles) ? dailyRes.puzzles : [];
    if (list.length > 0) {
      const exists = list.some((p) => String(p.id) === selectedId);
      if (!selectedId || !exists) setSelectedId(String(list[0].id));
    } else {
      setSelectedId("");
    }
  }

  useEffect(() => {
    let cancelled = false;

    (async () => {
      setLoading(true);
      setLoadError(null);
      try {
        await refreshAll();
      } catch (e: any) {
        if (!cancelled) setLoadError(e?.message ?? "Failed to load daily challenge.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();

    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const puzzles = useMemo(() => instance?.puzzles ?? [], [instance]);
  const selectedPuzzle = useMemo(() => {
    if (!selectedId) return null;
    return puzzles.find((p) => String(p.id) === selectedId) ?? null;
  }, [puzzles, selectedId]);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (isSubmitting) return;

    setSubmitOk(null);
    setSubmitError(null);

    const dailyId = instance?.dailyChallengeId ?? "";
    const puzzleId = selectedPuzzle ? String(selectedPuzzle.id) : "";

    if (!dailyId) {
      setSubmitError("Missing dailyChallengeId (reload /daily).");
      return;
    }
    if (!puzzleId) {
      setSubmitError("Missing puzzleId (select a puzzle).");
      return;
    }

    setIsSubmitting(true);
    try {
      await submitDailyAnswer({
        dailyChallengeId: dailyId,
        puzzleId,
        answer: answer.trim(),
      });

      // Immediately re-fetch (single source of truth)
      await refreshAll();
      setSubmitOk("Submitted. Status refreshed.");
    } catch (err: any) {
      setSubmitError(err?.message ?? "POST /daily/answer failed.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div style={{ padding: 16 }}>
      <h1>Daily Challenge</h1>

      {loading && <p data-testid="daily-loading">Loading...</p>}

      {!loading && loadError && (
        <p data-testid="daily-error" style={{ color: "crimson" }}>
          Failed to load daily challenge. ({loadError})
        </p>
      )}

      {!loading && !loadError && (
        <>
          <p style={{ marginTop: 0 }}>
            Status: <strong>{status?.status ?? "unknown"}</strong>
          </p>

          <h2>Puzzles</h2>

          <ul
            data-testid="daily-puzzles-list"
            style={{
              border: "1px solid #ddd",
              borderRadius: 8,
              padding: 12,
              listStylePosition: "inside",
              margin: 0,
              maxWidth: 720,
            }}
          >
            {puzzles.length === 0 ? (
              <li data-testid="daily-puzzles-empty">No puzzles available.</li>
            ) : (
              puzzles.map((p) => {
                const isSelected = String(p.id) === selectedId;
                return (
                  <li key={String(p.id)} style={{ marginBottom: 6 }}>
                    <button
                      type="button"
                      onClick={() => {
                        setSelectedId(String(p.id));
                        setSubmitOk(null);
                        setSubmitError(null);
                      }}
                      data-testid="daily-puzzle-item"
                      style={{
                        background: "transparent",
                        border: "none",
                        padding: 0,
                        cursor: "pointer",
                        textAlign: "left",
                        fontWeight: isSelected ? "bold" : "normal",
                      }}
                    >
                      {p.question}
                    </button>
                  </li>
                );
              })
            )}
          </ul>

          <div style={{ marginTop: 16, maxWidth: 720 }}>
            <h3>Selected</h3>

            {!selectedPuzzle ? (
              <p data-testid="daily-selected-empty">Select a puzzle to answer.</p>
            ) : (
              <form onSubmit={onSubmit}>
                <p data-testid="daily-selected-question">{selectedPuzzle.question}</p>

                <label>
                  Answer:{" "}
                  <input
                    value={answer}
                    onChange={(e) => setAnswer(e.target.value)}
                    style={{ width: 260 }}
                    disabled={isSubmitting}
                  />
                </label>{" "}
                <button
                  type="submit"
                  disabled={isSubmitting}
                  data-testid="daily-submit"
                >
                  {isSubmitting ? "Submitting..." : "Submit"}
                </button>

                {submitOk && (
                  <p data-testid="daily-submit-ok" style={{ marginTop: 10 }}>
                    {submitOk}
                  </p>
                )}
                {submitError && (
                  <p
                    data-testid="daily-submit-error"
                    style={{ marginTop: 10, color: "crimson" }}
                  >
                    {submitError}
                  </p>
                )}
              </form>
            )}

            <p style={{ marginTop: 12 }}>
              <Link to="/">← Back to Home</Link>
            </p>
          </div>
        </>
      )}
    </div>
  );
}
