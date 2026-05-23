export const ANALYTICS_EVENTS = {
  APP_LOADED: "app_loaded",
  PRACTICE_STARTED: "practice_started",
  QUESTION_VIEWED: "question_viewed",
  ANSWER_SUBMITTED: "answer_submitted",
  PRACTICE_COMPLETED: "practice_completed",
  PRACTICE_RESTARTED: "practice_restarted",
} as const;

export type MindLabAnalyticsEvent =
  (typeof ANALYTICS_EVENTS)[keyof typeof ANALYTICS_EVENTS];

export type MindLabAgeGroup = "kids" | "teens" | "adults" | "unknown";

type BasePayload = {
  age_group?: MindLabAgeGroup;
};

export type MindLabAnalyticsPayload = {
  app_loaded: {
    app_version?: string;
    page_path?: string;
  };
  practice_started: BasePayload & {
    source: "home_screen";
  };
  question_viewed: BasePayload & {
    question_index: number;
    total_questions: number;
  };
  answer_submitted: BasePayload & {
    question_index: number;
    is_correct: boolean;
  };
  practice_completed: BasePayload & {
    score: number;
    total_questions: number;
    completion_status: "completed";
  };
  practice_restarted: {
    previous_age_group?: MindLabAgeGroup;
    next_action: "replay" | "choose_age_group";
  };
};

export type MindLabAnalyticsRecord<T extends MindLabAnalyticsEvent> = {
  event: T;
  payload: Readonly<MindLabAnalyticsPayload[T]>;
};

export const ANALYTICS_ENABLED = false;

export function trackMindLabEvent<T extends MindLabAnalyticsEvent>(
  event: T,
  payload: MindLabAnalyticsPayload[T],
): MindLabAnalyticsRecord<T> {
  const record: MindLabAnalyticsRecord<T> = {
    event,
    payload: Object.freeze({ ...payload }),
  };

  if (!ANALYTICS_ENABLED) {
    return record;
  }

  return record;
}

let mindLabAnalyticsDomBridgeStarted = false;

function getMindLabVisibleText(target: EventTarget | null): string {
  if (!(target instanceof HTMLElement)) {
    return "";
  }

  return target.textContent?.trim().toLowerCase() ?? "";
}

function getMindLabAgeGroupFromPage(): MindLabAgeGroup {
  if (typeof document === "undefined") {
    return "unknown";
  }

  const pageText = document.body?.textContent?.toLowerCase() ?? "";

  if (pageText.includes("adult")) {
    return "adults";
  }

  if (pageText.includes("teen")) {
    return "teens";
  }

  if (pageText.includes("kid") || pageText.includes("child")) {
    return "kids";
  }

  return "unknown";
}

function getMindLabProgressSnapshot(): {
  question_index: number;
  total_questions: number;
} {
  if (typeof document === "undefined") {
    return {
      question_index: 0,
      total_questions: 0,
    };
  }

  const pageText = document.body?.textContent ?? "";
  const match = pageText.match(/(\d+)\s*(?:\/|of)\s*(\d+)/i);
  const visibleQuestionNumber = match ? Number(match[1]) : 1;
  const visibleTotalQuestions = match ? Number(match[2]) : 0;

  return {
    question_index: Math.max(0, visibleQuestionNumber - 1),
    total_questions: Math.max(0, visibleTotalQuestions),
  };
}

