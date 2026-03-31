function renderKidsPuzzle06(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 06 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the fruit that is red.</p>
            <button type="button" data-choice="banana">Banana</button>
            <button type="button" data-choice="apple">Apple</button>
            <button type="button" data-choice="grape">Grape</button>
            <div id="mindlab-kids-puzzle-06-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-06-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "apple"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle06 };
}

