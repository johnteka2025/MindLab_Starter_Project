function renderKidsPuzzle13(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids puzzle 13 host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the thing you wear on your feet.</p>
            <button type="button" data-choice="shoe">Shoe</button>
            <button type="button" data-choice="plate">Plate</button>
            <button type="button" data-choice="book">Book</button>
            <div id="mindlab-kids-puzzle-13-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-13-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "shoe"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle13 };
}
