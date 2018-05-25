#!/bin/bash - 
# ============================================================================ #
#
#          FILE: metaLookup.sh
# 
#         USAGE: ./metaLookup.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Torgny Rasmark (TR), Torgny.Rasmark@gmail.com
#  ORGANIZATION: lifeLAB
#       CREATED: 2018-05-17 14:23
#      REVISION:  ---
# ============================================================================ #

declare -A metaLookupHash
#metaLookupHash=( ["Biomedicine 1"]="1608,1609" ["Biomedicine 2"]="1610,1611,1612,1613" ["Biomedicine 3"]="1797" ["Clinical Sciences 1"]="1616,1759,1760,1761,1772" ["Clinical Sciences 2"]="1618,1769,1770,1771" ["Clinical Sciences 3"]="1617,1762,1765,1766,1767,1768" ["Clinical Sciences 4"]="1763,1764" ["Medicine 1"]="1621" ["Medicine 2"]="1625,1793" ["Medicine 3"]="1623,1624,1840,1841,1920" ["Neuroscience and Physiology 1"]="1627,1628" ["Neuroscience and Physiology 2"]="1629,1630,1960" ["Neuroscience and Physiology 3"]="1626,1919" )
#metaLookupHash=( ["Biomedicine1"]="1608,1609" ["Biomedicine2"]="1610,1611,1612,1613" ["Biomedicine3"]="1797" ["ClinicalSciences1"]="1616,1759,1760,1761,1772" ["ClinicalSciences2"]="1618,1769,1770,1771" ["ClinicalSciences3"]="1617,1762,1765,1766,1767,1768" ["ClinicalSciences4"]="1763,1764" ["Medicine1"]="1621" ["Medicine2"]="1625,1793" ["Medicine3"]="1623,1624,1840,1841,1920" ["NeuroscienceAndPhysiology1"]="1627,1628" ["NeuroscienceAndPhysiology2"]="1629,1630,1960" ["NeuroscienceAndPhysiology3"]="1626,1919" )
metaLookupHash=( ["Biomedicine1"]="1608,1609" ["Biomedicine2"]="1610,1611,1612,1613" ["Biomedicine3"]="1797" ["ClinicalSciences1"]="1759,1760,1761,1772" ["ClinicalSciences2"]="1769,1770,1771" ["ClinicalSciences3"]="1762,1765,1766,1767,1768" ["ClinicalSciences4"]="1763,1764" ["Medicine1"]="1621" ["Medicine2"]="1625,1793" ["Medicine3"]="1623,1624,1840,1841,1920" ["NeuroscienceAndPhysiology1"]="1627,1628" ["NeuroscienceAndPhysiology2"]="1629,1630,1960" ["NeuroscienceAndPhysiology3"]="1626,1919" )

function metaLookup(){
  key="${*}"
  #echo "key:${key}:"
  # should return in-arg when in-arg doesn't lookup
  if [ ${metaLookupHash[${key}]+_} ]
  then 
    echo -n "${metaLookupHash[${key}]}"
  else 
    echo -n "${key}"
  fi
}
