#!/bin/bash - 
# ============================================================================ #
#
#          FILE: extAuth.sh
# 
#         USAGE: ./extAuth.sh {unitId} {startyear} {endyear}
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
    echo "#   {unitId} {startyear} {endyear}"
    echo "# Example:"
    echo "#   ./extAuth.sh 1284 2013 2017"
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
OUTDIRNAME="extAuth"
OUTFILENAME="${DEPTID}.csv"
DEPTID="$(metaLookup ${DEPTID} )"
OUTFILEPATH="${OUTDIRNAME}/${OUTFILENAME}"
# -------------------------------------------------- #
mkdir -p "${OUTDIRNAME}"
declare -a yearList=($(seq  "${ENDYEAR}" -1 "${STARTYEAR}"))  # array
declare -A pYear pPubs cYear cPubs
echo "Processing ${OUTFILEPATH}"
# -------------------------------------------------- #
# retrieve the data
# -------------------------------------------------- #
publications=$(psql -tAF"¤" -Upostgres -h "${DBHOST}"  -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < extAuth_publications.sql)
coops=$(psql -tAF"¤" -Upostgres -h "${DBHOST}"  -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < extAuth_externals.sql)

IFS=$'\n'
for p in $publications
do
  pYear="${p%¤*}"
  pPubs="${p#*¤}"
  pubs[$pYear]=$pPubs
done

for c in $coops
do
  cYear="${c%¤*}"
  cPubs="${c#*¤}"
  coops[$cYear]=$cPubs
done

printf -v result "Share of co-authored publications, $(IFS=, ; echo "${yearList[*]}")\nco-authored publications"

for year in "${yearList[@]}"
do
  pYear=${pubs[$year]}
  cYear=${coops[$year]}
  if [[ $pYear -eq "0" ]]; then
    percent="0"
  else
    percent=$(( 100*cYear/pYear ))
  fi
  
  result="${result},${percent}%"

done

echo "${result}" > $OUTFILEPATH
