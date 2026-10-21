from app.app import app


def test_health_endpoint():
    response = app.test_client().get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_ready_endpoint():
    response = app.test_client().get("/ready")
    assert response.status_code == 200
    assert response.get_json() == {"ready": True}


def test_version_endpoint(monkeypatch):
    monkeypatch.setenv("APP_VERSION", "abc123")
    response = app.test_client().get("/version")
    assert response.status_code == 200
    assert response.get_json() == {"version": "abc123"}
