export function handleUserInput(answer) {
    if (!answer) return "invalid"
    return answer === "correct" ? "correct" : "wrong"
}


