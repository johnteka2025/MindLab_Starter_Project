function renderKidsPuzzle09(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 09 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the thing that can fly.</p>
            <button type="button" data-choice="bird">Bird</button>
            <button type="button" data-choice="chair">Chair</button>
            <button type="button" data-choice="shoe">Shoe</button>
            <div id="mindlab-kids-puzzle-09-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-09-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "bird"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle09 };
}


