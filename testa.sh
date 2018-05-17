#!/bin/bash - 
# ============================================================================ #
#
#          FILE: testa.sh
# 
#         USAGE: ./testa.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Torgny Rasmark (TR), Torgny.Rasmark@gmail.com
#  ORGANIZATION: lifeLAB
#       CREATED: 2018-05-17 15:21
#      REVISION:  ---
# ============================================================================ #



# -------------------------------------------------- #
# sourcing the lookup table                          #
# -------------------------------------------------- #
. metaLookup.sh
# -------------------------------------------------- #
# example: doing stuff for each number in a lookup   #
# -------------------------------------------------- #
for number in $(echo ${metaLookupHash["Biomedicine 2"]} | tr "," " ")
do
  echo "This is the number:${number}:"
done
# -------------------------------------------------- #
# example: doing stuff for each number in all lookups#
# -------------------------------------------------- #
for key in "${!metaLookupHash[@]}"
do 
  echo "# --------------- key:'${key}'"
  for number in $(echo ${metaLookupHash["${key}"]} | tr "," " ")
  do
    echo "This is the number:${number}:"
  done
done
# -------------------------------------------------- #
# example: doing stuff for each lookup               #
# -------------------------------------------------- #
for key in "${!metaLookupHash[@]}"
do 
  echo "select * from blabla where xxx in (${metaLookupHash["${key}"]})"
done
# -------------------------------------------------- #
# example: using function                            #
# -------------------------------------------------- #
metaLookup 'Biomedicine 2'
echo
echo "function lookup:12345:$(metaLookup 12345 )"
echo "function lookup:Biomedicine 2:$(metaLookup 'Biomedicine 2')"
