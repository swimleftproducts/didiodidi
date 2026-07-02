# CLAUDE.md — didiodidi

> **didiodidi** = "did I do it or didn't I do it." A local-first Flutter app for tracking a
> recurring to-do list (built for physical-therapy exercises), with a one-tap **share**
> that publishes a static, read-only web snapshot of the last 7 days.

This file is the build contract. When in doubt, the **Hard Constraints** section wins over
convenience. Build **test-first**, one phase at a time (see **Build Phases**).

---

## 1. What we're building

A personal, no-account exercise/task tracker.

- **Flutter app** (Android first) — all data stored **locally on the device**. No login, no cloud DB.
- **Two primary screens**: a daily list (today's tasks + done/not-done) and an input screen
  (add/edit a task, by form or by photo→LLM).
- **Share**: tapping share builds a self-contained HTML snapshot of the last 7 days and POSTs it
  to a single serverless function, which stores it as a static file. The snapshot is then readable
  at `share.didiodidi.com/{username}-{slug}` by anyone with the link.
- **Landing page**: `didiodidi.com` itself is a separate static marketing page (App Platform,
  `landing/`) explaining the app and linking to the Android download. It is not part of the
  share/ingest flow — see Section 13a.
- **Reminders**: three local notifications per day (morning / midday / evening).

Two languages: **Dart** (the app) and **Python** (the one serverless function). They meet only
at a JSON payload, which is governed by a shared, version-controlled **contract** (Section 5).

---

## 2. Architecture — two stores, one direction of flow

There is no server-side database. There are exactly two places data lives:

1. **On-device SQLite** (via `drift`) — the source of truth for tasks, completions, and image
   file paths. The app reads/writes this **directly**. It never travels through the function.
2. **DigitalOcean Spaces** — a dumb blob store holding published HTML snapshots. Written **only**
   by the function, at share time.

```
┌────────────────────────── PHONE ──────────────────────────┐
│  Flutter app                                               │
│   ├─ drift / SQLite  ← tasks, completions, image paths     │  (local only, never leaves device)
│   ├─ flutter_secure_storage ← device secret, Anthropic key │
│   └─ Share button                                          │
│         │ builds self-contained HTML snapshot (last 7 days)│
│         │ POST {contract JSON}                             │
└─────────┼──────────────────────────────────────────────────┘
          ▼
   /ingest   (Python serverless function — the ONLY writer to Spaces; exact invoke domain TBD, see 13a)
          │ validate → render (Jinja2, autoescape) → PUT
          ▼
   DigitalOcean Spaces  →  CDN  →  share.didiodidi.com/{username}-{slug}  (public, static, read-only)
```

The read path has **no function**: `share.didiodidi.com/{username}-{slug}` is served straight from
the Spaces CDN via a DNS CNAME directly to the CDN endpoint — it never touches App Platform or the
function. The function exists only to write.

`didiodidi.com` (bare root) is a **separate App Platform app** serving the static landing page —
it shares nothing with the share/ingest path. Because the root domain now belongs to App Platform,
the ingest function needs its own routing (a DO Functions invoke URL, or an `api.` subdomain) that
doesn't collide with either `didiodidi.com` or the `share.` CNAME — **not yet decided, revisit in
Phase 3.**

---

## 3. Hard Constraints (non-negotiable)

1. **Local data never leaves the device except inside a share snapshot the user explicitly triggers.**
2. **Only the function may hold Spaces write credentials.** They live in the function's environment,
   never in the app, never in a snapshot, never in the repo. The app cannot write to Spaces.
3. **Payload ceiling ≈ 1.8 MB.** DigitalOcean Functions reject request bodies above ~2 MB
   (`Request larger than allowed: … > 2097152 bytes`) despite docs claiming 5 MB. The generated
   snapshot HTML — including all embedded base64 thumbnails — **must** stay under **1.8 MB**. The
   app must enforce this before POSTing (downscale/recompress thumbnails; drop images if needed) and
   surface a clear error rather than sending an oversized body.
4. **All task-supplied text is data, never markup.** The function renders via **Jinja2 with
   autoescaping ON**, into a fixed template. A task titled `<script>…</script>` must render as inert
   text. Never build HTML by string concatenation in the function.
5. **Image sources must be validated `data:image/...` URIs.** The function rejects any `image` value
   that does not match `^data:image/(png|jpeg|webp);base64,`. No `http:`, no `javascript:`.
6. **The function is stateless by default.** It stores nothing but the rendered page. It does not
   verify slug ownership (see Section 9 for the security model and the opt-in hardening).
7. **The contract is the source of truth** (Section 5). Neither the Dart models nor the Python code
   may diverge from `contract/schema/snapshot.schema.json`.

---

## 4. Repository layout

```
~/git/didiodidi/
├── CLAUDE.md                     # this file
├── landing/                      # static marketing page, deployed via App Platform to didiodidi.com
│   └── index.html
├── contract/                     # the single source of truth for the app↔function payload
│   ├── schema/
│   │   └── snapshot.schema.json  # JSON Schema (draft 2020-12). THE contract.
│   └── fixtures/                 # golden payloads BOTH test suites pin to
│       ├── minimal.json
│       ├── full_week.json
│       └── with_images.json
├── app/                          # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── data/                 # drift database, DAOs, repositories
│   │   ├── domain/               # pure Dart: due-logic, snapshot builder, slug, models
│   │   ├── services/             # ShareService (HTTP), NotificationService, IngestLlmService
│   │   └── ui/                   # DailyListScreen, TaskInputScreen, SettingsScreen
│   ├── test/
│   └── pubspec.yaml
└── functions/                    # DigitalOcean Functions project
    ├── project.yml
    ├── packages/
    │   └── didiodidi/
    │       └── ingest/
    │           ├── __main__.py           # def main(args): ...
    │           ├── requirements.txt      # jsonschema, jinja2, boto3
    │           └── templates/
    │               └── snapshot.html.j2
    └── tests/                    # pytest + moto (kept out of the deployed action)
        └── test_ingest.py
```

---

## 5. The data contract (this is where cross-language apps break — make it structural)

**Rule: the schema is truth. Dart and Python are both subordinate to it.**

Three guards, all cheap, together make silent drift essentially impossible:

- **Runtime guard** — the function validates every incoming payload against
  `snapshot.schema.json` with `jsonschema` as the *first* thing it does, returning HTTP 400 on any
  mismatch. It never renders unvalidated input.
- **Drift guard** — the golden fixtures in `contract/fixtures/` are shared. Dart tests assert the
  app **serializes to** those exact fixtures; Python tests load the **same** files and assert the
  function accepts and renders them; a small test validates every fixture against the schema. Rename
  a field on either side and that side's fixture test fails immediately.
- **Evolution guard** — every payload carries `schema_version` (integer). The function rejects
  unknown versions rather than guessing. Current version: **1**.

### Wire-format decisions (pinned in the schema — do not deviate)

| Concern           | Decision                                                                 |
|-------------------|--------------------------------------------------------------------------|
| Field casing      | **snake_case on the wire.** Dart maps via `FieldRename.snake` / `@JsonKey`. |
| Day of week       | **ISO integer 1–7** (Mon=1 … Sun=7). Never enum names or 0-based indices. |
| Dates             | **`YYYY-MM-DD` strings.** No timestamps, no timezones — we only track days. |
| Image field       | **Full data URI** (`data:image/jpeg;base64,…`) so the template drops it straight into `src`. |

### Payload shape (`schema_version: 1`)

```jsonc
{
  "schema_version": 1,
  "username": "alice",              // ^[a-z0-9_-]{1,32}$, lowercased by the app
  "slug": "x7f3k2q9pd",             // ^[a-z2-7]{10}$  (base32, see Section 9)
  "generated_at": "2026-07-01",     // YYYY-MM-DD
  "window": { "start": "2026-06-25", "end": "2026-07-01" },
  "stats": { "completed": 10, "total": 40 },
  "days": [
    {
      "date": "2026-06-25",
      "weekday": 3,                 // ISO 1-7
      "tasks": [
        {
          "id": "b1a2...",          // task uuid (stable across days)
          "title": "Hamstring stretch",
          "description": "3x10, hold 20s",
          "completed": true,
          "image": "data:image/jpeg;base64,/9j/4AAQ..."  // optional; omit if none
        }
      ]
    }
  ]
}
```

### Dart serialization

- Use **`freezed` + `json_serializable`** — generated, never hand-written.
- One **round-trip test** per model: `model → toJson → validate against schema` and
  `fixture → fromJson → toJson == fixture`.

---

## 6. Domain data model (on-device)

drift tables:

- **`tasks`**: `id` (uuid, PK), `title`, `description`, `active` (bool), `created_at`,
  `image_path` (nullable local filesystem path — **full-res image lives here, on device only**).
- **`task_days`**: `task_id` (FK), `weekday` (1–7). One row per active weekday. A task "due today"
  iff a row matches today's ISO weekday.
- **`completions`**: `task_id` (FK), `date` (`YYYY-MM-DD`), `completed_at`. Presence = done that
  day. Completing is a toggle (insert/delete). Enables the 7-day grid and streaks.

Design notes:
- No structured sets/reps. Prescription detail ("3x10, hold 20s") lives in `description` text.
- "Which tasks are due today" and "which are still incomplete" are **pure functions** of
  `tasks × task_days × completions` — implement in `domain/`, unit-test with no I/O.

---

## 7. Flutter app spec

### Screens
- **DailyListScreen** (landing): today's due tasks, each with a done/not-done indicator; tap to
  toggle completion. Header shows today's progress (e.g. `3/7`).
- **TaskInputScreen**: add/edit a task. Form fields = title, description, day-of-week toggles
  (styled, multi-select), optional image. Also a **"from photo"** action (Section 10).
- **SettingsScreen**: username, reminder times, Anthropic API key entry, "Share" action + display
  of the current share URL.

### Local storage
- **`drift`** with `NativeDatabase` on device. Chosen specifically so the data layer is tested
  against a **real in-memory SQLite** (`NativeDatabase.memory()`) — no mocking the DB.
- **`flutter_secure_storage`** for: the 32-byte **device secret** (base64), the **Anthropic API
  key**, and the chosen **username**.

### Reminders (three per day)
- **`flutter_local_notifications`**, three scheduled notifications:
  - **Morning** (default 08:00): all of today's task **titles**.
  - **Midday** (default 12:30): tasks **still incomplete**.
  - **Evening** (default 18:00): tasks **still incomplete**.
- **Constraint**: notification text is baked in at schedule time; it cannot query the DB when it
  fires. Therefore **recompute and reschedule all three every time the app is foregrounded or
  backgrounded** (app lifecycle observer). Morning is always accurate (deterministic from weekday
  toggles); midday/evening reflect completion state as of the last time the app was open. If the app
  isn't opened all day, they fire with last-known state — accepted failure mode. (Guaranteed-live
  content would require Android WorkManager — **deferred**, do not build in v1.)
