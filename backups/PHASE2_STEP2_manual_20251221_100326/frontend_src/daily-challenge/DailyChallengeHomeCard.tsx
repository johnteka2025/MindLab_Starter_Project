import React, { useEffect, useState } from "react";
import {
  fetchDailyStatus,
  type DailyChallengeStatus,
} from "./dailyChallengeApi";

/**
 * Small card to show Daily Challenge status on the home page.
 *
 * This component does not depend on any specific router.
 * It uses window.location.href to navigate to /daily.
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
    // Generic navigation – works regardless of React Router version.
    window.location.href = "/daily";
  };

  let body: React.ReactNode;

  if (loading) {
    body = <p className="text-sm text-gray-500">Loading Daily Challenge…</p>;
  } else if (error) {
    body = (
      <p className="text-sm text-red-600">
        Daily Challenge status unavailable: {error}
      </p>
    );
  } else if (status) {
    const friendlyStatus =
      status.status === "completed"
        ? "Completed"
        : status.status === "in_progress"
        ? "In progress"
        : "Not started";

    body = (
      <>
        <p className="text-sm text-gray-600">
          Today: <strong>{status.challengeDate}</strong> · Band{" "}
          <strong>{status.band}</strong>
        </p>
        <p className="text-sm text-gray-600 mt-1">
          Progress:{" "}
          <strong>
            {status.puzzlesCompletedToday} / {status.totalPuzzlesForToday}
          </strong>{" "}
          puzzles
        </p>
        <p className="text-sm text-gray-600 mt-1">
          Streak: <strong>{status.streakCount}</strong> day
          {status.streakCount === 1 ? "" : "s"}
        </p>
        <p className="text-sm font-semibold mt-2">
          Status: <span className="text-blue-700">{friendlyStatus}</span>
        </p>
      </>
    );
  } else {
    body = (
      <p className="text-sm text-gray-500">
        No Daily Challenge information available.
      </p>
    );
  }

  return (
    <section className="daily-challenge-card border rounded-lg p-4 shadow-sm bg-white">
      <h2 className="text-lg font-bold mb-2">Daily Challenge</h2>
      {body}
      <button
        type="button"
        onClick={handleOpenClick}
        className="mt-4 inline-flex items-center px-3 py-2 text-sm font-semibold rounded-md border border-blue-600 text-blue-600 hover:bg-blue-50"
      >
        Open Daily Challenge
      </button>
    </section>
  );
}

export default DailyChallengeHomeCard;
