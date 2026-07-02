"""didiodidi /ingest — validates a snapshot payload, renders it to static
HTML via Jinja2 (autoescape on), and PUTs it to DigitalOcean Spaces.

See CLAUDE.md Section 8 for the full spec. Order of operations is fixed and
fails fast: CORS/OPTIONS -> parse -> schema validate -> schema_version ->
username/slug -> image URIs -> render -> PUT -> return URL.
"""
import json
import os
import re
import socket
import traceback
from pathlib import Path

# Force IPv4-only DNS resolution for every socket-based call in this process
# (urllib, http.client, botocore/urllib3 all resolve addresses through this).
# Symptom that led here: even a trivial urllib GET to a bare IPv4 literal
# (https://1.1.1.1, no DNS involved) hung for ~30s in this deployed
# container, while local calls to the same hosts were instant — consistent
# with an IPv6 route that's black-holed (resolves but never connects), and
# Python's stdlib tries resolved addresses sequentially with a full timeout
# each rather than racing them (no Happy Eyeballs), so any IPv6 address
# ahead of a working IPv4 one in getaddrinfo's result eats a full timeout
# before falling back.
_original_getaddrinfo = socket.getaddrinfo


def _ipv4_only_getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
    return _original_getaddrinfo(host, port, socket.AF_INET, type, proto, flags)


socket.getaddrinfo = _ipv4_only_getaddrinfo

# Heavy third-party imports (boto3 in particular) are deferred into _init()/
# _spaces_client() rather than done at module level. Cold-start import time
# counts against the request's execution budget just like any other code,
# and boto3's import alone can be a large fraction of a serverless cold
# start — deferring it means a request that never needs Spaces (or fails
# validation before reaching it) doesn't pay that cost.
_HERE = Path(__file__).parent

_VALIDATOR = None
_JINJA_ENV = None


def _init():
    global _VALIDATOR, _JINJA_ENV
    if _VALIDATOR is not None:
        return
    import jsonschema
    from jinja2 import Environment, FileSystemLoader, select_autoescape

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
    import boto3

    return boto3.client(
        "s3",
        endpoint_url=os.environ["SPACES_ENDPOINT"],
        region_name=os.environ.get("SPACES_REGION", "sfo3"),
        aws_access_key_id=os.environ["SPACES_KEY"],
        aws_secret_access_key=os.environ["SPACES_SECRET"],
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

    if method.lower() == "get":
        # TEMPORARY DIAGNOSTIC, will revert: test raw outbound HTTPS
        # connectivity to a few destinations, independent of boto3/Spaces,
        # to isolate whether a hang is Spaces-specific or affects all
        # outbound calls from this deployed function.
        import time
        import urllib.request

        results = {}
        for name, url in [
            ("digitalocean_dot_com", "https://www.digitalocean.com"),
            ("spaces_endpoint_raw", "https://sfo3.digitaloceanspaces.com"),
            ("cloudflare_dns", "https://1.1.1.1"),
        ]:
            t0 = time.time()
            try:
                urllib.request.urlopen(url, timeout=6)
                results[name] = f"ok in {time.time() - t0:.2f}s"
            except Exception as exc:
                results[name] = (
                    f"{exc.__class__.__name__}: {exc} after {time.time() - t0:.2f}s"
                )

        # All probes above are bodyless GETs. Test whether a PUT WITH A BODY
        # specifically is what hangs (independent of boto3 entirely).
        t0 = time.time()
        try:
            req = urllib.request.Request(
                "https://sfo3.digitaloceanspaces.com/didiodidi/claude-debug-raw-put.txt",
                data=b"raw put body test" * 100,
                method="PUT",
                headers={"Content-Type": "text/plain"},
            )
            urllib.request.urlopen(req, timeout=8)
            results["raw_put_with_body"] = f"ok in {time.time() - t0:.2f}s"
        except Exception as exc:
            results["raw_put_with_body"] = (
                f"{exc.__class__.__name__}: {exc} after {time.time() - t0:.2f}s"
            )

        return _response(200, results)

    body = args.get("http", {}).get("body")
    if body is not None:
        try:
            payload = json.loads(body) if isinstance(body, str) else body
        except (TypeError, ValueError):
            return _error(400, "Malformed JSON body")
    else:
        # In practice, the platform merges the parsed JSON body's fields
        # directly into the top-level args rather than nesting it under
        # http.body — but it also adds an "http" key of its own (method/
        # headers, no body) alongside them, which isn't part of our payload.
        payload = {
            k: v for k, v in args.items() if not k.startswith("__ow_") and k != "http"
        }

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
