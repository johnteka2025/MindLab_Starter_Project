import React, { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import {
  fetchDaily,
  fetchDailyStatus,
  submitDailyAnswer,
  type DailyGetResponse,
  type DailyStatusResponse,
  type DailyPuzzleSummary,
} from "./dailyChallengeApi";

function safeString(v: unknown): string {
  return typeof v === "string" ? v : "";
}

export default function DailyChallengeDetailPage() {
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [daily, setDaily] = useState<DailyGetResponse | null>(null);
  const [status, setStatus] = useState<DailyStatusResponse | null>(null);

  const [selectedId, setSelectedId] = useState<string>("");
  const selectedPuzzle: DailyPuzzleSummary | null = useMemo(() => {
    if (!daily || !daily.puzzles?.length) return null;
    const found = daily.puzzles.find((p) => String(p.id) === selectedId);
    return found ?? daily.puzzles[0] ?? null;
  }, [daily, selectedId]);

  const [answer, setAnswer] = useState<string>("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitOk, setSubmitOk] = useState<string | null>(null);
  const [submitError, setSubmitError] = useState<string | null>(null);

  async function refreshDailyAndStatus() {
    const [d, s] = await Promise.all([fetchDaily(), fetchDailyStatus()]);
    setDaily(d);
    setStatus(s);

    const nextSelected =
      d.puzzles?.some((p) => String(p.id) === selectedId) ? selectedId : String(d.puzzles?.[0]?.id ?? "");
    setSelectedId(nextSelected);
  }

  useEffect(() => {
    let cancelled = false;

    (async () => {
      setLoading(true);
      setLoadError(null);

      try {
        await refreshDailyAndStatus();
        if (cancelled) return;
      } catch (e: any) {
        if (cancelled) return;
        setLoadError(e?.message ?? "Failed to load Daily Challenge.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();

    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function onSubmitAnswer() {
    if (isSubmitting) return;

    const trimmed = answer.trim();
    if (!trimmed) {
      setSubmitError("Please enter an answer.");
      return;
    }

    setIsSubmitting(true);
    setSubmitOk(null);
    setSubmitError(null);

    try {
      const res = await submitDailyAnswer({
        answer: trimmed,
        dailyChallengeId: status?.dailyChallengeId ?? daily?.dailyChallengeId,
      });

      if (!res?.ok) {
        const msg = res?.message ?? res?.error ?? "Answer not accepted.";
        setSubmitError(msg);
        return;
      }

      // Re-fetch immediately (single source of truth)
      await refreshDailyAndStatus();

      setAnswer("");
      setSubmitOk("Answer submitted.");
    } catch (e: any) {
      setSubmitError(e?.message ?? "Failed to submit answer.");
    } finally {
      setIsSubmitting(false);
    }
  }

  const progressText = useMemo(() => {
    if (!status) return "Status: Unknown";
    const suffix = typeof status.total === "number" && status.total > 0 ? ` (${status.progress}/${status.total})` : "";
    const s =
      status.status === "completed" ? "Complete" : status.status === "in_progress" ? "In progress" : "Not started";
    return `Status: ${s}${suffix} · Streak: ${status.streak ?? 0}`;
  }, [status]);

  if (loading) {
    return (
      <div style={{ padding: 16 }}>
        <h1>Daily Challenge</h1>
        <p data-testid="daily-loading">Loading...</p>
      </div>
    );
  }

  if (loadError) {
    return (
      <div style={{ padding: 16 }}>
        <h1>Daily Challenge</h1>
        <p data-testid="daily-error" style={{ color: "crimson" }}>
          {loadError}
        </p>
        <p>
          <Link to="/">← Back to Home</Link>
        </p>
      </div>
    );
  }

  return (
    <div style={{ padding: 16 }}>
      <h1>Daily Challenge</h1>

      <p data-testid="daily-status" style={{ marginTop: 0 }}>
        {progressText}
      </p>

      <div style={{ margin: "10px 0 16px" }}>
        <button
          type="button"
          onClick={() => {
            setLoadError(null);
            setSubmitOk(null);
            setSubmitError(null);
            setLoading(true);
            refreshDailyAndStatus()
              .catch((e: any) => setLoadError(e?.message ?? "Failed to refresh Daily Challenge."))
              .finally(() => setLoading(false));
          }}
          disabled={loading || isSubmitting}
        >
          Refresh
        </button>
      </div>

      <h2>Puzzles</h2>

      <ul
        data-testid="daily-puzzles-list"
        style={{ border: "1px solid #ddd", borderRadius: 8, padding: 12, margin: 0, maxWidth: 720 }}
      >
        {!daily?.puzzles?.length ? (
          <li data-testid="daily-puzzles-empty">No puzzles available.</li>
        ) : (
          daily.puzzles.map((p) => {
            const id = String(p.id);
            const isSelected = id === selectedId;
            return (
              <li key={id} style={{ marginBottom: 6 }}>
                <button
                  type="button"
                  onClick={() => {
                    setSelectedId(id);
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
                  {safeString(p.prompt) || `Puzzle ${id}`}
                </button>
              </li>
            );
          })
        )}
      </ul>

      {selectedPuzzle && (
        <div style={{ marginTop: 16, maxWidth: 720 }}>
          <h3>Selected</h3>
          <p data-testid="daily-selected-question">{safeString(selectedPuzzle.prompt)}</p>

          {!!selectedPuzzle.choices?.length && (
            <div style={{ marginTop: 8 }}>
              <div style={{ fontWeight: 700, marginBottom: 6 }}>Choices</div>
              <ul style={{ marginTop: 0 }}>
                {selectedPuzzle.choices.map((c, idx) => (
                  <li key={`${idx}-${c}`}>{c}</li>
                ))}
              </ul>
            </div>
          )}

          <div style={{ marginTop: 12 }}>
            <label>
              Answer:{" "}
              <input
                data-testid="daily-answer-input"
                value={answer}
                onChange={(e) => setAnswer(e.target.value)}
                disabled={isSubmitting}
                style={{ width: 320, maxWidth: "100%" }}
              />
            </label>
          </div>

          <div style={{ marginTop: 10 }}>
            <button data-testid="daily-submit-answer" type="button" onClick={onSubmitAnswer} disabled={isSubmitting}>
              {isSubmitting ? "Submitting..." : "Submit answer"}
            </button>
          </div>

          {submitOk && (
            <p data-testid="daily-submit-ok" style={{ marginTop: 10 }}>
              {submitOk}
            </p>
          )}

          {submitError && (
            <p data-testid="daily-submit-error" style={{ marginTop: 10, color: "crimson" }}>
              {submitError}
            </p>
          )}
        </div>
      )}

      <p style={{ marginTop: 18 }}>
        <Link to="/">← Back to Home</Link>
      </p>
    </div>
  );
}
