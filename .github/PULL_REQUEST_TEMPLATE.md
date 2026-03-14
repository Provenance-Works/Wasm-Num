## Description

<!-- Briefly describe the changes in this PR. -->

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature / definition (non-breaking change which adds functionality)
- [ ] New proof or theorem
- [ ] Breaking change (fix or feature that would cause existing code to not work as expected)
- [ ] Documentation update
- [ ] Test addition / improvement
- [ ] Refactoring (no functional changes)
- [ ] CI/CD changes

## Wasm Spec Reference

<!-- Link to the relevant WebAssembly specification section, if applicable. -->

## Checklist

- [ ] My code follows the project's style guide (snake_case defs, CamelCase types, `autoImplicit = false`)
- [ ] I have performed a self-review of my code
- [ ] I have added/updated doc comments for public definitions
- [ ] Definitions and proofs are properly separated ([ADR-006](docs/en/design/adr/0006-proof-separation.md))
- [ ] There are no `sorry` in definitions or proofs (excluding marked stubs)
- [ ] `lake build` succeeds with no errors
- [ ] I have added `#eval` tests for new definitions (if deterministic)
- [ ] I have added proof modules for new definitions (if applicable)
- [ ] I have updated the CHANGELOG.md (if applicable)

## Related Issues

<!-- Link related issues: "Closes #123", "Fixes #456", "Relates to #789" -->
