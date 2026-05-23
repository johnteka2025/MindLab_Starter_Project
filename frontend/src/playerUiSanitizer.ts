const RAW_JSON_KEYS = [
  '"ok"',
  '"session"',
  '"question"',
  '"progress"',
  '"nextQuestion"',
  '"currentIndex"',
  '"score"',
  '"category"'
];

function looksLikeRawJson(text: string): boolean {
  const trimmed = text.trim();

  if (!trimmed.startsWith("{") && !trimmed.startsWith("[")) {
    return false;
  }

  return RAW_JSON_KEYS.some((key) => trimmed.includes(key));
}

function makeStatusCard(kind: "answer" | "result"): HTMLDivElement {
  const card = document.createElement("div");
  card.setAttribute("role", "status");
  card.setAttribute("data-mindlab-player-card", kind);
  card.style.padding = "1rem";
  card.style.borderRadius = "0.75rem";
  card.style.background = "#f8fafc";
  card.style.border = "1px solid #e2e8f0";
  card.style.lineHeight = "1.6";
  card.style.marginTop = "1rem";
  card.style.marginBottom = "1rem";

  const strong = document.createElement("strong");
  strong.textContent = kind === "answer" ? "Answer saved." : "Result saved.";

  const paragraph = document.createElement("p");
  paragraph.style.margin = "0.5rem 0 0 0";
  paragraph.textContent =
    kind === "answer"
      ? "Continue to the next question or view your result when the session is complete."
      : "Start another session to keep practicing.";

  card.appendChild(strong);
  card.appendChild(paragraph);

  return card;
}

function replaceTextLabels(): void {
  const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
  const nodes: Text[] = [];

  while (walker.nextNode()) {
    nodes.push(walker.currentNode as Text);
  }

  for (const node of nodes) {
    if (!node.nodeValue) {
      continue;
    }

    node.nodeValue = node.nodeValue
      .replace(/Answer submitted/g, "Answer saved")
      .replace(/View progress/g, "View result");
  }

  for (const heading of Array.from(document.querySelectorAll("h1,h2,h3,h4,h5,h6"))) {
    if (heading.textContent?.trim() === "Progress") {
      heading.textContent = "Result";
    }
  }
}

function replaceRawJsonBlocks(): void {
  const candidates = Array.from(document.querySelectorAll("pre, code, textarea"));

  for (const candidate of candidates) {
    const text = candidate.textContent || "";

    if (!looksLikeRawJson(text)) {
      continue;
    }

    const pageText = document.body.textContent || "";
    const kind = pageText.includes("Start another session") ? "result" : "answer";
    const card = makeStatusCard(kind);

    candidate.replaceWith(card);
  }
}

function sanitizePlayerUi(): void {
  if (!document.body) {
    return;
  }

  replaceTextLabels();
  replaceRawJsonBlocks();
}

export function installPlayerUiSanitizer(): void {
  if (typeof window === "undefined") {
    return;
  }

  const run = () => sanitizePlayerUi();

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run, { once: true });
  } else {
    run();
  }

  const observer = new MutationObserver(() => run());

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true,
    characterData: true
  });
}

installPlayerUiSanitizer();