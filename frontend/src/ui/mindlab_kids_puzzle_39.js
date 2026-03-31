function renderKidsPuzzle39(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 39 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object that flies.</p>
            <button data-choice="bird">Bird</button>
            <button data-choice="car">Car</button>
            <button data-choice="chair">Chair</button>
            <div id="mindlab-kids-puzzle-39-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-39-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="bird" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle39 };
}

