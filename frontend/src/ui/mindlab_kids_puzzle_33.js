function renderKidsPuzzle33(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 33 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the color of the sky.</p>
            <button data-choice="blue">Blue</button>
            <button data-choice="green">Green</button>
            <button data-choice="black">Black</button>
            <div id="mindlab-kids-puzzle-33-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-33-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="blue" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle33 };
}


