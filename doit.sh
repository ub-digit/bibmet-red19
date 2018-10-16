#!/bin/bash

STARTYEAR="2013"
ENDYEAR="2017"
DEPTS_FOR_SA="departments_sa.txt"
DEPTS_FOR_NON_SA="departments_non_sa.txt"
DEPTS_FOR_KONST="departments_konst.txt"
DEPTS_FOR_MATTE="departments_matte.txt"
DEPTS_FOR_SPECIAL="departments_special.txt"
DEPTS_FOR_MARINA="departments_marina.txt"
DEPTS_FOR_NEURO1="departments_neuro1.txt"
DEPTS_FOR_NEURO2="departments_neuro2.txt"
DEPTS_FOR_NEURO3="departments_neuro3.txt"


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

departments=$(cat "${DEPTS_FOR_MATTE}")
for unit in $departments ; do ./dType_matte.sh    "5" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./norList_matte.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./extAuthNat_matte.sh   "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./oa_matte.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./gender.sh             "${unit}" "${ENDYEAR}" "${ENDYEAR}" "ma"; done

departments=$(cat "${DEPTS_FOR_SPECIAL}")
for unit in $departments ; do ./special_dType.sh    "5" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./special_norList.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./special_extAuthNat.sh   "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./special_oa.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./special_gender.sh       "${unit}" "${ENDYEAR}" "${ENDYEAR}" "special"; done


departments=$(cat "${DEPTS_FOR_MARINA}")
for unit in $departments ; do ./dType_marina.sh    "5" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./norList_marina.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./extAuthNat_marina.sh   "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./oa_marina.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./gender_marina.sh       "${unit}" "${ENDYEAR}" "${ENDYEAR}" "marina"; done

departments=$(cat "${DEPTS_FOR_NEURO1}")
for unit in $departments ; do ./dType_neuro1.sh    "5" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./norList_neuro1.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./extAuthNat_neuro1.sh   "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./oa_neuro1.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./gender.sh              "${unit}" "${ENDYEAR}" "${ENDYEAR}" "n1"; done

departments=$(cat "${DEPTS_FOR_NEURO2}")
for unit in $departments ; do ./dType_neuro2.sh    "5" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./norList_neuro2.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./extAuthNat_neuro2.sh   "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./oa_neuro2.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./gender.sh              "${unit}" "${ENDYEAR}" "${ENDYEAR}" "n2"; done

departments=$(cat "${DEPTS_FOR_NEURO3}")
for unit in $departments ; do ./dType_neuro3.sh    "5" "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./norList_neuro3.sh      "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./extAuthNat_neuro3.sh   "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./oa_neuro3.sh           "${unit}" "${STARTYEAR}" "${ENDYEAR}"; done
for unit in $departments ; do ./gender.sh              "${unit}" "${ENDYEAR}" "${ENDYEAR}" "n3"; done

./genStatExcel.pl "${DEPTS_FOR_SA}"
./genStatExcel.pl "${DEPTS_FOR_NON_SA}"
./genStatExcel.pl "${DEPTS_FOR_KONST}"
./genStatExcel.pl "${DEPTS_FOR_MATTE}"
./genStatExcel.pl "${DEPTS_FOR_SPECIAL}"
./genStatExcel.pl "${DEPTS_FOR_MARINA}"
./genStatExcel.pl "${DEPTS_FOR_NEURO1}"
./genStatExcel.pl "${DEPTS_FOR_NEURO2}"
./genStatExcel.pl "${DEPTS_FOR_NEURO3}"

#soffice result/*.xls

