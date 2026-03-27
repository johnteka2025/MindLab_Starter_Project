function renderKidsPuzzle23(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 23 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the shape that has four equal sides.</p>
            <button data-choice="square">Square</button>
            <button data-choice="triangle">Triangle</button>
            <button data-choice="circle">Circle</button>
            <div id="mindlab-kids-puzzle-23-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-23-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="square" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle23 };
}
