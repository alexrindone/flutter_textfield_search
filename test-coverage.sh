#!/bin/bash
echo "Writing Code Coverage Summary to COVERAGE.md";
npm install lcov-parse
node lcov-parse ./coverage/lcov.info > test-coverage.json
echo "Finished Writing to File";