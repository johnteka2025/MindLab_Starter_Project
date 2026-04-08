import * as Renderer from "../ui/mindlab_renderer.js";
import * as Interaction from "../ui/mindlab_interaction_controller.js";
import * as StateSync from "../engine/mindlab_state_sync.js";
import * as GameLogic from "../engine/mindlab_game_logic.js";
import { getKidsPuzzleByStage } from "../data/kids/mindlab_kids_content_selector.js";

function resolveFunction(moduleRef, names) {
  for (const name of names) {
    if (typeof moduleRef[name] === "function") return moduleRef[name];
  }
  return null;
}

function normalizeContainerId(containerSelector = "#app") {
  const raw = String(containerSelector || "").trim();
  if (!raw) return "app";
  if (raw.startsWith("#")) return raw.slice(1);
  return raw;
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

  if (!renderFn || !interactionFn) {
    throw new Error("Required UI runtime functions are missing");
  }

  const host = document.querySelector(containerSelector);
  if (!host) {
    throw new Error(`Runtime host not found: ${containerSelector}`);
  }

  const containerId = host.id || normalizeContainerId(containerSelector);
  if (!host.id) {
    host.id = containerId;
  }

  let state = loadStateFn ? (loadStateFn() || {}) : {};
  const activeStage = state.stage || "K1";
  const puzzle = getKidsPuzzleByStage(activeStage, 0);

  if (!puzzle) {
    throw new Error("No puzzle available for current stage");
  }

  const renderInput = {
    id: puzzle.id,
    puzzleId: puzzle.id,
    title: puzzle.title,
    prompt: puzzle.prompt,
    options: puzzle.options
  };

  renderFn(containerId, renderInput);

  const statusLine = document.getElementById("mindlab-status-line");
  if (statusLine) {
    statusLine.textContent = "Choose an answer.";
  }

  interactionFn(
    containerId,
    (choiceValue) => {
      const selectedChoice = Array.isArray(puzzle.options)
        ? puzzle.options.find((option) => String(option.value) === String(choiceValue))
        : null;

      const isCorrect = !!(selectedChoice && selectedChoice.value === puzzle.correctValue);

      return {
        userId: "kids-runtime-user",
        puzzleId: puzzle.id,
        isCorrect,
        basePoints: 10,
        responseMs: 1500,
        streak: isCorrect ? ((state.streak || 0) + 1) : 0
      };
    },
    {
      onAdvance: (response) => {
        const earned = response?.result?.earned || 0;

        const computed = nextStateFn
          ? nextStateFn(state, response)
          : {
              ...state,
              stage: activeStage,
              puzzleId: puzzle.id,
              score: (state.score || 0) + earned,
              streak: response?.result?.streak ?? state.streak ?? 0
            };

        state = computed;
        if (saveStateFn) {
          saveStateFn(computed);
        }
      }
    }
  );
}