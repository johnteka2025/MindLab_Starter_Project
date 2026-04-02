function renderKidsPuzzle53(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 53 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Which one is a fruit?</p>
            <button data-choice="apple">Apple</button>
            <button data-choice="car">Car</button>
            <button data-choice="table">Table</button>
            <div id="mindlab-kids-puzzle-53-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-53-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="apple" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle53 };
}


