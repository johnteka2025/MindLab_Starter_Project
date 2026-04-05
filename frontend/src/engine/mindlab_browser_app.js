import { submitMindLabScore } from "./mindlab_score_submitter.js";

export async function runMindLabBrowserScoreFlow(payload, handlers = {}) {
  const onSuccess = handlers.onSuccess ?? (() => {});
  const onError = handlers.onError ?? (() => {});

  try {
    const response = await submitMindLabScore(payload);
    onSuccess(response);
    return response;
  } catch (error) {
    onError(error);
    throw error;
  }
}
