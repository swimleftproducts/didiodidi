"""didiodidi /ingest — validates a snapshot payload, renders it to static
HTML via Jinja2 (autoescape on), and PUTs it to DigitalOcean Spaces.

See CLAUDE.md Section 8 for the full spec. Order of operations is fixed and
fails fast: CORS/OPTIONS -> parse -> schema validate -> schema_version ->
username/slug -> image URIs -> render -> PUT -> return URL.
"""
import json
import os
import re
import traceback
from pathlib import Path

import boto3
import jsonschema
from botocore.config import Config
from jinja2 import Environment, FileSystemLoader, select_autoescape

# Fail fast rather than let botocore's default retry/backoff burn through
# whatever request timeout the platform enforces before we can return our
# own clean error response.
_SPACES_CLIENT_CONFIG = Config(
    connect_timeout=3,
    read_timeout=4,
    retries={"max_attempts": 1},
)

_HERE = Path(__file__).parent

# Lazily initialized on first use, not at import time: if the deployed
# package layout ever doesn't include these files, we want that surfaced
# as a normal 500 response from main()'s exception handler, not a bare
# import-time crash that the platform reports as an opaque gateway error
# with zero detail (and no chance for us to log/return anything useful).
_VALIDATOR = None
_JINJA_ENV = None


def _init():
    global _VALIDATOR, _JINJA_ENV
    if _VALIDATOR is not None:
        return
    schema = json.loads((_HERE / "snapshot.schema.json").read_text())
    _VALIDATOR = jsonschema.Draft202012Validator(schema)
    _JINJA_ENV = Environment(
        loader=FileSystemLoader(str(_HERE / "templates")),
        autoescape=select_autoescape(["html", "j2"]),
    )

_USERNAME_RE = re.compile(r"^[a-z0-9_-]{1,32}$")
_SLUG_RE = re.compile(r"^[a-z2-7]{10}$")
_IMAGE_RE = re.compile(r"^data:image/(png|jpeg|webp);base64,")

_CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
}


def _response(status_code, body_dict, extra_headers=None):
    headers = {"Content-Type": "application/json", **_CORS_HEADERS}
    if extra_headers:
        headers.update(extra_headers)
    return {
        "statusCode": status_code,
        "headers": headers,
        "body": json.dumps(body_dict),
    }


def _error(status_code, message):
    return _response(status_code, {"error": message})


def _spaces_client():
    return boto3.client(
        "s3",
        endpoint_url=os.environ["SPACES_ENDPOINT"],
        region_name=os.environ.get("SPACES_REGION", "sfo3"),
        aws_access_key_id=os.environ["SPACES_KEY"],
        aws_secret_access_key=os.environ["SPACES_SECRET"],
        config=_SPACES_CLIENT_CONFIG,
    )


def handle_payload(payload):
    """Validates and renders a parsed JSON payload dict, writes it to Spaces,
    and returns a (statusCode, body_dict) tuple. Kept separate from `main`
    so tests can drive it directly without simulating DO's args envelope.
    """
    _init()
    errors = list(_VALIDATOR.iter_errors(payload))
    if errors:
        return 400, {"error": f"Schema validation failed: {errors[0].message}"}

    if payload.get("schema_version") != 1:
        return 400, {"error": f"Unsupported schema_version: {payload.get('schema_version')!r}"}

    username = payload["username"]
    if not _USERNAME_RE.match(username):
        return 400, {"error": f"Invalid username: {username!r}"}

    slug = payload["slug"]
    if not _SLUG_RE.match(slug):
        return 400, {"error": f"Invalid slug: {slug!r}"}

    for day in payload["days"]:
        for task in day["tasks"]:
            image = task.get("image")
            if image is not None and not _IMAGE_RE.match(image):
                return 400, {"error": f"Invalid image URI on task {task.get('id')!r}"}

    template = _JINJA_ENV.get_template("snapshot.html.j2")
    html = template.render(**payload)

    bucket = os.environ["SPACES_BUCKET"]
    key = f"{username}-{slug}"
    _spaces_client().put_object(
        Bucket=bucket,
        Key=key,
        Body=html.encode("utf-8"),
        ContentType="text/html",
        ACL="public-read",
    )

    public_base_url = os.environ["PUBLIC_BASE_URL"].rstrip("/")
    return 200, {"url": f"{public_base_url}/{key}"}


def main(args):
    method = args.get("http", {}).get("method") or args.get("__ow_method", "post")
    if method.lower() == "options":
        return _response(200, {})

    # TEMPORARY DEBUG — remove before merging. Proves whether POST reaches
    # this code at all and reveals the real shape of `args`.
    return _response(200, {"debug_args": {k: str(v)[:80] for k, v in args.items()}})

    body = args.get("http", {}).get("body")
    if body is not None:
        try:
            payload = json.loads(body) if isinstance(body, str) else body
        except (TypeError, ValueError):
            return _error(400, "Malformed JSON body")
    else:
        payload = {k: v for k, v in args.items() if not k.startswith("__ow_")}

    if not isinstance(payload, dict):
        return _error(400, "Malformed JSON body")

    try:
        status_code, body_dict = handle_payload(payload)
    except (KeyError, TypeError) as exc:
        return _error(400, f"Malformed payload: {exc}")
    except Exception as exc:
        # Last resort: without this, an unexpected error (e.g. a Spaces auth
        # failure) propagates out of main() and the platform's own gateway
        # returns an opaque "There was an error processing your request."
        # with no detail in the response body. Full traceback still goes to
        # the run logs; only a generic message reaches the client.
        traceback.print_exc()
        return _error(500, f"Internal error: {exc.__class__.__name__}: {exc}")

    return _response(status_code, body_dict)
