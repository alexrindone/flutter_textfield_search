#!/bin/bash
# 1. Run tests and generate lcov.info
flutter test --coverage

# 2. Convert to JSON (your existing script)
bash test-coverage.sh

# 3. Add to git
git add coverage/
echo "Coverage updated locally. You are ready to commit/push!"