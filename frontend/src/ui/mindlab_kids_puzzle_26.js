function renderKidsPuzzle26(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 26 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the cold object.</p>
            <button data-choice="ice">Ice</button>
            <button data-choice="fire">Fire</button>
            <button data-choice="sun">Sun</button>
            <div id="mindlab-kids-puzzle-26-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-26-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="ice" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle26 };
}


