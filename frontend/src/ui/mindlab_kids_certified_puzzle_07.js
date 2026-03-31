function renderCertifiedKidsPuzzle07(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 07 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>What do you wear on your feet?</p>' +
        '<button data-choice="shoes">Shoes</button>' +
        '<button data-choice="hat">Hat</button>' +
        '<button data-choice="gloves">Gloves</button>' +
        '<div id="p07-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p07-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "shoes" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle07 };
}

