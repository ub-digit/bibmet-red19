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
  if [[ "$#" -ne 4 ]]; 
  then 
    echo "# -------------------------------------------------- #"
    echo "# need four args:"
    echo "#    {unitId} {startyear} {endyear}"
    echo "# Example:"
    echo "#   ./gender.sh 1284 2012 2015 na"
    echo "#   or"
    echo "#   ./gender.sh 1284 2012 2015 hu"
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
VARIANT="${4}"

OUTDIRNAME="gender"
OUTFILENAME="${DEPTID}.csv"
DEPTID="$(metaLookup ${DEPTID} )"
OUTFILEPATH="${OUTDIRNAME}/${OUTFILENAME}"
# -------------------------------------------------- #
mkdir -p "${OUTDIRNAME}"
declare -A category                            # associative array 
declare -A categoryTotal                       # associative array 
echo "Processing ${OUTFILEPATH}"
# -------------------------------------------------- #
# retrieve sort order, see get_sortorder.sql
# -------------------------------------------------- #
#genderTotal=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < gender_total.sql)
#genderLevel2=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < gender_level2.sql)
titleSort=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < "title_sort_${VARIANT}.sql")
genderData=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < "gender_data_${VARIANT}.sql")
genderDataTotal=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < "gender_data_total_${VARIANT}.sql")
# -------------------------------------------------- #
# split each row into elements in two arrays: pubTypeId and pubTypeLabel
# -------------------------------------------------- #

if [ "${VARIANT}" = "hu" ]; then
  printf -v result ",Women,,,Men\nStaff category,P,PNor,%%Level 2,P,PNor,%%Level 2\n"
else
  printf -v result ",Women,,,Men\nStaff category,P,PWos,Top 10%%,P,PWos,Top 10%%\n"
fi

echo $genderData >> gender/"${DEPTID}".txt

IFS=$'\n'

for gd in $genderData
do
  nop=${gd##*¤}
  rest=${gd%¤*}
  gender=${rest##*¤}
  title=${rest%¤*}
  category["${title}","${gender}"]=$nop
done

for gdt in $genderDataTotal
do
  nop=${gdt##*¤}
  rest=${gdt%¤*}
  gender=${rest##*¤}
  title=${rest%¤*}
  categoryTotal["${title}","${gender}"]=$nop
done

let mtot=0
let ktot=0
for gs in $titleSort
do
  title=${gs%¤*}
  m=${category[${title},"M"]}
  #mt=${categoryTotal[${title},"M"]}
  if [ -z "$m" ]; then
    m="0"
  fi
  mtot=$(( $mtot + $m ))

  k=${category[${title},"K"]}
  #kt=${categoryTitle[${title},"K"]}
  if [ -z "$k" ]; then
    k="0"
  fi
  ktot=$(( $ktot + $k ))
done;

for gs in $titleSort
do
  title=${gs%¤*}
  m=${category[${title},"M"]}
  if [ -z "$m" ]; then
    m="0"
  fi
  mt=${categoryTotal[${title},"M"]}
  if [ -z "$mt" ]; then
    mt="0"
  fi
  k=${category[${title},"K"]}
  if [ -z "$k" ]; then
    k="0"
  fi
  kt=${categoryTotal[${title},"K"]}
  if [ -z "$kt" ]; then
    kt="0"
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

  result="${result}${title},${kt},${k},${kp}%,${mt},${m},${mp}%
"
done

echo "${result}" > $OUTFILEPATH

