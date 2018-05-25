#!/bin/bash - 
# ============================================================================ #
#
#          FILE: norList.sh
# 
#         USAGE: ./norList.sh {numberOfPubTypes} {unitId} {startyear} {endyear}
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
    echo "# need three args:"
    echo "#   {unitId} {startyear} {endyear}"
    echo "# Example:"
    echo "#   ./norList.sh 1284 2013 2017"
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
OUTDIRNAME="norList"
OUTFILENAME="${DEPTID}.csv"
DEPTID="$(metaLookup ${DEPTID} )"
OUTFILEPATH="${OUTDIRNAME}/${OUTFILENAME}"
# -------------------------------------------------- #
mkdir -p "${OUTDIRNAME}"
declare -a yearList=($(seq  "${ENDYEAR}" -1 "${STARTYEAR}"))  # array
declare -A yearSum                              # associative array 
declare -A publication_types
echo "Processing ${OUTFILEPATH}"

# -------------------------------------------------- #
# get publication types                              #
# -------------------------------------------------- #
pubtypes=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < norList_pubtype.sql)

while read -r row
do 
#  echo "A line of input: $row"
  dept_id="${row%¤*}"
  dept_label="${row#*¤}"
  publication_types[$dept_id]="$dept_label"
done <<<"$pubtypes"

# -------------------------------------------------- #
# get data for this unit                             #
# -------------------------------------------------- #
data=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < norList_data.sql)

# skapa upp en array med nollade värden
declare -A matrix
declare -A pts
for pt in 5 9 10
do
  for year in "${yearList[@]}"
  do
    for level in 0 1 2
    do
      matrix[$pt,$year,$level]="0"
    done
  done
done

# create header line (header and each of the years)
printf -v result "Document type/level, $(IFS=, ; echo "${yearList[*]}")\n"

for pt in 5 9 10 22
do
  
  for level in 0 1 2
  do
    for year in "${yearList[@]}"
    do
      row=$(grep "^${year}¤${level}¤${pt}" <<< "$data")
      noOfPublications=${row##*¤}           # remove everything but last position (number of publications)
      pt_label="${row#*¤*¤*¤}"              # remove first three positions from row, remainer: label and number of publications
      pt_label="${pt_label%¤*}"             # remove everything but label
      if [ ! -z "$noOfPublications" ]; 
      then
        if [ "$pt" -eq "22" ] 
        then
          (( matrix["5",$year,$level]+=$noOfPublications ))
        else
         (( matrix[$pt,$year,$level]+=$noOfPublications ))
        fi
      fi
      if [ ! -z "$pt_label" ];
      then
        pts[$pt]=$pt_label
      fi
    done
  done
done;

for pt in 5 9 10
do
  for year in "${yearList[@]}"
  do
    for level in 0 1 2
    do
      yearSum[$pt,$year]=$((${yearSum[$pt,$year]}+${matrix[$pt,$year,$level]}))
    done
  done
done

for pt in 5 9 10
do
  
  #for level in -1 0 1 2
  for level in -1 1 2
  do

    if [ $level -eq "-1" ] 
      then
      printf -v result "${result}${publication_types[$pt]}"
    else
      printf -v result "${result}Level $level"
    fi

    for year in "${yearList[@]}"
    do

      if [ $level -eq "-1" ]
        then
        printf -v result "${result},${yearSum[$pt,$year]}"
      else
        printf -v result "${result},${matrix[$pt,$year,$level]}"
      fi
      
    done

    printf -v result "${result}\n"

  done

done

echo "${result}" > $OUTFILEPATH




















