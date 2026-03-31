import { runGame } from "./mindlab_game_loop.js"

const inputs = ["correct", "wrong", "invalid"]

inputs.forEach(i => {
    const output = runGame(i)
    console.log(output)
})
