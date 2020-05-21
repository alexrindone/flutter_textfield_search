#!/bin/bash
echo 'Writing Code Coverage Summary to COVERAGE.md';
lcov coverage/lcov.info -o ./COVERAGE.md;
printf "%s\n%s\n" "# COVERAGE" "$(cat ./COVERAGE.md)" >| ./COVERAGE.md;
cat ./COVERAGE.md;
echo 'Finished Writing to File';