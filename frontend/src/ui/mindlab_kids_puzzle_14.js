function renderKidsPuzzle14(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 14 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the shape with three sides.</p>
            <button type="button" data-choice="triangle">Triangle</button>
            <button type="button" data-choice="circle">Circle</button>
            <button type="button" data-choice="square">Square</button>
            <div id="mindlab-kids-puzzle-14-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-14-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "triangle"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle14 };
}


