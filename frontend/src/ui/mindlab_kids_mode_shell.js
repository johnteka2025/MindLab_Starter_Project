function renderKidsModeShell(containerId) {
    const host = document.getElementById(containerId);
    if (!host) {
        throw new Error("Kids mode shell host not found.");
    }

    host.innerHTML = `
        <section class="mindlab-kids-mode">
            <h1>MindLab Kids Mode</h1>
            <p>Start with one simple puzzle.</p>
            <div id="mindlab-kids-puzzle-host"></div>
            <button id="mindlab-kids-retry-button" type="button">Retry</button>
        </section>
    `;
}

if (typeof module !== "undefined") {
    module.exports = { renderKidsModeShell };
}
