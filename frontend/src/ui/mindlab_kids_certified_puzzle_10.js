function renderCertifiedKidsPuzzle10(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 10 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>What do you use to see in the dark?</p>' +
        '<button data-choice="flashlight">Flashlight</button>' +
        '<button data-choice="book">Book</button>' +
        '<button data-choice="plate">Plate</button>' +
        '<div id="p10-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p10-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "flashlight" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle10 };
}


