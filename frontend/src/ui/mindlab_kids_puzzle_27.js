function renderKidsPuzzle27(containerId) {
    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 27 host not found");

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Pick the animal that barks.</p>
            <button data-choice="dog">Dog</button>
            <button data-choice="cat">Cat</button>
            <button data-choice="cow">Cow</button>
            <div id="mindlab-kids-puzzle-27-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-puzzle-27-feedback");
    host.querySelectorAll("button").forEach(btn=>{
        btn.addEventListener("click",()=>{
            feedback.textContent = btn.dataset.choice==="dog" ? "Great job." : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsPuzzle27 };
}


