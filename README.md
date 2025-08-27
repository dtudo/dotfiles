# dotfiles

Dotfiles project containing shared configuration files and executables for consistent setup. Made for Ubuntu and zsh.

## Prerequisites

- git
- antidote
- batcat
- mise
- aws cli

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/dtudo/dotfiles/main/install.sh | bash
```

## Contributing Guidelines

The following sections describe the standards for making changes to this repository.

### Development Setup

Set up `just` for standardized development workflows.

```bash
sudo apt update
sudo apt install just
```

Run `just install` to install the required dependencies.

### Commit Standards

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

```markdown
<type>: <description>
```

Examples:

```markdown
docs: add development requirements
fix: correct install symlinks
refactor: simplify async handling
```

## Before Committing Your Changes

Run `just verify` in the root of the repository. This target runs all the required checks.
