function renderKidsPuzzle44(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 44 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object that gives light.</p>
            <button data-choice="lamp">Lamp</button>
            <button data-choice="rock">Rock</button>
            <button data-choice="paper">Paper</button>
            <div id="mindlab-kids-puzzle-44-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-44-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="lamp" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle44 };
}


