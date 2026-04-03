function renderKidsPuzzle17(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 17 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the fruit.</p>
            <button data-choice="apple">Apple</button>
            <button data-choice="car">Car</button>
            <button data-choice="chair">Chair</button>
            <div id="mindlab-kids-puzzle-17-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-17-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="apple" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle17 };
}


