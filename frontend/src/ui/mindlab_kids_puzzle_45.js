function renderKidsPuzzle45(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 45 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object you use to eat soup.</p>
            <button data-choice="spoon">Spoon</button>
            <button data-choice="book">Book</button>
            <button data-choice="ball">Ball</button>
            <div id="mindlab-kids-puzzle-45-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-45-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="spoon" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle45 };
}

