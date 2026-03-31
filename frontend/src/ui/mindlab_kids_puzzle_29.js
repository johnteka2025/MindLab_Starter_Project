function renderKidsPuzzle29(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 29 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the object used for eating.</p>
            <button data-choice="spoon">Spoon</button>
            <button data-choice="stone">Stone</button>
            <button data-choice="book">Book</button>
            <div id="mindlab-kids-puzzle-29-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-29-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="spoon" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle29 };
}

