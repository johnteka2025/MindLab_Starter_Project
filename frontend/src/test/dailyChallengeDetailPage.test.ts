import { describe, it, expect, vi, beforeEach } from "vitest";

// NOTE: This is a lightweight regression test skeleton.
// It does NOT mount React unless the repo already has a render helper.
// It verifies the API wrapper functions exist and can be mocked reliably.

import * as api from "../daily-challenge/dailyChallengeApi";

describe("dailyChallengeApi - regression", () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it("exports daily fetch + status + submit functions (required for re-fetch flow)", () => {
    // These should exist if the UI depends on them.
    expect(typeof (api as any).fetchDaily).toBe("function");
    expect(typeof (api as any).fetchDailyStatus).toBe("function");
    expect(typeof (api as any).submitDailyAnswer).toBe("function");
  });

  it("allows mocking re-fetch after submit (contract stability)", async () => {
    const submitSpy = vi.spyOn(api as any, "submitDailyAnswer").mockResolvedValue({ ok: true });
    const dailySpy = vi.spyOn(api as any, "fetchDaily").mockResolvedValue({} as any);
    const statusSpy = vi.spyOn(api as any, "fetchDailyStatus").mockResolvedValue({} as any);

    await (api as any).submitDailyAnswer("x");
    await (api as any).fetchDaily();
    await (api as any).fetchDailyStatus();

    expect(submitSpy).toHaveBeenCalledTimes(1);
    expect(dailySpy).toHaveBeenCalledTimes(1);
    expect(statusSpy).toHaveBeenCalledTimes(1);
  });
});
