import KidsLanding from "./features/kids/KidsLanding";
import AdultsLanding from "./features/adults/AdultsLanding";
import SeniorsLanding from "./features/seniors/SeniorsLanding";

export function getMindLabRouteTarget(activeCategory) {
  if (activeCategory === "kids") {
    return "kids-feature";
  }

  if (activeCategory === "adults") {
    return "adults-feature";
  }

  if (activeCategory === "seniors") {
    return "seniors-feature";
  }

  return "invalid";
}

export default function MindLabModeRouter({ activeCategory }) {
  const routeTarget = getMindLabRouteTarget(activeCategory);

  if (routeTarget === "kids-feature") {
    return <KidsLanding />;
  }

  if (routeTarget === "adults-feature") {
    return <AdultsLanding />;
  }

  if (routeTarget === "seniors-feature") {
    return <SeniorsLanding />;
  }

  return (
    <main role="main" style={{ padding: "24px", fontFamily: "Arial, sans-serif" }}>
      <h1>MindLab</h1>
      <p>Unable to load the selected age category.</p>
    </main>
  );
}
