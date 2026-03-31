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

render("<button onclick=\"run('correct')\">Correct</button><button onclick=\"run('wrong')\">Wrong</button>")
