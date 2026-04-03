function renderKidsPuzzle49(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 49 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the animal that can fly.</p>
            <button data-choice="bird">Bird</button>
            <button data-choice="fish">Fish</button>
            <button data-choice="dog">Dog</button>
            <div id="mindlab-kids-puzzle-49-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-49-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="bird" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle49 };
}


