# Security Policy

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

**Please do NOT open a public issue for security vulnerabilities.**

If you discover a security vulnerability in wasm-num, please report it responsibly:

### Preferred: GitHub Private Vulnerability Reporting

1. Navigate to the [Security Advisories](https://github.com/Provenance-Works/wasm-num/security/advisories) page.
2. Click **"Report a vulnerability"**.
3. Fill in the details and submit.

### Alternative: Direct Contact

Contact the maintainer directly via GitHub: [@Aqua-218](https://github.com/Aqua-218)

### What to Include

- Description of the vulnerability
- Steps to reproduce (Lean code snippet, specific module, etc.)
- Impact assessment (what could go wrong if exploited)
- Suggested fix (if any)

### What to Expect

- **Acknowledgment** within 48 hours of your report.
- **Assessment** of severity and impact within 1 week.
- **Fix or mitigation** as soon as practical, depending on complexity.
- **Credit** in the security advisory and CHANGELOG (unless you prefer anonymity).

### Scope

Since wasm-num is a formal verification library (not a runtime or service), security vulnerabilities primarily include:

- **Unsound proofs** — A `theorem` that can be used to prove `False`, or relies on unintended axioms.
- **Incorrect definitions** — A definition that does not match the WebAssembly specification, which could lead to incorrect reasoning in downstream projects.
- **Supply chain issues** — Compromised dependencies, malicious commits, or CI/CD pipeline vulnerabilities.
- **Secret leakage** — Accidental inclusion of credentials or private data in the repository.

### Disclosure Policy

We follow coordinated disclosure:

1. Reporter contacts us privately.
2. We confirm the vulnerability and develop a fix.
3. We release the fix and publish a security advisory.
4. The reporter is credited (with their consent).

We aim to resolve critical issues before public disclosure. We will not take legal action against security researchers who follow this responsible disclosure process.

## Security Practices

- **CI/CD Pipeline**: All PRs are verified by a formal verification pipeline that checks for `sorry`, axiom usage, and proof completeness.
- **Dependency Scanning**: Dependabot monitors GitHub Actions dependencies for known vulnerabilities.
- **Secret Scanning**: Weekly automated scans of the repository and git history for leaked credentials.
- **Code Review**: All changes to `main` require review from a code owner.
