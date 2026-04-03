function renderCertifiedKidsPuzzle21(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 21 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>If it is night and dark, what should you use to see clearly?</p>' +
        '<button data-choice="flashlight">Flashlight</button>' +
        '<button data-choice="book">Book</button>' +
        '<button data-choice="pillow">Pillow</button>' +
        '<div id="p21-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p21-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "flashlight" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle21 };
}


