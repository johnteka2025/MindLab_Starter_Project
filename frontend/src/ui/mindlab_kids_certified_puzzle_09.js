function renderCertifiedKidsPuzzle09(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 09 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>Which one is food?</p>' +
        '<button data-choice="bread">Bread</button>' +
        '<button data-choice="chair">Chair</button>' +
        '<button data-choice="car">Car</button>' +
        '<div id="p09-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p09-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "bread" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle09 };
}


