# MindLab Daily Challenge API Contract (Phase 10)

## 1. GET /daily/status

Returns a summary of the current day's Daily Challenge for the current user.

### Response 200 OK (JSON)

{
  "status": "not_started" | "in_progress" | "completed",
  "streakCount": number,
  "puzzlesCompletedToday": number,
  "totalPuzzlesForToday": number,
  "band": "A" | "B" | "C",
  "challengeDate": "YYYY-MM-DD"
}

- status:
  - "not_started": user has not begun today's challenge.
  - "in_progress": user has started but not finished.
  - "completed": user has finished all puzzles for today.
- streakCount: number of consecutive days the user has completed the challenge.
- puzzlesCompletedToday / totalPuzzlesForToday: progress numbers.
- band: difficulty band (A=Explorer, B=Thinker, C=Master).
- challengeDate: server-side date for the challenge.

---

## 2. GET /daily

Creates or retrieves today's challenge instance for the current user.

### Response 200 OK (JSON)

{
  "dailyChallengeId": string,
  "band": "A" | "B" | "C",
  "challengeDate": "YYYY-MM-DD",
  "totalPuzzles": number,
  "completedCount": number,
  "status": "not_started" | "in_progress" | "completed",
  "puzzles": [
    {
      "id": string,
      "title": string,
      "type": string,
      "difficulty": number
    }
  ]
}

This object matches the DailyChallengeInstance interface defined in
frontend/src/daily-challenge/models.ts.

---

## 3. GET /daily/puzzles (optional)

Optional convenience endpoint. May be omitted if /daily already returns all puzzles.

### Response 200 OK (JSON)

{
  "dailyChallengeId": string,
  "puzzles": DailyChallengePuzzleSummary[]
}

---

## 4. POST /daily/answer

Submit an answer for a specific puzzle.

### Request body (JSON)

{
  "dailyChallengeId": string,
  "puzzleId": string,
  "answer": any
}

answer payload format depends on the puzzle type and should match
whatever the existing puzzle APIs use.

### Response 200 OK (JSON)

{
  "dailyChallengeId": string,
  "puzzleId": string,
  "correct": boolean,
  "completedCount": number,
  "totalPuzzles": number,
  "status": "in_progress" | "completed",
  "streakCount": number
}

Behavior:

- The backend validates the answer based on the puzzle type.
- If correct, increments completedCount.
- When completedCount === totalPuzzles, set status = "completed" and
  update streakCount if this is the first completion for challengeDate.

---

## 5. Error handling (generic)

On invalid dailyChallengeId or puzzleId, respond with 400 or 404 and
a JSON error object:

{
  "error": "DailyChallengeNotFound" | "PuzzleNotFound" | "ValidationError",
  "message": string
}
