function renderKidsPuzzle48(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 48 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object that tells time.</p>
            <button data-choice="clock">Clock</button>
            <button data-choice="banana">Banana</button>
            <button data-choice="shoe">Shoe</button>
            <div id="mindlab-kids-puzzle-48-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-48-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="clock" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle48 };
}


