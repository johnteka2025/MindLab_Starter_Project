import { runPersistentGame } from "./mindlab_persistent_game_runner.js"

let history = []

function render(html) {
  const app = document.getElementById("app")
  app.innerHTML = html
}

window.run = async function(answer) {
  const output = await runPersistentGame(answer, history)
  history = output.history
  render(output.puzzleHtml)
}

// INITIAL LOAD FIX
window.addEventListener("load", async () => {
  const output = await runPersistentGame(null, history)
  history = output.history
  render(output.puzzleHtml)
})

