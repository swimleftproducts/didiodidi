"""Drift guard: the ingest action bundles its own copy of the schema (DO
Functions only deploys each action's own directory), so this copy must be
kept byte-identical to contract/schema/snapshot.schema.json, the source of
truth (CLAUDE.md Section 5).
"""
import pathlib

REPO_ROOT = pathlib.Path(__file__).parent.parent.parent
CANONICAL = REPO_ROOT / "contract" / "schema" / "snapshot.schema.json"
BUNDLED = (
    REPO_ROOT
    / "functions"
    / "packages"
    / "didiodidi"
    / "ingest"
    / "snapshot.schema.json"
)


def test_bundled_schema_matches_canonical_source():
    assert BUNDLED.read_text() == CANONICAL.read_text(), (
        "functions/packages/didiodidi/ingest/snapshot.schema.json has drifted "
        "from contract/schema/snapshot.schema.json — re-copy it: "
        "cp contract/schema/snapshot.schema.json "
        "functions/packages/didiodidi/ingest/snapshot.schema.json"
    )
