/* PUBLICATION OUTPUT BASED ON GENDER */
SELECT prop.title, prop.person_kon, COUNT(prop.id) FROM (
	SELECT pfa.person_kon, 
	CASE 
		WHEN COALESCE(pfa.tjanstebenamning,pfa.tjben_ben) LIKE '%rofessor%' THEN 'Professors'
		WHEN COALESCE(pfa.tjanstebenamning,pfa.tjben_ben) LIKE '%ektor%' AND pfa.tjben_ben NOT LIKE '%iträdande%' THEN 'Senior Lecturers'
		WHEN COALESCE(pfa.tjanstebenamning,pfa.tjben_ben) LIKE '%djunkt%' THEN 'Lecturers'
		WHEN COALESCE(pfa.tjanstebenamning,pfa.tjben_ben) LIKE '%Forskarassistent' THEN 'Research Associates'
		WHEN COALESCE(pfa.tjanstebenamning,pfa.tjben_ben) LIKE '%ektor, Biträdande%' THEN 'Associate Senior Lecturers'
		WHEN COALESCE(pfa.tjanstebenamning,pfa.tjben_ben) LIKE '%ost%' THEN 'Postdocs'
		WHEN COALESCE(pfa.tjanstebenamning,pfa.tjben_ben) LIKE '%oktorand%' THEN 'PhD Studentships'
		ELSE                                      'Other Teaching/Research Staff'
	END as title, p.id
	FROM publications p
	JOIN publication_versions pv ON pv.id=p.current_version_id
	JOIN people2publications p2p ON p2p.publication_version_id=pv.id
	JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id=p2p.id
	JOIN departments d ON d.id=d2p2p.department_id
	JOIN people pe ON pe.id=p2p.person_id
	JOIN identifiers i ON i.person_id=pe.id
	JOIN red19.persons_for_analysis pfa ON pfa.xkonto = i.value
	WHERE p.deleted_at IS NULL
	AND (p.process_state NOT IN ('DRAFT', 'PREDRAFT') OR p.process_state IS NULL)
	AND (d.id IN (:DEPTID) OR d.parentid IN (:DEPTID) OR d.grandparentid IN (:DEPTID))
	AND pv.pubyear BETWEEN :STARTYEAR AND :ENDYEAR 
	AND i.source_id = 1
	--AND pfa.anstlpnr = 1
	AND p.id IN (
		SELECT pubid FROM legnor.master_2018 --WHERE update_level = 2
		/*SELECT pubid FROM legnor.handels WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.humfak WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.it WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.natfak WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.sa WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.samfak WHERE update_level = 2 UNION
		SELECT pubid FROM legnor.utbvet WHERE update_level = 2*/
	)
) AS prop
--WHERE prop.title NOT IN ('övriga')
GROUP BY prop.title, prop.person_kon
ORDER BY prop.title, prop.person_kon