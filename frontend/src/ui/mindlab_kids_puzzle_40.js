function renderKidsPuzzle40(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 40 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object you drink from.</p>
            <button data-choice="cup">Cup</button>
            <button data-choice="shoe">Shoe</button>
            <button data-choice="book">Book</button>
            <div id="mindlab-kids-puzzle-40-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-40-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="cup" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle40 };
}


