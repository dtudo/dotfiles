set quiet

install:
  mise install

lint:
	./scripts/lint-sh.sh

format:
	shfmt -w .

format-check:
	shfmt -d .

verify: lint format-check
