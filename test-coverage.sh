#!/bin/bash
echo 'Writing Code Coverage Summary to COVERAGE.md';
lcov --summary coverage/lcov.info | tee ./COVERAGE.md;
ls -la
#printf '%s\n%s\n' "# COVERAGE" "$(cat ./COVERAGE.md)" >| ./COVERAGE.md;
cat ./COVERAGE.md;
echo 'Finished Writing to File';