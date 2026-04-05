export function renderMindLabPuzzle(containerId, puzzle = {}) {
  const host = document.getElementById(containerId);

  if (!host) {
    throw new Error(`Renderer host not found: ${containerId}`);
  }

  const prompt = puzzle.prompt ?? "Puzzle prompt missing";
  const options = Array.isArray(puzzle.options) ? puzzle.options : [];
  const buttons = options
    .map(option => `<button class="mindlab-option" data-choice="${option.value}">${option.label}</button>`)
    .join("");

  host.innerHTML = `
    <div class="mindlab-card">
      <div class="mindlab-card-header">
        <h2>${prompt}</h2>
      </div>
      <div class="mindlab-card-body">
        ${buttons || "<p>No options available.</p>"}
      </div>
      <div id="mindlab-status-line"></div>
    </div>
  `;
}

export function renderMindLabStatus(containerId, message, isError = false) {
  const host = document.getElementById(containerId);

  if (!host) {
    throw new Error(`Status host not found: ${containerId}`);
  }

  host.textContent = message ?? "";
  host.dataset.state = isError ? "error" : "ok";
}