- All three times are user-configurable.

### Share flow (client side)
1. Read username + secret from secure storage; compute `slug` (Section 9).
2. Build the last-7-days snapshot from the DB → the contract JSON.
3. For each task image: load full-res from `image_path`, **downscale** (~500px longest edge, JPEG
   q≈60) to a thumbnail, base64-encode as a `data:image/jpeg;base64,…` URI.
4. Assemble payload; **assert total < 1.8 MB** (Constraint 3). If over, progressively drop/shrink
   images and, failing that, error clearly.
5. `POST` to the ingest endpoint (Section 13a). On success, show/copy
   `share.didiodidi.com/{username}-{slug}`.
- `ShareService` is the **only** HTTP boundary; it takes an injected HTTP client so tests mock it.

---

## 8. Serverless function spec (`/ingest`, Python)

Signature: `def main(args): -> {"statusCode": int, "body": str, "headers": {...}}`.

Order of operations (fail fast, in this order):
1. Method/CORS: handle `OPTIONS`; set `Access-Control-Allow-Origin` etc. (the 413/CORS pairing is a
   known DO gotcha — get headers right).
2. Parse JSON body.
3. **Validate against `snapshot.schema.json` with `jsonschema`.** Reject → 400 with a clear message.
4. Check `schema_version == 1`. Unknown → 400.
5. Validate `username` (`^[a-z0-9_-]{1,32}$`) and `slug` (`^[a-z2-7]{10}$`).
6. Validate every `image` against `^data:image/(png|jpeg|webp);base64,` — reject otherwise.
7. Render `templates/snapshot.html.j2` with **`autoescape=True`** → HTML string.
8. `PUT` to Spaces via **boto3** (S3-compatible endpoint) at key
   `{username}-{slug}` (no folder prefix, no extension — see note below), `ContentType=text/html`,
   public-read.
