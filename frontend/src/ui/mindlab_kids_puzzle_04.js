function renderKidsPuzzle04(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 04 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the animal that barks.</p>
            <button type="button" data-choice="cat">Cat</button>
            <button type="button" data-choice="dog">Dog</button>
            <button type="button" data-choice="fish">Fish</button>
            <div id="mindlab-kids-puzzle-04-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-04-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "dog"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle04 };
}


