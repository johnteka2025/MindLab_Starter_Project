function renderKidsPuzzle41(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 41 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object you use to write.</p>
            <button data-choice="pen">Pen</button>
            <button data-choice="plate">Plate</button>
            <button data-choice="shoe">Shoe</button>
            <div id="mindlab-kids-puzzle-41-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-41-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="pen" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle41 };
}


