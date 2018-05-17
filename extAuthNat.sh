#!/bin/bash - 
# ============================================================================ #
#
#          FILE: extAuthNat.sh
# 
#         USAGE: ./extAuthNat.sh {unitId} {startyear} {endyear}
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
DBHOST=130.241.35.144                           # used in psql connection
BIBMET_DB=bibmet                                # used in psql connection 
DEPTID="${1}"
STARTYEAR="${2}"
ENDYEAR="${3}"
OUTDIRNAME="extAuth"
OUTFILENAME="${DEPTID}.csv"
OUTFILEPATH="${OUTDIRNAME}/${OUTFILENAME}"
# -------------------------------------------------- #
mkdir -p "${OUTDIRNAME}"
declare -a yearList=($(seq  "${ENDYEAR}" -1 "${STARTYEAR}"))  # array
#declare -A pYear pPubs cYear cPubs
declare -A totalList coopList intList
declare -A totarray cooparray intarray
echo "OUTFILEPATH:${OUTFILEPATH}"
# -------------------------------------------------- #
# retrieve the data
# -------------------------------------------------- #
total=$(psql -tAF"¤" -Upostgres -h "${DBHOST}"  -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < extAuthNatTotal.sql)
cooptot=$(psql -tAF"¤" -Upostgres -h "${DBHOST}"  -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < extAuthNatCoop.sql)
coopint=$(psql -tAF"¤" -Upostgres -h "${DBHOST}"  -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < extAuthNatIntCoop.sql)


newline="
"
yearstring=$(IFS=, ; echo "${yearList[*]}")
result=$(printf "%s%s"   "${result}" "Share of co-authored publications,${yearstring}")
result=$(printf "%s\n%s" "${result}" "co-authored publications")

IFS=$'\n'

for t in $total
do
  while IFS='¤' read year value; do
      totarray[${year}]=${value}
  done <<<"$t"
done

for c in $cooptot
do
  while IFS='¤' read year value; do
      cooparray[${year}]=${value}
  done <<<"$c"
done

for i in $coopint
do
  while IFS='¤' read year value; do
      intarray[${year}]=${value}
  done <<<"$i"
done

#echo "${totarray[@]}"
for y in "${yearList[@]}"
do
  x=$(( 100*${cooparray[$y]}/${totarray[$y]} ))
  result=$(printf '%s,%s%%' "$result" "$x" )
done
result=$(printf '%s\n%s' "$result" "int. co-authored publications")

for y in "${yearList[@]}"
do
  x=$(( 100*${intarray[$y]}/${totarray[$y]} ))
  result=$(printf '%s,%s%%' "$result" "$x" )
done

echo "${result}" > $OUTFILEPATH
echo "${result}"
cat $OUTFILEPATH
exit

for c in $cooptot
do
  IFS='¤' read -r -a cooparray <<< "$c"
done

for i in $coopint
do
  IFS='¤' read -r -a intarray <<< "$i"
done


#echo "cooparray[2017]:$cooparray['2017']:"
#exit
for y in "${yearList[@]}"
do
  #echo "${cooparray[$y]}:${cooparray[$y]}:"
  #echo "${totarray[$y]}:$totarray[$y]:"
  #x=$(( 100 * cooparray[$y]/totarray[$y] ))
  #printf -v result ",$x%"
  #echo $x
  echo "${totarray}"
done


exit
totalList[2017]=145
totalList[2016]=131
coopList[2017]=120

total:2013¤117
2014¤120
2015¤142
2016¤131
2017¤145:
cooptot:2013¤98
2014¤103
2015¤115
2016¤101
2017¤120:
coopint:2013¤48
2014¤57
2015¤68
2016¤67
2017¤72:


Share of co-authored publications,2017,2016,2015,2014,2013
co-authored publications,120/145*100%,98/117*100%,...
int. co-authored publications,72/145*100%,67/145*100%,...





2013¤117
2014¤120
2015¤142
2016¤131
2017¤145





for t in $total
do

done




exit;


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
