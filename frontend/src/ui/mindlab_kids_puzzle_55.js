function renderKidsPuzzle55(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 55 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Which one can fly?</p>
            <button data-choice="bird">Bird</button>
            <button data-choice="rock">Rock</button>
            <button data-choice="chair">Chair</button>
            <div id="mindlab-kids-puzzle-55-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-55-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="bird" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle55 };
}
