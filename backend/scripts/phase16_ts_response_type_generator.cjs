"use strict";

function main() {
    const lines = [];
    lines.push('export type GameSessionResponse = {');
    lines.push('  ok: true;');
    lines.push('  result: Record<string, unknown>;');
    lines.push('};');
    lines.push('');
    lines.push('export type MultiplayerMatchResponse = {');
    lines.push('  ok: true;');
    lines.push('  result: {');
    lines.push('    matchId: string;');
    lines.push('    hostPlayer: string;');
    lines.push('    guestPlayer: string;');
    lines.push('    difficulty: string;');
    lines.push('    category: string;');
    lines.push('    questionCount: number;');
    lines.push('    createdAt: string;');
    lines.push('    state: string;');
    lines.push('    playersReady: boolean;');
    lines.push('    ok: true;');
    lines.push('  };');
    lines.push('};');
    lines.push('');
    lines.push('export type AiDifficultyCalibrationResponse = {');
    lines.push('  ok: true;');
    lines.push('  result: {');
    lines.push('    playerAccuracy: number;');
    lines.push('    responseTimeMs: number;');
    lines.push('    recommendedDifficulty: string;');
    lines.push('    ok: true;');
    lines.push('  };');
    lines.push('};');

    const output = lines.join("\n");
    console.log(output);
    return output;
}

module.exports = { main };

if (require.main === module) {
    main();
}
