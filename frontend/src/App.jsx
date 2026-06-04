import MindLabAgeProfileGate from "./mindlab-profile-age-repair/MindLabAgeProfileGate";
import MindLabOriginalApp from "./MindLabOriginalApp";

export default function App() {
  return (
    <MindLabAgeProfileGate>
      <MindLabOriginalApp />
    </MindLabAgeProfileGate>
  );
}
