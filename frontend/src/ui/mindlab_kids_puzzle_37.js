function renderKidsPuzzle37(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 37 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object you sleep on.</p>
            <button data-choice="bed">Bed</button>
            <button data-choice="stone">Stone</button>
            <button data-choice="cup">Cup</button>
            <div id="mindlab-kids-puzzle-37-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-37-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="bed" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle37 };
}
