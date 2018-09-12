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
	AND (d.id IN (:DEPTID))
	AND pv.pubyear = :ENDYEAR 
	AND p2p.person_id IN (SELECT id FROM tmp.marina_vetenskaper_2018)
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