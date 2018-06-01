/* PUBLICATION OUTPUT BASED ON GENDER */
SELECT prop.title, COUNT(prop.id) FROM (
	SELECT 
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
	WHERE p.deleted_at IS NULL
	AND (p.process_state NOT IN ('DRAFT', 'PREDRAFT') OR p.process_state IS NULL)
	AND (d.id IN (:DEPTID))
	AND pv.pubyear BETWEEN :STARTYEAR AND :ENDYEAR 
	AND i.source_id = 1
	---AND pfa.anstlpnr = 1
/*	AND p.id IN (
		SELECT pubid FROM legnor.master_2018 WHERE update_level = 2
		SELECT pubid FROM legnor.handels WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.humfak WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.it WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.natfak WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.sa WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.samfak WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.utbvet WHERE update_level = 2 
	)*/
) AS prop
WHERE prop.title NOT IN ('övriga')
GROUP BY prop.title
ORDER BY COUNT(prop.id) DESC
