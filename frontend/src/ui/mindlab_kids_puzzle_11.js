function renderKidsPuzzle11(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 11 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the season that comes after summer.</p>
            <button type="button" data-choice="winter">Winter</button>
            <button type="button" data-choice="autumn">Autumn</button>
            <button type="button" data-choice="spring">Spring</button>
            <div id="mindlab-kids-puzzle-11-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-11-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "autumn"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle11 };
}
