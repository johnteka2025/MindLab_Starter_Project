import MindLabAgeProfileGate from "./mindlab-profile-age-repair/MindLabAgeProfileGate";
import MindLabModeRouter from "./MindLabModeRouter";

export default function App() {
  return (
    <MindLabAgeProfileGate>
      {({ profile, activeCategory }) => (
        <MindLabModeRouter
          activeCategory={activeCategory}
          profileName={profile?.name || "MindLab Player"}
        />
      )}
    </MindLabAgeProfileGate>
  );
}
