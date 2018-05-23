#!/bin/bash - 
# ============================================================================ #
#
#          FILE: gender.sh
# 
#         USAGE: ./gender.sh {numberOfPubTypes} {unitId} {startyear} {endyear}
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
    echo "#    {unitId} {startyear} {endyear}"
    echo "# Example:"
    echo "#   ./gender.sh 1284 2012 2015"
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
OUTDIRNAME="gender"
OUTFILENAME="${DEPTID}.csv"
DEPTID="$(metaLookup ${DEPTID} )"
OUTFILEPATH="${OUTDIRNAME}/${OUTFILENAME}"
# -------------------------------------------------- #
mkdir -p "${OUTDIRNAME}"
declare -A category                            # associative array 
echo "Processing ${OUTFILEPATH}"
# -------------------------------------------------- #
# retrieve sort order, see get_sortorder.sql
# -------------------------------------------------- #
genderTotal=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < gender_total.sql)
genderLevel2=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < gender_level2.sql)
genderSort=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < gender_sort.sql)
genderData=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < gender_data.sql)
# -------------------------------------------------- #
# split each row into elements in two arrays: pubTypeId and pubTypeLabel
# -------------------------------------------------- #

printf -v result ",Women,,Men\nStaff category,publications,share of level 2,publications,share of level 2\n"

IFS=$'\n'

for gd in $genderData
do
  nop=${gd##*¤}
  rest=${gd%¤*}
  gender=${rest##*¤}
  title=${rest%¤*}
  category["${title}","${gender}"]=$nop
done

let mtot=0
let ktot=0
for gs in $genderSort
do
  title=${gs%¤*}
  m=${category[${title},"M"]}
  if [ -z "$m" ]; then
    m="0"
  fi
  mtot=$(( $mtot + $m ))

  k=${category[${title},"K"]}
  if [ -z "$k" ]; then
    k="0"
  fi
  ktot=$(( $ktot + $k ))
done;

for gs in $genderSort
do
  title=${gs%¤*}
  m=${category[${title},"M"]}
  if [ -z "$m" ]; then
    m="0"
  fi
  k=${category[${title},"K"]}
  if [ -z "$k" ]; then
    k="0"
  fi
  if [ $mtot != 0 ]; then
    mp=$(( 100*${m}/(${mtot}) ))
  else
    mp=0
  fi
  if [ $ktot != 0 ]; then
    kp=$(( 100*${k}/(${ktot}) ))
  else
    kp=0
  fi

  result="${result}${title},${k},${kp}%,${m},${mp}%
"
done

echo "${result}" > $OUTFILEPATH

