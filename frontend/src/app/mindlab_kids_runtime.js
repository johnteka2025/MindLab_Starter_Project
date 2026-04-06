import * as Renderer from "../ui/mindlab_renderer.js";
import * as Interaction from "../ui/mindlab_interaction_controller.js";
import * as StateSync from "../engine/mindlab_state_sync.js";
import * as GameLogic from "../engine/mindlab_game_logic.js";
import * as Submitter from "../engine/mindlab_score_submitter.js";
import { getKidsPuzzleByStage } from "../data/kids/mindlab_kids_content_selector.js";

function resolveFunction(moduleRef, names) {
  for (const name of names) {
    if (typeof moduleRef[name] === "function") return moduleRef[name];
  }
  return null;
}

export async function startMindLabKidsRuntime(containerSelector = "#app") {
  const renderFn = resolveFunction(Renderer, [
    "renderMindLabPuzzle",
    "renderMindLabRenderer",
    "default"
  ]);

  const interactionFn = resolveFunction(Interaction, [
    "attachMindLabInteraction",
    "wireMindLabInteraction",
    "default"
  ]);

  const loadStateFn = resolveFunction(StateSync, [
    "loadMindLabState",
    "loadState",
    "default"
  ]);

  const saveStateFn = resolveFunction(StateSync, [
    "saveMindLabState",
    "saveState"
  ]);

  const nextStateFn = resolveFunction(GameLogic, [
    "getMindLabNextState",
    "getNextState",
    "default"
  ]);

  const submitFn = resolveFunction(Submitter, [
    "submitMindLabScore",
    "submitScore",
    "default"
  ]);

  if (!renderFn || !interactionFn) {
    throw new Error("Required UI runtime functions are missing");
  }

  const host = document.querySelector(containerSelector);
  if (!host) throw new Error("Runtime host not found");

  let state = loadStateFn ? (loadStateFn() || {}) : {};
  const activeStage = state.stage || "K1";
  const puzzle = getKidsPuzzleByStage(activeStage, 0);
  if (!puzzle) throw new Error("No puzzle available for current stage");

  const renderInput = {
    id: puzzle.id,
    puzzleId: puzzle.id,
    title: puzzle.title,
    prompt: puzzle.prompt,
    options: puzzle.options
  };

  renderFn(host, renderInput);

  interactionFn(host, async (choiceIndex) => {
    const choice = puzzle.options[choiceIndex];
    const isCorrect = !!(choice && choice.value === puzzle.correctValue);

    const payload = {
      userId: "kids-runtime-user",
      puzzleId: puzzle.id,
      isCorrect,
      basePoints: 10,
      responseMs: 1500,
      streak: isCorrect ? ((state.streak || 0) + 1) : 0
    };

    let response = { ok: true, result: { earned: isCorrect ? 10 : 0 } };

    if (submitFn) {
      try {
        response = await submitFn(payload);
      } catch (error) {
        response = {
          ok: false,
          error: error.message,
          result: { earned: isCorrect ? 10 : 0 }
        };
      }
    }

    const computed = nextStateFn
      ? nextStateFn(state, response)
      : {
          puzzleId: puzzle.id,
          score: (state.score || 0) + (response.result?.earned || 0),
          streak: payload.streak
        };

    state = computed;
    if (saveStateFn) saveStateFn(computed);

    const feedback = document.querySelector("#mindlab-feedback");
    if (feedback) {
      feedback.textContent = isCorrect ? "Correct." : "Try again.";
    }

    return response;
  });
}