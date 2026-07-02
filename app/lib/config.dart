// Single source of truth for URLs the app talks to. See CLAUDE.md Section 2/13.
//
// kIngestUrl is a placeholder until the Phase 3 App Platform Functions
// deploy assigns the ingest function's real route under api.didiodidi.com —
// update this one constant once that's live, nothing else should hardcode it.
const kIngestUrl = 'https://api.didiodidi.com/didiodidi/ingest';
const kPublicBaseUrl = 'https://share.didiodidi.com';
