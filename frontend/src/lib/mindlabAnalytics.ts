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
