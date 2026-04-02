function renderKidsPuzzle12(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 12 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the day that comes after Monday.</p>
            <button type="button" data-choice="friday">Friday</button>
            <button type="button" data-choice="tuesday">Tuesday</button>
            <button type="button" data-choice="sunday">Sunday</button>
            <div id="mindlab-kids-puzzle-12-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-12-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "tuesday"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle12 };
}


