function renderKidsPuzzle15(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 15 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the color of the sky on a clear day.</p>
            <button data-choice="blue">Blue</button>
            <button data-choice="green">Green</button>
            <button data-choice="red">Red</button>
            <div id="mindlab-kids-puzzle-15-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-15-feedback");
    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "blue" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle15 };
}

