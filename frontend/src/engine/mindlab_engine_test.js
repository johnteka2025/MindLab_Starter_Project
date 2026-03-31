import { runEngineCycle } from "../ui/mindlab_engine_bridge.js"

const tests = ["correct", "wrong", "correct"]

tests.forEach(result => {
    const output = runEngineCycle(result)
    console.log("Input:", result, "Output:", output)
})
