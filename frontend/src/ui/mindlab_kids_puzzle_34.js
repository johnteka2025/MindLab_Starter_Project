function renderKidsPuzzle34(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 34 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object used for writing.</p>
            <button data-choice="pen">Pen</button>
            <button data-choice="stone">Stone</button>
            <button data-choice="leaf">Leaf</button>
            <div id="mindlab-kids-puzzle-34-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-34-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="pen" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle34 };
}


