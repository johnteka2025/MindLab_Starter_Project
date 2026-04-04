import { submitScore } from './mindlab_score_submitter.js';

export async function bootKidsApp() {
    const payload = {
        level: "K1",
        ageCategory: "kids",
        action: "boot"
    };

    const result = await submitScore(payload);

    console.log("[BOOT RESULT]", result);

    if (!result.ok) {
        document.body.innerHTML += '<div style="color:red">API ERROR: ' + result.error + '</div>';
    }
}

bootKidsApp();
