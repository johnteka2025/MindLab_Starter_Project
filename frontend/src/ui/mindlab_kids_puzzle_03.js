function renderKidsPuzzle03(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 03 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the color of the sun.</p>
            <button type="button" data-choice="blue">Blue</button>
            <button type="button" data-choice="yellow">Yellow</button>
            <button type="button" data-choice="green">Green</button>
            <div id="mindlab-kids-puzzle-03-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-03-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "yellow"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle03 };
}
