#!/bin/bash - 
# ============================================================================ #
#
#          FILE: dType.sh
# 
#         USAGE: ./dType.sh {numberOfPubTypes} {unitId} {startyear} {endyear}
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
    echo "\$0:${0}:"
    echo "\$1:${1}:"
    echo "\$2:${2}:"
    echo "\$3:${3}:"
    echo "\$4:${4}:"
    echo "\$5:${5}:"
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
numberOfPublicationtypes="${1}"                 # explicit results for the first 10 publication types, rest will be aggregated
DEPTID="${2}"
#echo "DEPTID:$DEPTID:"
STARTYEAR="${3}"
ENDYEAR="${4}"
OUTDIRNAME="dType"
OUTFILENAME="${DEPTID}.csv"
#echo "DEPTID:${DEPTID}:"
DEPTID="$(metaLookup ${DEPTID} )"
#echo "DEPTID:${DEPTID}:"
OUTFILEPATH="${OUTDIRNAME}/${OUTFILENAME}"
# -------------------------------------------------- #
mkdir -p "${OUTDIRNAME}"
declare -a yearList=($(seq  "${ENDYEAR}" -1 "${STARTYEAR}"))  # array
declare -A yearSum                              # associative array 
echo "Processing ${OUTFILEPATH}"
# -------------------------------------------------- #
# retrieve sort order, see get_sortorder.sql
# -------------------------------------------------- #
sortIx=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < dType_order_neuro2.sql)
# -------------------------------------------------- #
# split each row into elements in two arrays: pubTypeId and pubTypeLabel
# -------------------------------------------------- #
IFS=$'\n'
c=1
p=1
for item in $sortIx
do
  myId=${item%¤$(echo ${item#*¤})}
  if [[ $c -le ${numberOfPublicationtypes} ]]
  then
    pubTypeId[${c}]=${myId}
    pubTypeLabel[${c}]=${item##*¤}
    ((c++))
  else
    aggId[${p}]=${myId}
    ((p++))
  fi
done
# -------------------------------------------------- #
# get data for this unit                             #
# -------------------------------------------------- #
data=$(psql -tAF"¤" -Upostgres -h "${DBHOST}"  -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < dType_data_neuro2.sql)
# create header line (header and each of the years)
printf -v result "Document type, $(IFS=, ; echo "${yearList[*]}")\n"
for ((ptid=1;ptid<=numberOfPublicationtypes;ptid++))
do
  p=${pubTypeId[$ptid]}
  result="${result}${pubTypeLabel[$ptid]}"
  for year in  "${yearList[@]}"
  do
    row=$(grep "^${p}¤${year}" <<< "$data")
    if [[ -z "$row" ]]
    then
      result="${result},0"
    else
      idYearVal=${row##*¤}
      ((yearSum[${year}]+=${idYearVal}))
      result="${result},${idYearVal}"
    fi
  done
      printf -v result "${result}\n"
done
# -------------------------------------------------- #
# 
result="${result}Other"
for year in  "${yearList[@]}"
do
  let summa=0
  for aid in ${aggId[@]}
  do
    row=$(grep "^${aid}¤${year}" <<< "$data")
    if [[ -z "$row" ]]
    then
      addend=0
    else
      addend=${row##*¤}
    fi
    summa=$((${summa} + ${addend}))
  done
  result="${result},${summa}"
  ((yearSum[${year}]+=${summa}))
done
printf -v result "${result}\nTotal"
for year in  "${yearList[@]}"
do
  result="${result},${yearSum[${year}]}"
done
# -------------------------------------------------- #

echo "${result}" > $OUTFILEPATH




















