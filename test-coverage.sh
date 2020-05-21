#!/bin/bash
echo "Writing Code Coverage Summary to COVERAGE.md";
echo "test" >> ./COVERAGE.md;
#lcov --summary coverage/lcov.info >> ./COVERAGE.md;
while IFS= read -r line; do
    echo "$line" >> ./COVERAGE.md;
done < <( lcov --summary coverage/lcov.info );
#echo "${MULTILINE}" > ./COVERAGE.md;
#echo "$MULTILINE";
echo "Test reading coverage file";
cat ./COVERAGE.md;
echo "Finished Writing to File";