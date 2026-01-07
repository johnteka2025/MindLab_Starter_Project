// Simple puzzle engine that hides the correct answer server-side.
// We track answers by a random key stored in-memory per process.
import crypto from "node:crypto";

const store = new Map(); // key -> { correct: string, ttl: number(ms) }
const TTL_MS = 10 * 60 * 1000; // 10 minutes

const uid = () => crypto.randomUUID();
const pick = (arr) => arr[Math.floor(Math.random() * arr.length)];
const ri = (a, b) => a + Math.floor(Math.random() * (b - a + 1));

/* ---------- Generators (>= 10 types) ---------- */

function genAdd() {
  const a = ri(2, 30), b = ri(2, 30);
  const correct = String(a + b);
  const options = new Set([correct]);
  while (options.size < 4) options.add(String(ri(a + b - 10, a + b + 10)));
  return { q: `${a} + ${b} = ?`, options: Array.from(options) , correct };
}

function genSub() {
  let a = ri(10, 40), b = ri(2, 10);
  if (b > a) [a,b] = [b,a];
  const correct = String(a - b);
  const options = new Set([correct]);
  while (options.size < 4) options.add(String(ri(a - b - 10, a - b + 10)));
  return { q: `${a} - ${b} = ?`, options: Array.from(options) , correct };
}

function genMul() {
  const a = ri(2, 12), b = ri(2, 12);
  const correct = String(a * b);
  const options = new Set([correct]);
  while (options.size < 4) options.add(String(ri(a*b - 12, a*b + 12)));
  return { q: `${a} × ${b} = ?`, options: Array.from(options) , correct };
}

function genDiv() {
  const b = ri(2, 12), q = ri(2, 12), a = b * q;
  const correct = String(q);
  const options = new Set([correct]);
  while (options.size < 4) options.add(String(ri(q - 6, q + 6)));
  return { q: `${a} ÷ ${b} = ?`, options: Array.from(options) , correct };
}

function genSequence() {
  const start = ri(1, 10), step = ri(1, 7);
  const arr = [start, start+step, start+2*step, start+3*step];
  const correct = String(start + 4*step);
  const options = new Set([correct]);
  while (options.size < 4) options.add(String(ri(+correct - 10, +correct + 10)));
  return { q: `Next in sequence: ${arr.join(", ")}, ?`, options: Array.from(options) , correct };
}

function genMax() {
  const arr = Array.from({length:4}, () => ri(10,99));
  const correct = String(Math.max(...arr));
  const options = arr.map(String);
  return { q: `Pick the largest number`, options, correct };
}

function genMin() {
  const arr = Array.from({length:4}, () => ri(10,99));
  const correct = String(Math.min(...arr));
  const options = arr.map(String);
  return { q: `Pick the smallest number`, options, correct };
}

function genColor() {
  const question = `Color of the sky?`;
  const options = ["Green","Blue","Red","Brown"];
  return { q: question, options, correct: "Blue" };
}

function genCapital() {
  const set = [
    ["France","Paris"], ["Spain","Madrid"], ["Germany","Berlin"], ["Italy","Rome"]
  ];
  const [c, cap] = pick(set);
  const pool = set.map(([_,x])=>x);
  const opts = new Set([cap]); while(opts.size<4) opts.add(pick(pool));
  return { q: `Capital of ${c}?`, options: Array.from(opts), correct: cap };
}

function genAnagram() {
  const words = ["APPLE","HOUSE","TRAIN","WATER"];
  const w = pick(words);
  const scrambled = w.split("").sort(()=>Math.random()-0.5).join("");
  const pool = ["HORSE","PLANE","TABLE","MOUSE","GRAPE","STONE",w];
  const opts = new Set([w]); while(opts.size<4) opts.add(pick(pool));
  return { q:`Unscramble: ${scrambled}`, options:Array.from(opts), correct:w };
}

const gens = [
  genAdd, genSub, genMul, genDiv,
  genSequence, genMax, genMin,
  genColor, genCapital, genAnagram
];

/* ---------- API exported to server ---------- */

export function generatePuzzle(){
  const g = pick(gens);
  const { q, options, correct } = g();
  const key = uid();
  store.set(key, { correct, ttl: Date.now() + TTL_MS });
  // return puzzle WITHOUT correct
  return { key, q, options };
}

export function verifyAnswer(key, answer){
  const rec = store.get(key);
  if(!rec) return false;
  const ok = String(answer).trim() === String(rec.correct).trim();
  // consume once
  store.delete(key);
  return ok;
}

export function forget(key){ store.delete(key); }

// periodic cleanup (low effort)
setInterval(()=>{
  const now = Date.now();
  for(const [k, rec] of store.entries()){
    if(rec.ttl < now) store.delete(k);
  }
}, 60_000).unref();
