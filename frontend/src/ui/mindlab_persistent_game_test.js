import { runPersistentGame } from "./mindlab_persistent_game_runner.js"

let history = []

const inputs = ["correct", "wrong"]

async function runTest() {
    for (const input of inputs) {
        const output = await runPersistentGame(input, history)
        history = output.history

        console.log("RESULT:", output.result)
        console.log("SCORE:", output.payload.score)
        console.log("BACKEND:", output.backend)
    }
}

runTest()


