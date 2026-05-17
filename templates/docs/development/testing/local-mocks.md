# Local Mocks

↑ [docs/development/testing/](./strategy.md)
↔ related: [strategy.md](./strategy.md)

---

## SQS — moto

For unit and functional tests of the dispatcher (`app/worker/`), SQS calls are mocked in-process using **moto**.

No server required. moto intercepts boto3 calls and simulates AWS responses in memory.

### Install

Already in `app/worker/pyproject.toml` dev dependencies:

```toml
[tool.uv.dev-dependencies]
moto = { version = ">=5.0", extras = ["sqs"] }
boto3 = ">=1.38"
pytest = ">=8.0"
```

### Usage pattern

```python
import boto3
from moto import mock_aws
from main import handler

@mock_aws
def test_handler_accepts_sqs_event():
    # moto intercepts all boto3 SQS calls within this scope
    sqs = boto3.client("sqs", region_name="us-east-1")
    queue = sqs.create_queue(QueueName="test-queue")

    event = {
        "Records": [{
            "body": '{"app_name": "Duolingo"}',
            "receiptHandle": "test-handle",
        }]
    }
    result = handler(event, None)
    assert result["statusCode"] == 200
```

### Why moto over LocalStack

| | moto | LocalStack |
|---|---|---|
| Setup | Zero — in-process | Docker required |
| Speed | Fast (no network) | Slower |
| CI | No extra config | Requires docker-in-docker or socket mount |
| Coverage | SQS, S3, DynamoDB, etc. | Full AWS surface |

Use moto for unit + functional tests. Use LocalStack only if you need to test the actual SQS message visibility timeout loop or queue consumer behavior end-to-end.

---

## FastAPI — TestClient

API functional tests use FastAPI's built-in `TestClient` (wraps httpx, no server needed):

```python
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
```

No mock needed — TestClient runs the app in-process.
