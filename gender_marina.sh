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
declare -A categoryLevel2                      # associative array 
echo "Processing ${OUTFILEPATH}"
# -------------------------------------------------- #
# retrieve sort order, see get_sortorder.sql
# -------------------------------------------------- #
#genderTotal=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < gender_total.sql)
#genderLevel2=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < gender_level2.sql)
titleSort=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < "special_title_sort_${VARIANT}.sql")
genderData=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < "special_gender_data_${VARIANT}.sql")
genderDataLevel2=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < "special_gender_data_level2_${VARIANT}.sql")
genderDataTotal=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < "special_gender_data_total_${VARIANT}.sql")
# -------------------------------------------------- #
# split each row into elements in two arrays: pubTypeId and pubTypeLabel
# -------------------------------------------------- #

if [ "${VARIANT}" = "hu" ]; then
  printf -v result ",Women,,,Men\nStaff category,P,PNor,Level 2,P,PNor,Level 2\n"
else
  printf -v result ",Women,,,Men\nStaff category,P,PWos,Top 10%%,P,PWos,Top 10%%\n"
fi

#echo "Gender Data\n${genderData}\n\n"              > gender/"${DEPTID}_data".txt
#echo "Gender Total\n${genderDataTotal}\n"         >> gender/"${DEPTID}_data".txt
#echo "Gender Level2\n${genderDataLevel2}\n\n\n\n" >> gender/"${DEPTID}_data".txt

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

for gdl in $genderDataLevel2
do
  nop=${gdl##*¤}
  rest=${gdl%¤*}
  gender=${rest##*¤}
  title=${rest%¤*}
  categoryLevel2["${title}","${gender}"]=$nop
done

for gs in $titleSort
do
  title=${gs%¤*}
  mt=${categoryTotal[${title},"M"]}
  if [ -z "$mt" ]; then
    mt="0"
  fi
  md=${category[${title},"M"]}
  if [ -z "$md" ]; then
    md="0"
  fi
  ml=${categoryLevel2[${title},"M"]}
  if [ -z "$ml" ]; then
    ml="0"
  fi
  kt=${categoryTotal[${title},"K"]}
  if [ -z "$kt" ]; then
    kt="0"
  fi
  kd=${category[${title},"K"]}
  if [ -z "$kd" ]; then
    kd="0"
  fi
  kl=${categoryLevel2[${title},"K"]}
  if [ -z "$kl" ]; then
    kl="0"
  fi

  result="${result}${title},${kt},${kd},${kl},${mt},${md},${ml}
"
done

echo "${result}" > $OUTFILEPATH

