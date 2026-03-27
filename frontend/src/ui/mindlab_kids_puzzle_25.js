function renderKidsPuzzle25(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 25 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object that gives light.</p>
            <button data-choice="sun">Sun</button>
            <button data-choice="stone">Stone</button>
            <button data-choice="chair">Chair</button>
            <div id="mindlab-kids-puzzle-25-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-25-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="sun" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle25 };
}
