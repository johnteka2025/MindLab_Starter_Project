function renderKidsPuzzle05(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 05 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the number that is bigger.</p>
            <button type="button" data-choice="4">4</button>
            <button type="button" data-choice="9">9</button>
            <button type="button" data-choice="2">2</button>
            <div id="mindlab-kids-puzzle-05-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-05-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "9"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle05 };
}


