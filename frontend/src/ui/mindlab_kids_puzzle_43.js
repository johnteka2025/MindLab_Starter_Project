function renderKidsPuzzle43(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 43 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object you wear on your feet.</p>
            <button data-choice="shoes">Shoes</button>
            <button data-choice="hat">Hat</button>
            <button data-choice="cup">Cup</button>
            <div id="mindlab-kids-puzzle-43-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-43-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="shoes" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle43 };
}


