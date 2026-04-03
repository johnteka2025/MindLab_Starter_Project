function renderKidsPuzzle02(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 02 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the largest number.</p>
            <button type="button" data-choice="2">2</button>
            <button type="button" data-choice="5">5</button>
            <button type="button" data-choice="3">3</button>
            <div id="mindlab-kids-puzzle-02-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-02-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "5"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle02 };
}


