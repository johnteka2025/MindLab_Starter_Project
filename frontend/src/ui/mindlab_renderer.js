export function renderPuzzle(data) {
    const root = document.getElementById('app') || document.body;

    const html =
        '<h1>' + (data.id || 'K1_standard') + '</h1>' +
        '<p>Type: ' + (data.type || 'puzzle') + '</p>' +
        '<p>Status: ready</p>';

    root.innerHTML = html;
}
