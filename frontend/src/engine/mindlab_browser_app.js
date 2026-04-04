import { renderPuzzle } from '/src/ui/mindlab_renderer.js';
import { submitScore } from '/src/engine/mindlab_score_submitter.js';

async function bootKidsApp() {

    try {
        renderPuzzle({
            id: 'K1_standard',
            type: 'puzzle'
        });

        const result = await submitScore({
            ageCategory: 'kids',
            level: 'K1',
            action: 'boot'
        });

        console.log('[BOOT RESULT]', result);

        if (!result || result.ok === false) {
            document.body.innerHTML += '<div style="color:red">API ERROR: ' + result.error + '</div>';
        }

    } catch (err) {
        console.error('[FATAL ERROR]', err);
        document.body.innerHTML += '<div style="color:red">FATAL ERROR</div>';
    }
}

if (!window.__bootExecuted) {
    window.__bootExecuted = true;
    bootKidsApp();
}

