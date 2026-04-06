import { kidsPackIndex } from "./mindlab_kids_pack_index.js";

export function getKidsPuzzleByStage(stage = "K1", index = 0) {
  const pack = kidsPackIndex[stage] || kidsPackIndex.K1 || [];
  return pack[index] || pack[0] || null;
}