#!/bin/bash

rm result/*.x*
rm -rf dType extAuth gender norList oa
for unit in 1759 1760 1761 1772 ClinicalSciences1 ; do ./dType.sh    5 ${unit} 2013 2017; done
for unit in 1759 1760 1761 1772 ClinicalSciences1 ; do ./norList.sh    ${unit} 2013 2017; done
for unit in 1759 1760 1761 1772 ClinicalSciences1 ; do ./extAuthNat.sh ${unit} 2013 2017; done
for unit in 1759 1760 1761 1772 ClinicalSciences1 ; do ./oa.sh         ${unit} 2013 2017; done
for unit in 1759 1760 1761 1772 ClinicalSciences1 ; do ./gender.sh     ${unit} 2013 2017 na; done


./genStatExcel.pl departments_sa_short.txt

#soffice result/*.xls




exit;

rm result/*.x*
rm -rf dType extAuth gender norList oa

for unit in 1841 NeuroscienceAndPhysiology3 ; do ./dType.sh 5 ${unit} 2013 2017; done
for unit in 1841 NeuroscienceAndPhysiology3 ; do ./norList.sh ${unit} 2013 2017; done
for unit in 1841 NeuroscienceAndPhysiology3 ; do ./extAuthNat.sh ${unit} 2013 2017; done
for unit in 1841 NeuroscienceAndPhysiology3 ; do ./oa.sh ${unit} 2013 2017; done
for unit in 1841 NeuroscienceAndPhysiology3 ; do ./gender.sh ${unit} 2013 2017; done

for unit in 1849 1752 ; do ./dType.sh 10 ${unit} 2013 2017; done
for unit in 1849 1752 ; do ./norList.sh ${unit} 2013 2017; done
for unit in 1849 1752 ; do ./extAuth.sh ${unit} 2013 2017; done
for unit in 1849 1752 ; do ./oa.sh ${unit} 2013 2017; done
for unit in 1849 1752 ; do ./gender.sh ${unit} 2013 2017; done

./genStatExcel.pl departments_sa_shorty.txt




rm result/*.x*
rm -rf dType extAuth gender norList oa
for unit in 1381 ; do ./dType.sh 5 ${unit} 2013 2017; done
for unit in 1381 ; do ./norList.sh ${unit} 2013 2017; done
for unit in 1381 ; do ./extAuthNat.sh ${unit} 2013 2017; done
for unit in 1381 ; do ./oa.sh ${unit} 2013 2017; done
for unit in 1381 ; do ./gender.sh ${unit} 2013 2017; done
./genStatExcel.pl departments_sa_shorty.txt



