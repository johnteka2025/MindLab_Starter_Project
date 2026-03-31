export function renderPuzzle(puzzle) {
    return `
        <div class="puzzle">
            <h2>${puzzle.id}</h2>
            <p>Type: ${puzzle.type}</p>
            <p>Status: ${puzzle.status}</p>
        </div>
    `
}

