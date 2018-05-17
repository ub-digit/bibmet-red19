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
DBHOST=130.241.35.144                           # used in psql connection
BIBMET_DB=bibmet                                # used in psql connection 
DEPTID="${1}"
STARTYEAR="${2}"
ENDYEAR="${3}"
OUTDIRNAME="NorList"
OUTFILENAME="${DEPTID}.csv"
OUTFILEPATH="${OUTDIRNAME}/${OUTFILENAME}"
# -------------------------------------------------- #
mkdir -p "${OUTDIRNAME}"
declare -a yearList=($(seq  "${ENDYEAR}" -1 "${STARTYEAR}"))  # array
declare -A yearSum                              # associative array 
declare -A publication_types
echo "OUTFILEPATH:${OUTFILEPATH}"

# -------------------------------------------------- #
# get publication types                              #
# -------------------------------------------------- #
pubtypes=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < NorList_pt.sql)

while read -r row
do 
#  echo "A line of input: $row"
  dept_id="${row%¤*}"
  dept_label="${row#*¤}"
  #echo "id:$dept_id:label:$dept_label:"
#  echo "id:$dept_id:"
#  echo "label:$dept_label:"
  publication_types[$dept_id]="$dept_label"
#  echo " - - - "
#  echo "${ptsx[${ptsx[$pt]}"
#  echo " "
done <<<"$pubtypes"

### # -------------------------------------------------- #
### # retrieve sort order, see get_sortorder.sql
### # -------------------------------------------------- #
### sortIx=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID="${DEPTID}" "${BIBMET_DB}" < get_sortorder.sql)
### # -------------------------------------------------- #
### # split each row into elements in two arrays: pubTypeId and pubTypeLabel
### # -------------------------------------------------- #
### IFS=$'\n'
### c=1
### p=1
### for item in $sortIx
### do
###   myId=${item%¤$(echo ${item#*¤})}
###   if [[ $c -le ${numberOfPublicationtypes} ]]
###   then
###     pubTypeId[${c}]=${myId}
###     pubTypeLabel[${c}]=${item##*¤}
###     ((c++))
###   else
###     aggId[${p}]=${myId}
###     ((p++))
###   fi
### done
# -------------------------------------------------- #
# get data for this unit                             #
# -------------------------------------------------- #
data=$(psql -tAF"¤" -Upostgres -h "${DBHOST}" -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < NorList_data.sql)

# skapa upp en array med nollade värden
declare -A matrix
declare -A pts
for pt in 5 9 10
do
  for year in "${yearList[@]}"
  do
    for level in 0 1 2
    do
      #var_${!pt}_${!year)_${!level}="0"
      #echo "var_$${pt}_$${year}_$${$level}"
      #echo "var_$pt_$year_$level"
      matrix[$pt,$year,$level]="0"
      #matrix[$i,$j]=$RANDOM
    done
  done
done

#for x in 5 9 10
#do
#  for y in "${yearList[@]}"
#  do
#    for z in 0 1 2
#    do
#      echo ${matrix[$x,$y,$z]}
#    done
#  done
#done




# create header line (header and each of the years)
printf -v result "Document type/level, $(IFS=, ; echo "${yearList[*]}")\n"

#echo ${data}

#echo "File of $(date '+%x %X')" > tmpfil.txt

for pt in 5 9 10
do
#  echo "working on ${pt}"  >> tmpfil.txt
  for level in 0 1 2
  do
#    echo "  working on level ${level}" >> tmpfil.txt
    #row=$(grep "^${year}¤${pt}" <<< "$data")

    for year in "${yearList[@]}"
    do
      row=$(grep "^${year}¤${level}¤${pt}" <<< "$data")
#      echo "    working on ${year}"  >> tmpfil.txt
      #noOfPublications="$row"
      noOfPublications=${row##*¤}
      pt_label="${row#*¤*¤*¤}"
      pt_label="${pt_label%¤*}"
      if [ ! -z "$noOfPublications" ]; 
      then
        matrix[$pt,$year,$level]=$noOfPublications;
      fi
      if [ ! -z "$pt_label" ];
      then
        pts[$pt]=$pt_label
      fi
#      echo "    row:${row}:"                                    >> tmpfil.txt
#      echo "    pt_label:${pt_label}:"                          >> tmpfil.txt
#      echo "    number of publications:${noOfPublications}:"    >> tmpfil.txt
#      echo " "    >> tmpfil.txt
      #printf -v result "${result}${pt_label}\n"
      #printf -v result "${result}matrix[$pt,$year,$level]"

#      echo "$year;$level;$pt;$pt_label;$noOfPublications" >> tmpfil.txt
#      echo " "    >> tmpfil.txt
      

#      r_${pt}_${year}_${level}=${noOfPublications}
#      echo " - - - - - "
#      echo $r_${pt}_${year}_${level}
#      echo " - - - - - "

    done
#printf -v result "${result}\n"
###     pubTypeLabel[${c}]=${item##*¤}    
    #echo "    level:${level}"
    #echo "    noOfPublications:${noOfPublications}"
  done
  
done;

#echo "--------------"
#echo "${result}"
#echo "--------------"


#5;"Journal article"
#9;"Book"
#10;"Book chapter"
for pt in 5 9 10
do
  for year in "${yearList[@]}"
  do
    for level in 0 1 2
    do
      yearSum[$pt,$year]=$((${yearSum[$pt,$year]}+${matrix[$pt,$year,$level]}))
      #matrix[$pt,$year,$level]=$noOfPublications
      
    done
  done
done


#for pt in 5 9 10
#do
#  for year in "${yearList[@]}"
#  do
#    echo "yearSum[$pt,$year]:${yearSum[$pt,$year]}"
#  done
#done


for pt in 5 9 10
do
  
  for level in -1 0 1 2
  do

    if [ $level -eq "-1" ] 
      then
      #printf -v result "${result}${pts[$pt]}"
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
      
      #echo ${matrix[$x,$y,$z]}
      #printf -v result "${result},${matrix[$pt,$year,$level]}"
      
    done

    printf -v result "${result}\n"

  done
  
  #printf -v result "${result}\n"

done

#echo "result:"
#echo "$result"
#exit;

#for ((ptid=1;ptid<=numberOfPublicationtypes;ptid++))
#do
#  p=${pubTypeId[$ptid]}
#  result="${result}${pubTypeLabel[$ptid]}"
#  for year in  "${yearList[@]}"
#  do
#    row=$(grep "^${p}¤${year}" <<< "$data")
#    if [[ -z "$row" ]]
#    then
#      result="${result},0"
#    else
#      idYearVal=${row##*¤}
#      ((yearSum[${year}]+=${idYearVal}))
#      result="${result},${idYearVal}"
#    fi
#  done
#      printf -v result "${result}\n"
#done
## -------------------------------------------------- #
## 
#result="${result}Other"
#for year in  "${yearList[@]}"
#do
#  let summa=0
#  for aid in ${aggId[@]}
#  do
#    row=$(grep "^${aid}¤${year}" <<< "$data")
#    if [[ -z "$row" ]]
#    then
#      addend=0
#    else
#      addend=${row##*¤}
#    fi
#    summa=$((${summa} + ${addend}))
#  done
#  result="${result},${summa}"
#  ((yearSum[${year}]+=${summa}))
#done
#printf -v result "${result}\nTotal"
#for year in  "${yearList[@]}"
#do
#  result="${result},${yearSum[${year}]}"
#done
## -------------------------------------------------- #

echo "${result}" > $OUTFILEPATH




















