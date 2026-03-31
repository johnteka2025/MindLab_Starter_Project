import { runEngineCycle } from "../ui/mindlab_engine_bridge.js"

const tests = ["correct", "wrong"]

tests.forEach(result => {
    const output = runEngineCycle(result)
    console.log("Result:", output.id, output.type, output.status)
})
