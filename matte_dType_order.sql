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
AND (d.id IN (:DEPTID) OR d.parentid IN (:DEPTID) OR d.grandparentid IN (:DEPTID))
AND p2p.person_id IN (122,920,2230,6456,7663,15395,15891,18377,19835,20514,20518,20522,20866,21717,77129,77141,77148,77164,77275,77278,77279,77297,77306,78396,80763,81177,81331,82037,83001,83456,84204,84371,84432,85193,85213,92471,94680,105654,107072,113731,117772,120486,124425,125121,125271,125272,133747,145601,152535,152727,155673,156002,156779,156933,157250,160387,163062,173047,175708,176655,178298,179836,183846,204170,206571,213161,220822,240502,243794,250821,263407,270245,428803,448843,497951,544478,635533)
GROUP BY pv.publication_type_id,pt.label_en
ORDER BY count(distinct p.id) DESC
