
## Local Setup

Usage of Python 3 is required.

```bash
# Create and activate a virtual environment
python3 -m venv env
source env/bin/activate

# Install application and test dependencies
make install
```

`make install` installs the dependencies from `requirements.txt`, adds `pytest`, `pytest-cov`, `pytest-playwright`, `ruff`, and `bandit`, and installs the Playwright Chromium browser.

To run the application locally:

```bash
# Optional: configure local secrets (OAuth, Stripe) — see .env.local.sample
cp .env.local.sample .env.local
source .env.local

FLASK_APP=manage flask --debug run
```

## Running Tests

Backend tests:

```bash
APPNAME_ENV=test env/bin/python -m pytest tests/test_urls.py tests/test_config.py tests/test_login.py
```

UI tests (Playwright):

```bash
APPNAME_ENV=test env/bin/python -m pytest tests/test_ui.py
```

## Validation Pipeline

The `Makefile` defines the validation pipeline:

- `make lint` — runs Ruff against `appname` and `tests`, and writes the JSON report to `reports/ruff-report.json`.
- `make test` — runs the backend test suite and writes a JUnit XML report to `reports/unit-test-results.xml`.
- `make ui-test` — runs the Playwright UI test and writes a JUnit XML report to `reports/ui-test-results.xml`.
- `make security` — runs Bandit against `appname` and writes the JSON report to `reports/bandit-report.json`.
- `make coverage` — runs the backend test suite with coverage, producing XML, HTML, and JUnit reports.
- `make reports` — runs `test`, `coverage`, `lint`, `security`, and `ui-test` together.
- `make check` — runs the full validation pipeline (equivalent to `make reports`).
- `make clean` — removes generated reports and cache/build artifacts.

## Reports

All reports are written to the `reports/` directory:

| File                                  | Description                                   |
| -------------------------------------- | ---------------------------------------------- |
| `reports/unit-test-results.xml`        | JUnit XML results for the backend test suite   |
| `reports/coverage-test-results.xml`    | JUnit XML results from the coverage test run   |
| `reports/coverage.xml`                 | Coverage report in Cobertura XML format         |
| `reports/htmlcov/`                     | Browsable HTML coverage report                 |
| `reports/ruff-report.json`             | Ruff lint results in JSON format                |
| `reports/bandit-report.json`           | Bandit security scan results in JSON format     |
| `reports/ui-test-results.xml`          | JUnit XML results for the Playwright UI test    |

## Current Validation Status

| Check          | Result       |
| -------------- | ------------ |
| Ruff            | PASS         |
| Backend tests   | 12 passed    |
| UI tests        | 1 passed     |
| Coverage        | ~52%         |
| Bandit          | Completed, JSON report generated |
| Reports         | Generated successfully under `reports/` |

## GitHub Actions

The workflow at `.github/workflows/flask-pytest.yml` (`MyTemplate CI`) runs on every push and pull request. It installs dependencies, installs the Playwright Chromium browser, and runs Ruff, the backend test suite, the UI test, Bandit, and the coverage run — writing all reports to `reports/` and uploading them as build artifacts. The same checks can be reproduced locally using the Makefile commands above (`make check`), without needing to trigger GitHub Actions remotely.

## Notes / Warnings

Current test runs may print dependency/deprecation warnings originating from third-party packages (e.g. `requests`/`urllib3` compatibility, `pkg_resources`, Flask-Caching, Flask-Limiter, Flask-Admin, `EncryptedType`, Flask Debug Toolbar). These are warnings from existing dependencies, not application test failures — all listed tests currently pass. Coverage is currently approximately 52%, not 100%, and there are no claims of a warning-free run or of AWS deployment support in this repository.