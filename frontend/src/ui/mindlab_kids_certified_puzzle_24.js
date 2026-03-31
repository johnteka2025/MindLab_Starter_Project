function renderCertifiedKidsPuzzle24(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 24 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>If it is hot outside, what should you wear?</p>' +
        '<button data-choice="tshirt">T-shirt</button>' +
        '<button data-choice="coat">Coat</button>' +
        '<button data-choice="scarf">Scarf</button>' +
        '<div id="p24-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p24-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "tshirt" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle24 };
}

