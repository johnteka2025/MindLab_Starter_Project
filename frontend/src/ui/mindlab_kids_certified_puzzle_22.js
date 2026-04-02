function renderCertifiedKidsPuzzle22(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 22 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>If you are thirsty after running, what should you do?</p>' +
        '<button data-choice="drink">Drink water</button>' +
        '<button data-choice="sleep">Sleep</button>' +
        '<button data-choice="jump">Jump</button>' +
        '<div id="p22-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p22-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "drink" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle22 };
}


