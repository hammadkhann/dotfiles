---
description: Review recently written/modified code with fresh eyes for bugs and issues
allowed-tools: Read, Grep, Glob, LS, ReadLints
---

Carefully read over all of the new code you just wrote and other existing code you just modified with "fresh eyes" looking super carefully for any obvious bugs, errors, problems, issues, confusion, etc.

Your review should include:

1. **Logic Errors**: Off-by-one errors, incorrect conditions, race conditions, null/undefined handling
2. **Type Issues**: Type mismatches, missing type annotations, incorrect type coercion
3. **API Misuse**: Incorrect function signatures, missing required parameters, wrong return types
4. **Resource Leaks**: Unclosed files/connections, missing cleanup, memory leaks
5. **Error Handling**: Missing try/catch, swallowed exceptions, incorrect error propagation
6. **Edge Cases**: Empty inputs, boundary conditions, unexpected data types
7. **Code Consistency**: Naming inconsistencies, style violations, dead code
8. **Security Concerns**: Input validation, injection vulnerabilities, sensitive data exposure

For each issue found:
- Identify the file and location
- Explain what the problem is
- Implement the fix

Carefully fix anything you uncover. Do not just list issues - actually implement the fixes.
