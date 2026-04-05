import { renderMindLabStatus } from "./mindlab_renderer.js";
import { runMindLabBrowserScoreFlow } from "../engine/mindlab_browser_app.js";
import { shouldAdvancePuzzle } from "../engine/mindlab_game_logic.js";

export function attachMindLabInteraction(containerId, payloadBuilder, handlers = {}) {
  const host = document.getElementById(containerId);

  if (!host) {
    throw new Error(`Interaction host not found: ${containerId}`);
  }

  host.querySelectorAll("[data-choice]").forEach(button => {
    button.addEventListener("click", async () => {
      const choice = button.dataset.choice;
      const payload = payloadBuilder(choice);

      try {
        const response = await runMindLabBrowserScoreFlow(payload, {
          onSuccess: () => renderMindLabStatus("mindlab-status-line", "Saved.", false),
          onError: (error) => renderMindLabStatus("mindlab-status-line", error.message, true)
        });

        if (shouldAdvancePuzzle(response) && handlers.onAdvance) {
          handlers.onAdvance(response);
        }
      } catch (error) {
        renderMindLabStatus("mindlab-status-line", error.message, true);
      }
    });
  });
}
