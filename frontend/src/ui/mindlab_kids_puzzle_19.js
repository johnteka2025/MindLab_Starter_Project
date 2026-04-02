function renderKidsPuzzle19(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 19 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the number that is greater than 5.</p>
            <button data-choice="3">3</button>
            <button data-choice="7">7</button>
            <button data-choice="2">2</button>
            <div id="mindlab-kids-puzzle-19-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-19-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="7" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle19 };
}


