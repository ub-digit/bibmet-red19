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
DBHOST=130.241.35.144                           # used in psql connection
BIBMET_DB=bibmet                                # used in psql connection 
DEPTID="${1}"
STARTYEAR="${2}"
ENDYEAR="${3}"
OUTDIRNAME="gender"
OUTFILENAME="${DEPTID}.csv"
OUTFILEPATH="${OUTDIRNAME}/${OUTFILENAME}"
# -------------------------------------------------- #
mkdir -p "${OUTDIRNAME}"
#declare -a yearList=($(seq  "${ENDYEAR}" -1 "${STARTYEAR}"))  # array
#declare -A yearSum  
declare -A category                            # associative array 
#echo "OUTFILEPATH:${OUTFILEPATH}"
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

#echo "genderTotal:$genderTotal:"
#echo "genderLevel2:$genderLevel2:"
#cho "genderSort:$genderSort:"
#echo "genderData:$genderData:"
printf -v result ",Women,,Men\nStaff category,publications,share of level 2,publications,share of level 2\n"

IFS=$'\n'

for gd in $genderData
do
  #nop=${gd##*¤}
  #gender=${gd%%¤*}
  #part_title=${gd%¤*}
  #title=${part_title#*¤}
  #echo "gd:${gd}:"
  nop=${gd##*¤}
  #echo "nop:${nop}:"

  rest=${gd%¤*}
  #echo "rest:${rest}:"

  gender=${rest##*¤}
  #echo "gender:${gender}:"
  
  title=${rest%¤*}
  #echo "title:${title}:"
  

#var="teCertificateId"
#var2="${var#te}"
#echo "${var2%Id}"

#  title=${title//Förekomst Saknas/Okänd}
  #title=${title//[åä]/a}
  #title=${title//ö/o}
  #title=${title// /blanksteg}
  #title=${title//,/komma}
  #echo "- nop:$nop:gender:$gender:title:$title:"
  category["${title}","${gender}"]=$nop

done

#x="Professor"
#y="M"
#echo "${category[${x},${y}]}"
#y="K"
#echo "${category[${x},${y}]}"

#matrix[$pt,$year,$level]="0"
for gs in $genderSort
do
#echo $gs
  title=${gs%¤*}
  #echo "title:${title}:"
  m=${category[${title},"M"]}
  #echo "m:${m}:"
  if [ -z "$m" ]; then
    m="0"
  fi
  #echo "m:${m}:"
  k=${category[${title},"K"]}
  #echo "k:${k}:"
  if [ -z "$k" ]; then
    k="0"
  fi
  #echo "k:${k}:"
  #echo "$title"
  mp=$(( 100*${m}/(${m}+${k}) ))
  kp=$(( 100*${k}/(${m}+${k}) ))
  echo "title:${title}:m:${m}:k:${k}:mp:${mp}:kp:${kp}:"
  #result="${result},${percent}%"
  result="${result}${title},${k},${kp}%,${m},${mp}%
"
  echo "${result}"
  echo " "
  #echo ${category[${title},"M"]}
  #echo ${category[${title},"K"]}
  #echo "m:${m}:"
  #echo "k:${k}:"
  #echo " "
done

#echo ${result} > testfil.csv
echo "${result}" > $OUTFILEPATH

exit
# -------------------------------------------------- #
# get data for this unit                             #
# -------------------------------------------------- #
data=$(psql -tAF"¤" -Upostgres -h "${DBHOST}"  -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < dType_data.sql)
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




















