function renderKidsPuzzle08(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 08 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the word that names a color.</p>
            <button type="button" data-choice="table">Table</button>
            <button type="button" data-choice="blue">Blue</button>
            <button type="button" data-choice="shoe">Shoe</button>
            <div id="mindlab-kids-puzzle-08-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-08-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "blue"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle08 };
}