9. Return 200 with the public URL: `https://share.didiodidi.com/{username}-{slug}`.

**Why no `pages/` prefix or `.html` extension on the object key:** the CDN sits directly in front of
the bucket via a plain DNS CNAME (`share.didiodidi.com` → CDN endpoint) with no reverse proxy or
rewrite layer in between, so it only ever serves **exact object-key matches** — a request for
`/{username}-{slug}` fetches the object at that literal key. `ContentType` is set explicitly on
`PUT`, so the extensionless key still serves as `text/html`. Confirmed working with a manually
uploaded `test_12345.html` object during infra setup (Section 13a).

Dependencies (`requirements.txt`): `jsonschema`, `jinja2`, `boto3`.

Config via env (never in repo): `SPACES_KEY`, `SPACES_SECRET`, `SPACES_ENDPOINT`,
`SPACES_REGION`, `SPACES_BUCKET`, `PUBLIC_BASE_URL`.

Template: renders the stat line (`{completed}/{total}`), then a responsive 7-day view — columns per
day on wide screens, stacking vertically on narrow — with each day's tasks and done/not-done marks
underneath, and thumbnails where present. Autoescape makes all task text inert.

---

## 9. Share security model (the username/slug scheme)

**Goal:** anyone can read a shared page via its link, but a stranger cannot overwrite *your* page or
hijack *your* URL — without any server-side accounts or binding store.

