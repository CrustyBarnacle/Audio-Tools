# Development Tests

Smoke tests for Audio-Tools scripts.

## Running Tests

```bash
./tests/smoke_test.sh
```

## Branch Workflow

The `dev` branch contains development tests that should not be merged to `main`.

**Keeping dev up to date:**
```bash
git checkout dev
git pull origin main
./tests/smoke_test.sh  # Verify tests still pass
```

**Adding new tests:**
1. Checkout `dev` branch
2. Pull latest from `main`
3. Add/modify tests
4. Run tests to verify
5. Commit to `dev`

The `dev` branch should **not** be merged back to `main` - production scripts remain test-free.
