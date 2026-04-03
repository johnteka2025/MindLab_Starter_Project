function renderKidsPuzzle07(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 07 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the shape with three sides.</p>
            <button type="button" data-choice="square">Square</button>
            <button type="button" data-choice="triangle">Triangle</button>
            <button type="button" data-choice="circle">Circle</button>
            <div id="mindlab-kids-puzzle-07-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-07-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "triangle"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle07 };
}


