#!/bin/bash - 
# ============================================================================ #
# HAR INTE GJORT NÅGOT MED DENNA ÄN
#          FILE: oa.sh
# 
#         USAGE: ./oa.sh {numberOfPubTypes} {unitId} {startyear} {endyear}
# 
#   DESCRIPTION: delivers csv formatted statistics on number of publications/year
#                for unit with {unitId} within the year span {startyear} - {endyear},
#                sorted by overall sum for publication type for all years.          
#                The first {numberOfPubTypes} publication types are separately accounted
#                for, the rest are summarized.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Torgny Rasmark (TR), Torgny.Rasmark@gmail.com
#  ORGANIZATION: lifeLAB
#       CREATED: 2018-04-17 14:27
#      REVISION:  ---
# ============================================================================ #
function argCheck(){
  if [[ "$#" -ne 3 ]]; 
  then 
    echo "# -------------------------------------------------- #"
    echo "# need four args:"
    echo "#   {numberOfPubTypes} {unitId} {startyear} {endyear}"
    echo "# Example:"
    echo "#   ./getDataForUnit.sh 5 1284 2012 2015"
    echo "# -------------------------------------------------- #"
    exit;
  fi
}
argCheck "${@}"
. metaLookup.sh
DBHOST=130.241.35.144                           # used in psql connection
BIBMET_DB=bibmet                                # used in psql connection 
DEPTID="${1}"
STARTYEAR="${2}"
ENDYEAR="${3}"
OUTDIRNAME="oa"
OUTFILENAME="${DEPTID}.csv"
DEPTID="$(metaLookup ${DEPTID} )"
OUTFILEPATH="${OUTDIRNAME}/${OUTFILENAME}"
# -------------------------------------------------- #
mkdir -p "${OUTDIRNAME}"
declare -a yearList=($(seq  "${ENDYEAR}" -1 "${STARTYEAR}"))  # array
declare -A yearSum                              # associative array 
echo "Processing ${OUTFILEPATH}"
# -------------------------------------------------- #
# get data for this unit                             #
# -------------------------------------------------- #
data=$(psql -tAF"¤" -Upostgres -h "${DBHOST}"  -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < matte_oa.sql)
# create header line (header and each of the years)
printf -v result "Document type, $(IFS=, ; echo "${yearList[*]}")\n"
printf -v result "${result}Journal articles"

# Läs in data till en array
IFS=$'\n'
for d in $data
do
  year=${d%%¤*}
  pubs=${d##*¤}
  yearSum[$year]=$pubs
done

for year in  "${yearList[@]}"
do
  if [ -z "${yearSum[${year}]}" ]; then
    pubs=0
  else
    pubs=${yearSum[${year}]}
  fi
  printf -v result "${result},${pubs}"
done
echo "${result}" > $OUTFILEPATH
