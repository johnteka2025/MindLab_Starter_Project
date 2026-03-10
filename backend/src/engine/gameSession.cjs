"use strict";

function buildGameSession(input){

const player = input && input.player ? input.player : "";
const difficulty = input && input.difficulty ? input.difficulty : "medium";
const question = input && input.question ? input.question : "";
const startedAt = new Date().toISOString();

return {

player,
difficulty,
question,
startedAt,
status:"active"

};

}

module.exports={buildGameSession};
