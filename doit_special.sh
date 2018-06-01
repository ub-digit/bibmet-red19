#!/bin/bash

STARTYEAR="2013"
ENDYEAR="2017"
DEPTS_FOR_SPECIAL="departments_special.txt"

departments=$(cat "${DEPTS_FOR_SPECIAL}")
for unit in $departments ; do ./dType.sh    "5" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./norList.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./extAuthNat.sh   "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./oa.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./gender.sh       "${unit}" "${ENDYEAR}" "${ENDYEAR}" "na"; done

./genStatExcel.pl "${DEPTS_FOR_SPECIAL}"

#soffice result/*.xls
