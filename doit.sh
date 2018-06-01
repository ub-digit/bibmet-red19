#!/bin/bash

STARTYEAR="2013"
ENDYEAR="2017"
DEPTS_FOR_SA="departments_sa.txt"
DEPTS_FOR_NON_SA="departments_non_sa.txt"
DEPTS_FOR_KONST="departments_konst.txt"
DEPTS_FOR_SPECIAL="departments_special.txt"

rm result/*.x*
rm -rf dType extAuth gender norList oa
departments=$(cat "${DEPTS_FOR_SA}")
for unit in $departments ; do ./dType.sh    "5" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./norList.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./extAuthNat.sh   "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./oa.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./gender.sh       "${unit}" "${ENDYEAR}" "${ENDYEAR}" "na"; done

departments=$(cat "${DEPTS_FOR_NON_SA}")
for unit in $departments ; do ./dType.sh   "10" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./norList.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./extAuth.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./oa.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./gender.sh       "${unit}" "${ENDYEAR}"   "${ENDYEAR}" "hu"; done

departments=$(cat "${DEPTS_FOR_KONST}")
# dessa skall inte räkna med legnor någonstans. gör den det i gender? gör den det i de övriga?
for unit in $departments ; do ./dType.sh   "10" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./norList.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./extAuth.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./oa.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./gender.sh       "${unit}" "${ENDYEAR}"   "${ENDYEAR}" "ko"; done

departments=$(cat "${DEPTS_FOR_SPECIAL}")
for unit in $departments ; do ./special_dType.sh    "5" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./special_norList.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./special_extAuthNat.sh   "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./special_oa.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./special_gender.sh       "${unit}" "${ENDYEAR}" "${ENDYEAR}" "special"; done

./genStatExcel.pl "${DEPTS_FOR_SA}"
./genStatExcel.pl "${DEPTS_FOR_NON_SA}"
./genStatExcel.pl "${DEPTS_FOR_KONST}"
./genStatExcel.pl "${DEPTS_FOR_SPECIAL}"

#soffice result/*.xls
