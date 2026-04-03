function renderKidsPuzzle54(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 54 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Which one is a color?</p>
            <button data-choice="blue">Blue</button>
            <button data-choice="dog">Dog</button>
            <button data-choice="chair">Chair</button>
            <div id="mindlab-kids-puzzle-54-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-54-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="blue" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle54 };
}


