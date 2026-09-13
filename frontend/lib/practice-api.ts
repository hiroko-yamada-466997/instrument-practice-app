export type PracticeTarget = {
  id: number;
  name: string;
  kind: "piece" | "exercise" | "technique";
  composer: string;
};

export type PracticeSession = {
  id: number;
  target: number;
  target_detail: PracticeTarget;
  practiced_at: string;
  practice_count: number;
  tempo: number | null;
  notes: string;
};

const backendUrl = (process.env.BACKEND_INTERNAL_URL ?? "http://localhost:8000").replace(
  /\/$/,
  "",
);

export function backendApiUrl(path: string) {
  return `${backendUrl}${path}`;
}

async function getJson<T>(path: string): Promise<T> {
  const response = await fetch(backendApiUrl(path), { cache: "no-store" });
  if (!response.ok) {
    throw new Error(`Backend request failed with status ${response.status}.`);
  }
  return response.json() as Promise<T>;
}

export async function getPracticeDashboard() {
  const [targets, sessions] = await Promise.all([
    getJson<PracticeTarget[]>("/api/practice-targets/"),
    getJson<PracticeSession[]>("/api/practice-sessions/"),
  ]);
  return { targets, sessions };
}
