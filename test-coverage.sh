#!/bin/bash
echo "Writing Code Coverage Summary to coverage.json file";
line_details="";
# loop through each line in lcov.info file
while read -r line; do
  # all parts, split line into array based on colon
  IFS=: read -ra allparts <<< "$line"
  # case statement using first part of each line in file
    case ${allparts[0]} in
       "SF")
       # this sets the file we are covering
            FILE_NAME="${allparts[1]}"
       ;;
       "LF")
       # this sets the lines that were found
            lines_found="${allparts[1]}"
       ;;
       "LH")
       # this sets the lines that were hit
            lines_hit="${allparts[1]}"
       ;;
       "DA")
       # split the line on a comma
           IFS=',' read -r lined lineh <<< "${allparts[1]}"
           all_details='{"line":"'${lined}'","hit":"'${lineh}'"}'
           line_details+="${all_details}",
       ;;
       *)
       # default output
       # echo "Sorry, no line found.";;
    esac
done <./coverage/lcov.info
# set line summary which is lines hit divided by lines found, then get
# percentage by multiplying by 100
line_summary=$(echo "scale=2;$lines_hit/$lines_found*100" | bc);
# remove the last comma from the array of line details
line_details=${line_details%,};
# create a json string from all variables
JSON_STRING='{"file":"'$FILE_NAME'","lines":{"coverage_summary":"'$line_summary'% ('$lines_hit' of '$lines_found' lines)","found":"'$lines_found'","hit":"'$lines_hit'","details":['$line_details']}}';
# output content to json fine
echo "${JSON_STRING}" > ./coverage/coverage.json;
echo "Finished Writing to File";
