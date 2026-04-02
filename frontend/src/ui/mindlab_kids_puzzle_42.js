function renderKidsPuzzle42(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 42 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object you sit on.</p>
            <button data-choice="chair">Chair</button>
            <button data-choice="water">Water</button>
            <button data-choice="cloud">Cloud</button>
            <div id="mindlab-kids-puzzle-42-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-42-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="chair" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle42 };
}


