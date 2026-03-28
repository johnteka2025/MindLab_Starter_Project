function renderKidsPuzzle50(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 50 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object you use to drink.</p>
            <button data-choice="cup">Cup</button>
            <button data-choice="book">Book</button>
            <button data-choice="shoe">Shoe</button>
            <div id="mindlab-kids-puzzle-50-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-50-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="cup" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle50 };
}
