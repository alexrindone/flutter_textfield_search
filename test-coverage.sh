#!/bin/bash
echo 'Writing Code Coverage Summary to COVERAGE.md';
lcov --summary coverage/lcov.info > ./COVERAGE.md;
printf '%s\n%s\n' "# COVERAGE" "$(cat ./COVERAGE.md)" >| ./COVERAGE.md;
echo 'Finished Writing to File';