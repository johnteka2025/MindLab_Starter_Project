function renderKidsFirstPuzzle(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids first puzzle host not found.");
    }

    host.innerHTML = `
        <div class="mindlab-kids-puzzle">
            <p>Find the matching shape.</p>
            <button type="button" data-choice="circle">Circle</button>
            <button type="button" data-choice="square">Square</button>
            <button type="button" data-choice="triangle">Triangle</button>
            <div id="mindlab-kids-feedback"></div>
        </div>
    `;

    const feedback = host.querySelector("#mindlab-kids-feedback");
    host.querySelectorAll("button[data-choice]").forEach((button) => {
        button.addEventListener("click", () => {
            feedback.textContent = button.dataset.choice === "circle"
                ? "Great job."
                : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsFirstPuzzle };
}


