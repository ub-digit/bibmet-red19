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
WHERE p.deleted_at IS NULL
AND (p.process_state NOT IN ('DRAFT', 'PREDRAFT') OR p.process_state IS NULL)
AND pv.pubyear between :STARTYEAR AND :ENDYEAR 
AND (d.id IN (:DEPTID))
AND p2p.person_id IN (SELECT id FROM tmp.marina_vetenskaper_2018)
GROUP BY pv.publication_type_id,pt.label_en
ORDER BY count(distinct p.id) DESC
