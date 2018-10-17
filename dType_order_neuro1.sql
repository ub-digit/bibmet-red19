/*
  significant part: count(distinct p_view.id) 
 */
SELECT pv.publication_type_id,COUNT(DISTINCT p.id),pt.label_en
FROM publications p
JOIN publication_versions pv ON pv.id=p.current_version_id
JOIN publication_types pt ON pt.id=pv.publication_type_id
JOIN people2publications p2p ON p2p.publication_version_id=pv.id
JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id=p2p.id
JOIN departments d ON d.id=d2p2p.department_id
JOIN people pe ON pe.id=p2p.person_id
JOIN identifiers i ON i.person_id=pe.id
WHERE p.deleted_at IS NULL
AND (p.process_state NOT IN ('DRAFT', 'PREDRAFT') OR p.process_state IS NULL)
AND pv.pubyear between :STARTYEAR AND :ENDYEAR 
AND ( (d.id IN (:DEPTID) OR d.parentid IN (:DEPTID) OR d.grandparentid IN (:DEPTID)) OR (i.value IN (SELECT xkonto FROM red19.neuro1) AND (d.id IN (1384) OR d.parentid IN (1384) OR d.grandparentid IN (1384))) )
AND i.source_id = 1
GROUP BY pv.publication_type_id,pt.label_en
ORDER BY count(distinct p.id) DESC
