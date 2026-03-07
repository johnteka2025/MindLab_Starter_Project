"use strict";

function normalizeAnswer(value) {
  if (value === null || value === undefined) {
    return "";
  }
  return String(value).trim().toLowerCase();
}

function validateAnswer(expectedAnswer, submittedAnswer) {
  const expected = normalizeAnswer(expectedAnswer);
  const submitted = normalizeAnswer(submittedAnswer);

  return {
    ok: expected.length > 0 && submitted.length > 0 && expected === submitted,
    expected,
    submitted
  };
}

module.exports = {
  normalizeAnswer,
  validateAnswer
};
