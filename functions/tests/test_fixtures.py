"""Phase 0: validate every contract fixture against snapshot.schema.json."""
import json
import pathlib

import jsonschema
import pytest

REPO_ROOT = pathlib.Path(__file__).parent.parent.parent
SCHEMA_PATH = REPO_ROOT / "contract" / "schema" / "snapshot.schema.json"
FIXTURES_DIR = REPO_ROOT / "contract" / "fixtures"


@pytest.fixture(scope="module")
def schema():
    return json.loads(SCHEMA_PATH.read_text())


@pytest.fixture(scope="module")
def validator(schema):
    return jsonschema.Draft202012Validator(schema)


@pytest.mark.parametrize("fixture_path", sorted(FIXTURES_DIR.glob("*.json")))
def test_fixture_validates_against_schema(validator, fixture_path):
    payload = json.loads(fixture_path.read_text())
    errors = list(validator.iter_errors(payload))
    assert not errors, f"{fixture_path.name} failed: {errors[0].message}"


@pytest.mark.parametrize("fixture_path", sorted(FIXTURES_DIR.glob("*.json")))
def test_fixture_stats_are_consistent(fixture_path):
    payload = json.loads(fixture_path.read_text())
    total = sum(len(day["tasks"]) for day in payload["days"])
    completed = sum(
        1 for day in payload["days"] for task in day["tasks"] if task["completed"]
    )
    assert payload["stats"]["total"] == total, (
        f"{fixture_path.name}: stats.total={payload['stats']['total']} "
        f"but counted {total} tasks"
    )
    assert payload["stats"]["completed"] == completed, (
        f"{fixture_path.name}: stats.completed={payload['stats']['completed']} "
        f"but counted {completed} completed tasks"
    )


@pytest.mark.parametrize("fixture_path", sorted(FIXTURES_DIR.glob("*.json")))
def test_fixture_weekdays_are_iso(fixture_path):
    payload = json.loads(fixture_path.read_text())
    for day in payload["days"]:
        assert 1 <= day["weekday"] <= 7, (
            f"{fixture_path.name}: weekday {day['weekday']} on {day['date']} is not ISO 1–7"
        )


@pytest.mark.parametrize("fixture_path", sorted(FIXTURES_DIR.glob("*.json")))
def test_fixture_image_uris_are_valid(fixture_path):
    import re
    pattern = re.compile(r"^data:image/(png|jpeg|webp);base64,")
    payload = json.loads(fixture_path.read_text())
    for day in payload["days"]:
        for task in day["tasks"]:
            if "image" in task:
                assert pattern.match(task["image"]), (
                    f"{fixture_path.name}: task '{task['title']}' has invalid image URI"
                )
