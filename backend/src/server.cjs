const express = require("express");
const cors = require("cors");

const app = express();
const PORT = 8085;

app.use(cors());
app.use(express.json({ limit: "1mb" }));

app.get("/health", (req, res) => {
  res.status(200).json({
    ok: true,
    status: "ok",
    port: PORT
  });
});

app.post("/score", (req, res) => {
  const payload = req.body && typeof req.body === "object" ? req.body : {};

  res.status(200).json({
    ok: true,
    sessionId: payload.sessionId ?? "default-session",
    scoreDelta: Number(payload.scoreDelta ?? 0),
    result: payload.result ?? "unknown",
    puzzleId: payload.puzzleId ?? null,
    metadata: payload.metadata ?? {}
  });
});

app.use((req, res) => {
  res.status(404).json({
    ok: false,
    error: `Route not found: ${req.method} ${req.originalUrl}`
  });
});

app.use((error, req, res, next) => {
  res.status(400).json({
    ok: false,
    error: "Invalid JSON body"
  });
});

app.listen(PORT, () => {
  console.log(`MindLab backend listening on ${PORT}`);
});
