import { getPracticeDashboard } from "@/lib/practice-api";

type HomeProps = {
  searchParams: Promise<{ error?: string; saved?: string }>;
};

export default async function Home({ searchParams }: HomeProps) {
  const query = await searchParams;
  let loadError = "";
  let targets: Awaited<ReturnType<typeof getPracticeDashboard>>["targets"] = [];
  let sessions: Awaited<ReturnType<typeof getPracticeDashboard>>["sessions"] = [];

  try {
    const dashboard = await getPracticeDashboard();
    targets = dashboard.targets;
    sessions = dashboard.sessions;
  } catch {
    loadError = "Practice data is unavailable.";
  }

  const error = query.error ?? loadError;

  return (
    <main>
      <header className="hero">
        <p className="eyebrow">Instrument Practice</p>
        <h1>Make every repetition count.</h1>
        <p className="intro">
          Choose one clear focus, record how many times you practiced it, and
          leave yourself a useful note.
        </p>
      </header>

      {error && <p className="error" role="alert">{error}</p>}
      {query.saved === "1" && (
        <p className="success" role="status">Practice was recorded.</p>
      )}

      <section className="practice-card" aria-labelledby="practice-title">
        <div>
          <p className="section-label">New record</p>
          <h2 id="practice-title">What did you practice?</h2>
          <p className="muted">Add one record after completing a set of repetitions.</p>
        </div>
        <form action="/record-practice/" method="post">
          <label>
            Practice target
            <select required name="target" defaultValue={targets[0]?.id ?? ""}>
              {targets.length === 0 && <option value="">No targets available</option>}
              {targets.map((target) => (
                <option value={target.id} key={target.id}>{target.name}</option>
              ))}
            </select>
          </label>
          <label>
            Number of repetitions
            <input required name="practice_count" type="number" min="1" defaultValue="1" />
          </label>
          <label>
            Tempo <span>optional</span>
            <input name="tempo" type="number" min="1" placeholder="72 BPM" />
          </label>
          <label>
            Practice note <span>optional</span>
            <textarea name="notes" maxLength={2000} placeholder="What improved? What needs attention next time?" />
          </label>
          <button type="submit" disabled={targets.length === 0}>Record practice</button>
        </form>
      </section>

      <section className="history" aria-labelledby="history-title">
        <div className="history-heading">
          <div>
            <p className="section-label">Recent work</p>
            <h2 id="history-title">Practice history</h2>
          </div>
          <span>{sessions.length} records</span>
        </div>
        <div className="session-list">
          {sessions.length === 0 && <p className="empty">Recorded practice will appear here.</p>}
          {sessions.map((session) => (
            <article className="session" key={session.id}>
              <div>
                <h3>{session.target_detail.name}</h3>
                <p>{new Date(session.practiced_at).toLocaleDateString("en-US", { dateStyle: "medium" })}</p>
              </div>
              <strong>{session.practice_count} times</strong>
              <p className="tempo">{session.tempo ? `${session.tempo} BPM` : "Tempo not recorded"}</p>
              {session.notes && <p className="notes">{session.notes}</p>}
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}
