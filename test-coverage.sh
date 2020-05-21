#!/bin/bash
echo "Writing Code Coverage Summary to COVERAGE.md";
MULTILINE=$(lcov --summary coverage/lcov.info);
echo "${MULTILINE}" > ./COVERAGE.md;
echo "Test reading coverage file";
cat ./COVERAGE.md;
echo "Finished Writing to File";