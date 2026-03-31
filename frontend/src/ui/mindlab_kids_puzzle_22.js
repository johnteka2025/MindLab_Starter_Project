function renderKidsPuzzle22(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 22 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the vehicle.</p>
            <button data-choice="car">Car</button>
            <button data-choice="apple">Apple</button>
            <button data-choice="tree">Tree</button>
            <div id="mindlab-kids-puzzle-22-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-22-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="car" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle22 };
}