**Slug:** `slug = base32_lower( HMAC_SHA256(key=device_secret, msg=username) )[:10]`
(base32 alphabet lowercased → `a-z2-7`; strip padding).

- The device secret (32 random bytes, generated once, in secure storage) means only this device can
  produce this slug for this username.
- Object key = `{username}-{slug}`; public URL = `share.didiodidi.com/{username}-{slug}`.
- The app can always **recompute its own share URL** from `(secret, username)` — the slug is never
  persisted separately, and the server stores nothing.

**What this stops:** overwriting a page you didn't create (a stranger can't compute your slug ⇒
can't name your key), and reading a page whose link you weren't given (10 base32 chars ≈ 50 bits ⇒
unguessable, so the page is effectively unlisted).

**What it does NOT stop (documented limitation, matches accepted risk):**
- **Impersonation by label** — anyone can create their own page and *write* "I'm Alice" in it. This
  is unpreventable without real identity and is out of scope.
- **A person you shared the link with can overwrite your page** — because the slug is in the URL you
  handed them. The blast radius is only a defaced *static* page; your on-device data is untouched.

**Opt-in hardening (Phase 3 stretch, only if desired):** on overwrite, have the function `HEAD` the
existing object, read an `x-amz-meta-write-hash`, and require the incoming request to present a
secret whose hash matches (first write sets it). This keeps the read-slug public but makes *writes*
require the secret, which is never in the URL. It uses the object's own metadata as the binding
record — still no separate store — at the cost of one extra Spaces read per overwrite and a
"lost-secret ⇒ can't update (but can make a new URL)" failure mode. **Default is the simple stateless
scheme above; build the hardening only on request.**

