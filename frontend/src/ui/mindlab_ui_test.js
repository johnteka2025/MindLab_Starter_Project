import { runUI } from "./mindlab_ui_controller.js"

const results = ["correct", "wrong"]

results.forEach(r => {
    const html = runUI(r)
    console.log(html)
})
