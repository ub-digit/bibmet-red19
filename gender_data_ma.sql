/* PUBLICATION OUTPUT BASED ON GENDER */
SELECT prop.title, prop.person_kon, COUNT(prop.id) FROM (
	SELECT pfa.person_kon, 
	p18.category as title, p.id
	FROM publications p
	JOIN publication_versions pv ON pv.id=p.current_version_id
	JOIN people2publications p2p ON p2p.publication_version_id=pv.id
	JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id=p2p.id
	JOIN departments d ON d.id=d2p2p.department_id
	JOIN people pe ON pe.id=p2p.person_id
	JOIN identifiers i ON i.person_id=pe.id
	JOIN red19.persons_for_analysis pfa ON pfa.xkonto = i.value
	JOIN red19.personal_2018 p18 ON p18.p_number=pfa.pnr_kod_10
	JOIN publication_identifiers pi ON pi.publication_version_id=pv.id
	WHERE p.deleted_at IS NULL
	AND (p.process_state NOT IN ('DRAFT', 'PREDRAFT') OR p.process_state IS NULL)
	AND (d.id IN (:DEPTID) OR d.parentid IN (:DEPTID) OR d.grandparentid IN (:DEPTID))
	AND p2p.person_id IN (122,920,2230,6456,7663,15395,15891,18377,19835,20514,20518,20522,20866,21717,77129,77141,77148,77164,77275,77278,77279,77297,77306,78396,80763,81177,81331,82037,83001,83456,84204,84371,84432,85193,85213,92471,94680,105654,107072,113731,117772,120486,124425,125121,125271,125272,133747,145601,152535,152727,155673,156002,156779,156933,157250,160387,163062,173047,175708,176655,178298,179836,183846,204170,206571,213161,220822,240502,243794,250821,263407,270245,428803,448843,497951,544478,635533)
	AND pv.pubyear = :ENDYEAR 
	AND i.source_id = 1
	--AND pfa.anstlpnr = 1
	AND p.id IN (
		SELECT g2e.pubid 
		FROM cwts.fielddata  fd
		JOIN "cross".gup2ext g2e ON g2e.isi_id=fd.isi_id
		--WHERE fd."n*%" >= 90
	)
) AS prop
--WHERE prop.title NOT IN ('övriga')
GROUP BY prop.title, prop.person_kon
ORDER BY prop.title, prop.person_kon