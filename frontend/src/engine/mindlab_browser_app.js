import { renderPuzzle } from '../ui/mindlab_renderer.js';
import { submitScore } from './mindlab_score_submitter.js';

async function bootKidsApp() {
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
}

bootKidsApp();
