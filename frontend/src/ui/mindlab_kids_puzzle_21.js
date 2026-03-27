function renderKidsPuzzle21(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 21 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object that can fly.</p>
            <button data-choice="bird">Bird</button>
            <button data-choice="rock">Rock</button>
            <button data-choice="table">Table</button>
            <div id="mindlab-kids-puzzle-21-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-21-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="bird" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle21 };
}
