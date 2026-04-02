function renderCertifiedKidsPuzzle01(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Certified Kids Puzzle 01 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Which one is blue?</p>
            <button data-choice="blue">Blue</button>
            <button data-choice="banana">Banana</button>
            <button data-choice="dog">Dog</button>
            <div id="mindlab-certified-kids-puzzle-01-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-certified-kids-puzzle-01-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "blue" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle01 };
}


