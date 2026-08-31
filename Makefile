.PHONY: help install test ui-test lint security coverage reports check clean

VENV_PYTHON=env/bin/python

help:
	@echo "Available commands:"
	@echo "  make install   Install project and test dependencies"
	@echo "  make test      Run backend tests with JUnit report"
	@echo "  make ui-test   Run Playwright UI tests"
	@echo "  make lint      Run Ruff linting"
	@echo "  make security  Run Bandit security scan"
	@echo "  make coverage  Run tests with XML and HTML coverage"
	@echo "  make reports   Run tests, coverage, lint, and security checks"
	@echo "  make check     Run the complete validation pipeline"
	@echo "  make clean     Remove generated reports and cache files"

install:
	$(VENV_PYTHON) -m pip install -r requirements.txt
	$(VENV_PYTHON) -m pip install pytest pytest-cov pytest-playwright ruff bandit
	$(VENV_PYTHON) -m playwright install chromium

test:
	mkdir -p reports
	APPNAME_ENV=test $(VENV_PYTHON) -m pytest tests/test_urls.py tests/test_config.py tests/test_login.py \
		--junitxml=reports/unit-test-results.xml

ui-test:
	mkdir -p reports
	APPNAME_ENV=test $(VENV_PYTHON) -m pytest tests/test_ui.py \
		--junitxml=reports/ui-test-results.xml

lint:
	mkdir -p reports
	$(VENV_PYTHON) -m ruff check appname tests --output-format=json > reports/ruff-report.json

security:
	mkdir -p reports
	$(VENV_PYTHON) -m bandit -r appname -f json -o reports/bandit-report.json

coverage:
	mkdir -p reports
	APPNAME_ENV=test $(VENV_PYTHON) -m pytest tests/test_urls.py tests/test_config.py tests/test_login.py \
		--cov=appname \
		--cov-report=term-missing \
		--cov-report=xml:reports/coverage.xml \
		--cov-report=html:reports/htmlcov \
		--junitxml=reports/coverage-test-results.xml

reports: test coverage lint security ui-test

check: reports

clean:
	rm -rf reports
	rm -rf .pytest_cache
	rm -rf htmlcov
	find . -type d -name "__pycache__" -prune -exec rm -rf {} +
	find . -type f \( -name "*.pyc" -o -name ".DS_Store" \) -delete
