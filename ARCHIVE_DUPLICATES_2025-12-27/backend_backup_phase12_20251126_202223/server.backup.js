import express from 'express';
import cors from 'cors';
import { pool } from './db.js';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', async (req, res) => {
  let db = false;
  try {
    const r = await pool.query('select 1');
    db = r?.rows?.length === 1;
  } catch (_) { db = false; }
  res.json({ ok: true, db });
});

app.get('/progress', async (req, res) => {
  // simple “exists” endpoint to let frontend render something
  res.json({ level: 1, xp: 0, streak: 0 });
});

const port = +(process.env.PORT || 8085);
app.listen(port, () => {
  console.log(`Backend listening on ${port}`);
});
