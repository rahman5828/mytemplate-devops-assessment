import threading
import time

import pytest
from playwright.sync_api import expect

from appname import create_app


@pytest.fixture(scope="module")
def flask_server():
    app = create_app("appname.settings.TestConfig")

    server = threading.Thread(
        target=lambda: app.run(
            host="127.0.0.1",
            port=5001,
            debug=False,
            use_reloader=False,
        )
    )
    server.daemon = True
    server.start()

    time.sleep(2)

    yield "http://127.0.0.1:5001"


def test_beta_page_shows_mytemplate(page, flask_server):
    page.goto(f"{flask_server}/beta")

    expect(page.locator("body")).to_contain_text("Welcome to MyTemplate")
