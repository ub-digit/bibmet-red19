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
#declare -A pYear pPubs cYear cPubs
declare -A totalList coopList intList
declare -A totarray cooparray intarray
echo "Processing ${OUTFILEPATH}"
# -------------------------------------------------- #
# retrieve the data
# -------------------------------------------------- #
total=$(psql -tAF"¤" -Upostgres -h "${DBHOST}"  -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < marina_extAuthNatTotal.sql)
cooptot=$(psql -tAF"¤" -Upostgres -h "${DBHOST}"  -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < marina_extAuthNatCoop.sql)
coopint=$(psql -tAF"¤" -Upostgres -h "${DBHOST}"  -v DEPTID=${DEPTID} -v STARTYEAR=${STARTYEAR} -v ENDYEAR=${ENDYEAR} "${BIBMET_DB}" < marina_extAuthNatIntCoop.sql)


# Initialize
for y in "${yearList[@]}"
do
  totarray[${y}]=0
  cooparray[${y}]=0
  intarray[${y}]=0
done

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
  if [ "${totarray[$y]}" -eq "0" ]; then
    x=0
  else
    #if [ "${cooparray[$y]}" -eq "0" ]; then
    #  x=0
    #else
      x=$(( 100*${cooparray[$y]}/${totarray[$y]} ))
    #fi
  fi

  result=$(printf '%s,%s%%' "$result" "$x" )
done
result=$(printf '%s\n%s' "$result" "int. co-authored publications")

for y in "${yearList[@]}"
do
  if [ "${totarray[$y]}" -eq "0" ]; then
    x=0
  else
    x=$(( 100*${intarray[$y]}/${totarray[$y]} ))
  fi
  result=$(printf '%s,%s%%' "$result" "$x" )
done

echo "${result}" > $OUTFILEPATH
