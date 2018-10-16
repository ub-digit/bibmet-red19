SELECT pv.pubyear, COUNT(DISTINCT p.id)
FROM publications p
JOIN publication_versions pv ON pv.id=p.current_version_id
JOIN people2publications p2p ON p2p.publication_version_id=pv.id
JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id=p2p.id
JOIN departments d ON d.id=d2p2p.department_id
JOIN publication_identifiers pi ON pi.publication_version_id=pv.id
JOIN red19.oa oa ON oa.doi=pi.identifier_value
JOIN people pe ON pe.id=p2p.person_id
JOIN identifiers i ON i.person_id=pe.id
--JOIN people pe ON pe.id=p2p.person_id
WHERE p.deleted_at IS NULL
AND (p.process_state NOT IN ('DRAFT', 'PREDRAFT') OR p.process_state IS NULL)
AND pv.pubyear BETWEEN :STARTYEAR AND :ENDYEAR
AND ( (d.id IN (:DEPTID) OR d.parentid IN (:DEPTID) OR d.grandparentid IN (:DEPTID)) OR (i.value IN (SELECT xkonto FROM red19.neuro3) AND d2p2p.department_id = 1384) )
AND i.source_id = 1
AND pi.identifier_code = 'doi'
AND oa.is_oa = 'True'
AND pv.publication_type_id IN (5,22)
GROUP BY pv.pubyear