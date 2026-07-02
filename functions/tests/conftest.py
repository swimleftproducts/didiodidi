import copy
import importlib.util
import json
import pathlib

import boto3
import pytest
from moto import mock_aws

REPO_ROOT = pathlib.Path(__file__).parent.parent.parent
INGEST_MAIN = (
    REPO_ROOT / "functions" / "packages" / "didiodidi" / "ingest" / "__main__.py"
)
FIXTURES_DIR = REPO_ROOT / "contract" / "fixtures"

TEST_ENV = {
    "SPACES_KEY": "test-key",
    "SPACES_SECRET": "test-secret",
    # moto only intercepts AWS-shaped endpoints; a DO-specific endpoint_url
    # would fall through to a real network call. The app code never
    # branches on this value, so pointing it at AWS in tests exercises the
    # exact same put_object/ACL/ContentType path moto can observe.
    "SPACES_ENDPOINT": "https://s3.amazonaws.com",
    "SPACES_REGION": "us-east-1",
    "SPACES_BUCKET": "didiodidi-test",
    "PUBLIC_BASE_URL": "https://share.didiodidi.com",
}


@pytest.fixture
def ingest(monkeypatch):
    for key, value in TEST_ENV.items():
        monkeypatch.setenv(key, value)
    spec = importlib.util.spec_from_file_location(
        "didiodidi_ingest_main", INGEST_MAIN
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


@pytest.fixture
def spaces_bucket():
    with mock_aws():
        client = boto3.client("s3", region_name="us-east-1")
        client.create_bucket(Bucket=TEST_ENV["SPACES_BUCKET"])
        yield client


@pytest.fixture
def minimal_payload():
    return copy.deepcopy(
        json.loads((FIXTURES_DIR / "minimal.json").read_text())
    )


def fixture_paths():
    return sorted(FIXTURES_DIR.glob("*.json"))
