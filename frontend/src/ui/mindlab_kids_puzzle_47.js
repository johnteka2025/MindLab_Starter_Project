function renderKidsPuzzle47(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 47 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object you use to write.</p>
            <button data-choice="pencil">Pencil</button>
            <button data-choice="plate">Plate</button>
            <button data-choice="shoe">Shoe</button>
            <div id="mindlab-kids-puzzle-47-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-47-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="pencil" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle47 };
}