---

## 10. Photo → task ingestion (Anthropic)

On TaskInputScreen, "from photo": user snaps/picks a photo of an exercise sheet; the app sends it to
the **Anthropic API** (vision) with a prompt to extract structured fields, and pre-fills the form.

- Provider: **Anthropic only** for v1. User pastes their **own** API key (secure storage).
- `IngestLlmService` sends the image + a prompt instructing the model to return **only JSON** with
  `title`, `description`, and `weekdays` (array of ISO 1–7). No prose, no markdown fences.
- Parse defensively (strip fences if present); on parse failure, fall back to an empty editable form
  rather than crashing.
- The photo itself is **attached to the task** (saved full-res to the device filesystem,
  `image_path` recorded). It becomes a thumbnail only later, at share time.
- Model id is **config, not hardcoded** (model strings change) — surface it in one constant.

---

## 11. Testing strategy — "tests for all items"

**Dart (`app/test/`):**
- **Pure domain logic**: due-today, still-incomplete, stats, streaks, slug computation — direct unit
  tests, no mocks.
- **Data layer**: run against `NativeDatabase.memory()` (real SQLite) — insert/query/toggle,
  migrations. No DB mocking.
- **Serialization**: freezed models round-trip against `contract/fixtures/*` and validate against the
  schema.
- **ShareService**: injected mock HTTP client — assert correct payload, the <1.8 MB guard, and
  response handling. This is the only place we mock.
- Widget tests for the two screens (toggle completion, add/edit task).

