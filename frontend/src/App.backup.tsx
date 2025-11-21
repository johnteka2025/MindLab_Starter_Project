import HealthPanel from "./components/HealthPanel";
export default function App(){
  const apiBase = import.meta.env.VITE_API_BASE;
  return (
    <main className="p-8">
      <h1 className="text-4xl font-bold mb-4">MindLab Frontend</h1>
      <p className="mb-4 text-sm">API base: {apiBase}</p>
      <HealthPanel />
    </main>
  );
}
