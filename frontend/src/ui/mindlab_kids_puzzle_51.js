function renderKidsPuzzle51(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 51 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object you wear on your head.</p>
            <button data-choice="hat">Hat</button>
            <button data-choice="shoe">Shoe</button>
            <button data-choice="cup">Cup</button>
            <div id="mindlab-kids-puzzle-51-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-51-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="hat" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle51 };
}

