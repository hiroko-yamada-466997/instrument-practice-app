import { backendApiUrl } from "@/lib/practice-api";

const frontendPublicUrl = process.env.FRONTEND_PUBLIC_URL ?? "http://localhost:3000";

function positiveInteger(value: FormDataEntryValue | null) {
  if (typeof value !== "string" || value.trim() === "") return null;
  const parsed = Number(value);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : null;
}

function redirectToDashboard(parameter: string, value: string) {
  const destination = new URL("/", frontendPublicUrl);
  destination.searchParams.set(parameter, value);

  return new Response(null, {
    status: 303,
    headers: { Location: destination.toString() },
  });
}

export async function POST(request: Request) {
  const formData = await request.formData();
  const target = positiveInteger(formData.get("target"));
  const practiceCount = positiveInteger(formData.get("practice_count"));
  const tempoValue = formData.get("tempo");
  const tempo = tempoValue === null || tempoValue === "" ? null : positiveInteger(tempoValue);
  const notesValue = formData.get("notes");
  const notes = typeof notesValue === "string" ? notesValue.slice(0, 2000) : "";

  if (target === null || practiceCount === null) {
    return redirectToDashboard(
      "error",
      "Practice target and a positive repetition count are required.",
    );
  }
  if (tempoValue !== null && tempoValue !== "" && tempo === null) {
    return redirectToDashboard("error", "Tempo must be a positive integer.");
  }

  try {
    const response = await fetch(backendApiUrl("/api/practice-sessions/"), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        target,
        practice_count: practiceCount,
        tempo,
        notes,
      }),
      cache: "no-store",
    });
    if (!response.ok) {
      return redirectToDashboard("error", "The practice record could not be saved.");
    }
  } catch {
    return redirectToDashboard("error", "The practice service is unavailable.");
  }

  return redirectToDashboard("saved", "1");
}
