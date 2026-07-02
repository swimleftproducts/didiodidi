"""Phase 3: pytest + moto tests for the /ingest function.

Feeds every contract fixture through main()/handle_payload() and asserts:
validation, XSS-inert rendering, rejection of bad image/slug/schema_version,
correct object key, and writes landing in the mocked bucket.
"""
import json

import pytest

from conftest import TEST_ENV, fixture_paths


@pytest.mark.parametrize("fixture_path", fixture_paths())
def test_every_fixture_validates_and_writes(ingest, spaces_bucket, fixture_path):
    payload = json.loads(fixture_path.read_text())
    status, body = ingest.handle_payload(payload)

    assert status == 200, f"{fixture_path.name}: {body}"
    expected_key = f"{payload['username']}-{payload['slug']}"
    assert body["url"] == f"{TEST_ENV['PUBLIC_BASE_URL']}/{expected_key}"

    obj = spaces_bucket.get_object(Bucket=TEST_ENV["SPACES_BUCKET"], Key=expected_key)
    assert obj["ContentType"] == "text/html"
    html = obj["Body"].read().decode("utf-8")
    assert "<!DOCTYPE html>" in html
    for day in payload["days"]:
        for task in day["tasks"]:
            assert task["title"] in html


def test_xss_task_title_is_escaped(ingest, spaces_bucket, minimal_payload):
    hostile = "<script>alert(1)</script>"
    minimal_payload["days"][0]["tasks"][0]["title"] = hostile
    minimal_payload["days"][0]["tasks"][0]["description"] = hostile

    status, _ = ingest.handle_payload(minimal_payload)
    assert status == 200

    key = f"{minimal_payload['username']}-{minimal_payload['slug']}"
    obj = spaces_bucket.get_object(Bucket=TEST_ENV["SPACES_BUCKET"], Key=key)
    html = obj["Body"].read().decode("utf-8")

    assert "<script>" not in html
    assert "&lt;script&gt;" in html


@pytest.mark.parametrize(
    "bad_image",
    [
        "http://evil.com/x.png",
        "javascript:alert(1)",
        "data:text/html;base64,PHNjcmlwdD4=",
        "data:image/gif;base64,R0lGODlh",  # gif not in the allowed set
    ],
)
def test_rejects_bad_image_uri(ingest, minimal_payload, bad_image):
    minimal_payload["days"][0]["tasks"][0]["image"] = bad_image
    status, body = ingest.handle_payload(minimal_payload)
    assert status == 400
    assert "image" in body["error"].lower()


@pytest.mark.parametrize("bad_slug", ["short", "TOOLONG123", "has-dash-01", "1234567890"])
def test_rejects_bad_slug(ingest, minimal_payload, bad_slug):
    minimal_payload["slug"] = bad_slug
    status, body = ingest.handle_payload(minimal_payload)
    assert status == 400


@pytest.mark.parametrize("bad_username", ["", "Has-Caps", "a" * 33, "spaces here"])
def test_rejects_bad_username(ingest, minimal_payload, bad_username):
    minimal_payload["username"] = bad_username
    status, body = ingest.handle_payload(minimal_payload)
    assert status == 400


@pytest.mark.parametrize("bad_version", [2, 0, "1", None])
def test_rejects_unknown_schema_version(ingest, minimal_payload, bad_version):
    # Caught by schema validation (const: 1) before our own explicit check —
    # either way it must be a 400, never a render/write.
    minimal_payload["schema_version"] = bad_version
    status, body = ingest.handle_payload(minimal_payload)
    assert status == 400


def test_computes_correct_object_key(ingest, spaces_bucket, minimal_payload):
    status, body = ingest.handle_payload(minimal_payload)
    assert status == 200
    assert body["url"].endswith(
        f"{minimal_payload['username']}-{minimal_payload['slug']}"
    )


def test_options_request_returns_cors_headers(ingest):
    result = ingest.main({"http": {"method": "OPTIONS"}})
    assert result["statusCode"] == 200
    assert result["headers"]["Access-Control-Allow-Origin"] == "*"
    assert "POST" in result["headers"]["Access-Control-Allow-Methods"]


def test_main_parses_json_string_body(ingest, spaces_bucket, minimal_payload):
    result = ingest.main(
        {"http": {"method": "POST", "body": json.dumps(minimal_payload)}}
    )
    assert result["statusCode"] == 200
    body = json.loads(result["body"])
    assert body["url"].endswith(
        f"{minimal_payload['username']}-{minimal_payload['slug']}"
    )
