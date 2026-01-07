import React, { useEffect, useState } from "react";
import { fetchDailyStatus, type DailyChallengeStatus } from "./dailyChallengeApi";

/**
 * Small card to show Daily Challenge status on the home page.
 * ASCII-only text to avoid encoding/mojibake issues across environments.
 */
export function DailyChallengeHomeCard() {
  const [status, setStatus] = useState<DailyChallengeStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      try {
        const result = await fetchDailyStatus();
        if (!cancelled) {
          setStatus(result);
          setLoading(false);
        }
      } catch (err: any) {
        if (!cancelled) {
          setError(err?.message ?? "Unable to load Daily Challenge status.");
          setLoading(false);
        }
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  const handleOpenClick = () => {
    window.location.href = "/app/daily";
  };

  let body: React.ReactNode;

  if (loading) {
    body = <p>Loading Daily Challenge...</p>;
  } else if (error) {
    body = <p style={{ color: "crimson" }}>Daily Challenge status unavailable: {error}</p>;
  } else if (status) {
    const friendlyStatus =
      status.status === "completed"
        ? "Completed"
        : status.status === "in_progress"
        ? "In progress"
        : "Not started";

    body = (
      <>
        <p>
          Today: <strong>{status.challengeDate}</strong> - Band{" "}
          <strong>{status.band}</strong>
        </p>
        <p style={{ marginTop: 6 }}>
          Progress:{" "}
          <strong>
            {status.puzzlesCompletedToday} / {status.totalPuzzlesForToday}
          </strong>{" "}
          puzzles
        </p>
        <p style={{ marginTop: 6 }}>
          Streak: <strong>{status.streakCount}</strong> day
          {status.streakCount === 1 ? "" : "s"}
        </p>
        <p style={{ marginTop: 10, fontWeight: 700 }}>
          Status: <span>{friendlyStatus}</span>
        </p>
      </>
    );
  } else {
    body = <p>No Daily Challenge information available.</p>;
  }

  return (
    <section style={{ border: "1px solid #ddd", borderRadius: 12, padding: 16 }}>
      <h2 style={{ marginTop: 0 }}>Daily Challenge</h2>
      {body}
      <button type="button" onClick={handleOpenClick} style={{ marginTop: 12 }}>
        Open Daily Challenge
      </button>
    </section>
  );
}

export default DailyChallengeHomeCard;
