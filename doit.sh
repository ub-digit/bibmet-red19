#!/bin/bash

STARTYEAR="2013"
ENDYEAR="2017"
DEPTS_FOR_SA="departments_sa.txt"
DEPTS_FOR_NON_SA="departments_non_sa.txt"

rm result/*.x*
rm -rf dType extAuth gender norList oa
departments=$(cat "${DEPTS_FOR_SA}")
for unit in $departments ; do ./dType.sh    "5" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./norList.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./extAuthNat.sh   "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./oa.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./gender.sh       "${unit}" "${STARTYEAR}" "${ENDYEAR}" "na"; done

departments=$(cat "${DEPTS_FOR_NON_SA}")
for unit in $departments ; do ./dType.sh   "10" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./norList.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./extAuth.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./oa.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./gender.sh       "${unit}" "${STARTYEAR}" "${ENDYEAR}" "hu"; done

./genStatExcel.pl "${DEPTS_FOR_SA}"
./genStatExcel.pl "${DEPTS_FOR_NON_SA}"

#soffice result/*.xls
