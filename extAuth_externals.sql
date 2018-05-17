SELECT pv.pubyear, count(p.id)
FROM publications p
JOIN publication_versions pv ON pv.id=p.current_version_id
JOIN people2publications p2p ON p2p.publication_version_id=pv.id
JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id=p2p.id
JOIN departments d ON d.id=d2p2p.department_id
WHERE p.deleted_at IS NULL
AND (p.process_state NOT IN ('DRAFT', 'PREDRAFT') OR p.process_state IS NULL)
AND (d.id = :DEPTID OR d.parentid = :DEPTID OR d.grandparentid = :DEPTID)
AND pv.pubyear BETWEEN :STARTYEAR AND :ENDYEAR
AND p.id in (
	SELECT p.id
	FROM publications p
	JOIN publication_versions pv ON pv.id=p.current_version_id
	JOIN people2publications p2p ON p2p.publication_version_id=pv.id
	JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id=p2p.id
	JOIN departments d ON d.id=d2p2p.department_id
	WHERE p.deleted_at IS NULL
	AND (p.process_state NOT IN ('DRAFT', 'PREDRAFT') OR p.process_state IS NULL)
	AND (d.id = 666)
	AND pv.pubyear BETWEEN :STARTYEAR AND :ENDYEAR
)
GROUP BY pv.pubyear
