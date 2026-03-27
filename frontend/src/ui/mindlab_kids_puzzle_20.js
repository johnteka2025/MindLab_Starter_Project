function renderKidsPuzzle20(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 20 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the fastest animal.</p>
            <button data-choice="cheetah">Cheetah</button>
            <button data-choice="turtle">Turtle</button>
            <button data-choice="snail">Snail</button>
            <div id="mindlab-kids-puzzle-20-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-20-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="cheetah" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle20 };
}
