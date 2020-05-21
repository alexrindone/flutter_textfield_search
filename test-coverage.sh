#!/bin/bash
echo "Writing Code Coverage Summary to COVERAGE.md";
npm install lcov-parse
node ./node_modules/lcov-parse/bin/cli.js ./coverage/lcov.info > test-coverage.json
echo "Finished Writing to File";