export function startMindLabAnalyticsDomBridge(): () => void {
  if (mindLabAnalyticsDomBridgeStarted || typeof document === "undefined") {
    return () => undefined;
  }

  mindLabAnalyticsDomBridgeStarted = true;

  trackMindLabEvent(ANALYTICS_EVENTS.APP_LOADED, {
    app_version: "1.0.0",
    page_path: typeof window === "undefined" ? "app" : window.location.pathname,
  });

  let lastQuestionKey = "";
  let lastFeedbackKey = "";
  let lastCompletionKey = "";

  const trackQuestionViewed = (): void => {
    const progress = getMindLabProgressSnapshot();
    const ageGroup = getMindLabAgeGroupFromPage();
    const questionKey = `${ageGroup}:${progress.question_index}:${progress.total_questions}`;

    if (questionKey === lastQuestionKey) {
      return;
    }

    lastQuestionKey = questionKey;

    trackMindLabEvent(ANALYTICS_EVENTS.QUESTION_VIEWED, {
      age_group: ageGroup,
      question_index: progress.question_index,
      total_questions: progress.total_questions,
    });
  };

  const trackAnswerFeedback = (): void => {
    const pageText = document.body?.textContent?.toLowerCase() ?? "";
    const hasCorrectFeedback = pageText.includes("correct");
    const hasIncorrectFeedback = pageText.includes("not quite") || pageText.includes("incorrect");

    if (!hasCorrectFeedback && !hasIncorrectFeedback) {
      return;
    }

    const progress = getMindLabProgressSnapshot();
    const ageGroup = getMindLabAgeGroupFromPage();
    const feedbackKey = `${ageGroup}:${progress.question_index}:${hasCorrectFeedback}:${hasIncorrectFeedback}`;

    if (feedbackKey === lastFeedbackKey) {
      return;
    }

    lastFeedbackKey = feedbackKey;

    trackMindLabEvent(ANALYTICS_EVENTS.ANSWER_SUBMITTED, {
      age_group: ageGroup,
      question_index: progress.question_index,
      is_correct: hasCorrectFeedback && !hasIncorrectFeedback,
    });
  };

  const trackCompletion = (): void => {
    const pageText = document.body?.textContent?.toLowerCase() ?? "";

    if (!pageText.includes("result") && !pageText.includes("score")) {
      return;
    }

    const scoreMatch = pageText.match(/score[^0-9]*(\d+)/i);
    const totalMatch = pageText.match(/(?:\/|of)\s*(\d+)/i);
    const score = scoreMatch ? Number(scoreMatch[1]) : 0;
    const totalQuestions = totalMatch ? Number(totalMatch[1]) : getMindLabProgressSnapshot().total_questions;
    const ageGroup = getMindLabAgeGroupFromPage();
    const completionKey = `${ageGroup}:${score}:${totalQuestions}`;

    if (completionKey === lastCompletionKey) {
      return;
    }

    lastCompletionKey = completionKey;

    trackMindLabEvent(ANALYTICS_EVENTS.PRACTICE_COMPLETED, {
      age_group: ageGroup,
      score,
      total_questions: Math.max(0, totalQuestions),
      completion_status: "completed",
    });
  };

  const handleClick = (event: MouseEvent): void => {
    const clickedButton =
      event.target instanceof HTMLElement ? event.target.closest("button") : null;

    const buttonText = getMindLabVisibleText(clickedButton);

    if (!buttonText) {
      return;
    }

    const ageGroup = getMindLabAgeGroupFromPage();

    if (buttonText.includes("start practice")) {
      trackMindLabEvent(ANALYTICS_EVENTS.PRACTICE_STARTED, {
        age_group: ageGroup,
        source: "home_screen",
      });

      trackQuestionViewed();
      return;
    }

    if (
      buttonText.includes("replay") ||
      buttonText.includes("play again") ||
      buttonText.includes("choose another age group")
    ) {
      trackMindLabEvent(ANALYTICS_EVENTS.PRACTICE_RESTARTED, {
        previous_age_group: ageGroup,
        next_action: buttonText.includes("replay") || buttonText.includes("play again")
          ? "replay"
          : "choose_age_group",
      });
    }
  };

  const observer = new MutationObserver(() => {
    trackQuestionViewed();
    trackAnswerFeedback();
    trackCompletion();
  });

  document.addEventListener("click", handleClick);
  observer.observe(document.body, {
    childList: true,
    subtree: true,
    characterData: true,
  });

  return () => {
    document.removeEventListener("click", handleClick);
    observer.disconnect();
    mindLabAnalyticsDomBridgeStarted = false;
  };
}