**Python (`functions/tests/`):**
- **pytest + `moto`** (mock S3/Spaces). Feed `main()` each fixture: assert it validates, escapes
  hostile task text (inject `<script>` and assert it's inert in output), computes the correct key,
  rejects bad `image` URIs / bad slug / unknown `schema_version`, and writes to the mocked bucket.

**Shared:** a test on each side loads `contract/fixtures/*` and validates them against
`snapshot.schema.json`, so the fixtures can't drift from the schema.

---

## 12. Build phases (test-first, one at a time)

Write the failing tests first, then the code, per phase. Do not start a phase before the prior one is
green.

- **Phase 0 — Contract skeleton.** Author `snapshot.schema.json`, the three fixtures, and the
  fixtures-validate-against-schema tests (both languages). Nothing else references anything unbuilt.
- **Phase 1 — Local app.** drift schema + DAOs, domain logic (due/incomplete/stats), the two
  screens, add/edit/complete. Full Dart tests. **No network, no images-to-cloud yet.**
- **Phase 2 — Reminders.** The three notifications + reschedule-on-lifecycle. Configurable times.
- **Phase 3 — Sharing.** The Python `/ingest` function (validate → Jinja2 autoescape → boto3 PUT),
  the snapshot template, `ShareService`, the slug scheme, the <1.8 MB guard. pytest+moto + Dart
  share tests. (Optional: the Section 9 hardening.)
- **Phase 4 — Photo ingest.** `IngestLlmService` (Anthropic), attach-image-to-task, photo→form.

---

## 13. Dev environment

- **App**: developed on a computer, run onto an Android phone via `flutter run` for local testing.
  Release builds are distributed via the **`upload-build` skill** (`.claude/skills/upload-build/`),
  which runs `flutter build apk --release` and publishes it with `s3cmd` to a fixed CDN URL —
  `https://didiodidi.sfo3.cdn.digitaloceanspaces.com/builds/didiodidi-app-release.apk` — flushing the
  CDN cache afterward. One stable filename, always overwritten, so shared links (e.g. from the
  landing page) never need to change between releases. (No Play Store, no CI signing in v1.)
- **Flutter install**: Homebrew cask (`brew install --cask flutter`), at
  `/opt/homebrew/share/flutter`, binary at `/opt/homebrew/bin/flutter`. Run as `flutter` from
  anywhere — no per-project install needed.
- **Function**: `doctl serverless` for local invoke + deploy. Python action under
  `packages/didiodidi/ingest/`. `doctl` is installed globally; run `doctl serverless connect` to
  link this project (separate namespace from other DO projects).
- **Python env**: **conda environment `didiodidi`** (Python 3.12). Create once:
  `conda create -n didiodidi python=3.12 && conda activate didiodidi && pip install -r functions/packages/didiodidi/ingest/requirements.txt`
- **LLM model constant**: `claude-sonnet-4-6` — one constant in `IngestLlmService`, never hardcoded elsewhere.
- **Domain**: `didiodidi.com` is being transferred to DigitalOcean. Use `kPublicBaseUrl` constant
  (Dart) / `PUBLIC_BASE_URL` env var (function) — never hardcode the domain.

### Commands
```
# App (from repo root)
cd app && flutter pub get
cd app && flutter test                                         # all Dart tests
cd app && flutter test test/path/to/test.dart                 # single test file
cd app && flutter run                                         # onto connected Android device

# Function (activate conda env first: conda activate didiodidi)
pytest functions/tests/                                       # all Python tests
pytest functions/tests/test_ingest.py::test_name             # single test
doctl serverless deploy functions/                           # deploy to DigitalOcean
```

---

## 13a. Infrastructure (provisioned)

DigitalOcean account: **swimleft@gmail.com**. `doctl` context name is `swimleft` — this machine also
has a `default` context on a *different* DO account (`staging@leasly.ai`, used for another project);
always confirm active context with `doctl account get` before running infra commands, and
`doctl auth switch --context swimleft` if it's wrong.

- **DO Project**: `didiodidi` (groups the resources below).
- **DNS zone**: `didiodidi.com`, hosted on DO nameservers (`ns1/ns2/ns3.digitalocean.com`) —
  delegation confirmed live.
- **Spaces bucket**: `didiodidi`, region **sfo3**. Origin: `didiodidi.sfo3.digitaloceanspaces.com`.
  Spaces access keys are separate from the `doctl` API token (console-generated only, no CLI);
  stored locally in `~/.s3cfg-didiodidi` (kept separate from an existing unrelated `~/.s3cfg` that
  points at a Cloudflare R2 account — never overwrite that file). Upload via
  `s3cmd -c ~/.s3cfg-didiodidi put <file> s3://didiodidi/<key> --acl-public --mime-type=text/html`.
- **CDN**: endpoint `didiodidi.sfo3.cdn.digitaloceanspaces.com`, custom domain
  `share.didiodidi.com` bound with a DO-managed Let's Encrypt cert. DNS: `share` CNAME →
  `didiodidi.sfo3.cdn.digitaloceanspaces.com`. Verified working with a manually uploaded
  `test_12345.html` demo object.
- **Landing page**: App Platform app `didiodidi-landing` (region `sfo`), static site component
  deployed from `swimleftproducts/didiodidi` GitHub repo, `/landing` source dir, deploy-on-push from
  `master`. Required a one-time GitHub App authorization in the DO console before `doctl apps create`
  would work (`GitHub user not authenticated` otherwise). Custom domain `didiodidi.com` bound to this
  app (done manually in console).
- **Not yet done**: the ingest function itself hasn't been deployed or given a routable domain (see
  Section 2's open note); the `pages/` fixtures/templates in `functions/` predate the object-key
  decision above and should be checked for consistency when Phase 3 starts.

---

## 14. Deferred / out of scope for v1

- Guaranteed-live reminder content (Android WorkManager).
- Full-resolution or many-image sharing via presigned PUT (only needed if a snapshot must exceed the
  1.8 MB ceiling; the single-blob presigned PUT is the escape hatch, not per-image links).
- Clean/owned usernames (`share.didiodidi.com/alice`) — requires a stateful binding store.
- iOS build, Play Store distribution, multi-provider LLM.
