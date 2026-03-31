function renderCertifiedKidsPuzzle20(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 20 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>If you are cold, what should you wear?</p>' +
        '<button data-choice="jacket">Jacket</button>' +
        '<button data-choice="shorts">Shorts</button>' +
        '<button data-choice="sandals">Sandals</button>' +
        '<div id="p20-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p20-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "jacket" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle20 };
}

