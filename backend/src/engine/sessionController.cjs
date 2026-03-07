"use strict";

const { buildGameState } = require("./gameState.cjs");

function buildSessionController(input){

const state = buildGameState(input || {});

return {
player: state.player,
status: state.status,
sessionActive: true,
state
};

}

module.exports={
buildSessionController
};
