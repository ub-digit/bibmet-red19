SELECT pubs.pubyear, pubs.update_level, pubs.publication_type_id, pubs.publication_type_label_en, count(DISTINCT pubs.id)
FROM (
	SELECT pv.pubyear, pv.publication_type_id, pt.label_en AS publication_type_label_en, COALESCE(norska.update_level::integer, 0::integer) AS update_level, p.id
	FROM publications p
	JOIN publication_versions pv ON pv.id=p.current_version_id
	JOIN people2publications p2p ON p2p.publication_version_id=pv.id
	JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id=p2p.id
	JOIN departments d ON d.id=d2p2p.department_id
	JOIN publication_types pt ON pt.id=pv.publication_type_id
	JOIN people pe ON pe.id=p2p.person_id
	JOIN identifiers i ON i.person_id=pe.id
	LEFT JOIN (
		SELECT pubid, update_level, nor_points FROM legnor.master_2018
	    /* SELECT pubid, update_level, nor_points FROM legnor.handels UNION
	    SELECT pubid, update_level, nor_points FROM legnor.humfak UNION
	    SELECT pubid, update_level, nor_points FROM legnor.it UNION
	    SELECT pubid, update_level, nor_points FROM legnor.natfak UNION
	    SELECT pubid, update_level, nor_points FROM legnor.sa UNION
	    SELECT pubid, update_level, nor_points FROM legnor.samfak UNION
	    SELECT pubid, update_level, nor_points FROM legnor.utbvet */
	) AS norska ON norska.pubid=p.id
	WHERE p.deleted_at IS NULL
	AND (p.process_state NOT IN ('DRAFT', 'PREDRAFT') OR p.process_state IS NULL)
	AND ( (d.id IN (:DEPTID) OR d.parentid IN (:DEPTID) OR d.grandparentid IN (:DEPTID)) OR (i.value IN (SELECT xkonto FROM red19.neuro3) AND d2p2p.department_id = 1384) )
	AND i.source_id = 1
	AND pv.pubyear BETWEEN :STARTYEAR AND :ENDYEAR
	--AND pv.publication_type_id = 5
	AND pv.publication_type_id IN (5, 9, 10, 22)
) AS pubs
GROUP BY pubs.pubyear, pubs.publication_type_id, pubs.publication_type_label_en, update_level
ORDER BY pubs.pubyear, pubs.publication_type_id, update_level
