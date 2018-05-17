Med ROW_NUMBER kan man lista upp radnumret, och med en case-sats kan man gruppera ihop alla som är högre än 10, exempelvis.

SELECT p_view.publication_type_id, p_view.publication_type_label_en, COUNT(DISTINCT p_view.id)
  ,CASE
    WHEN row_number() over(ORDER BY count(distinct p_view.id) DESC) > 10 THEN 11
    ELSE row_number() over(ORDER BY count(distinct p_view.id) DESC)
  END AS positioning
FROM dev_publications_view p_view
JOIN people2publications p2p ON p2p.publication_version_id=p_view.publication_version_id
JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id=p2p.id
JOIN departments d ON d.id=d2p2p.department_id
WHERE d.id = 1284 OR d.parentid = 1284 OR d.grandparentid = 1284
GROUP BY p_view.publication_type_id, p_view.publication_type_label_en
ORDER BY count(distinct p_view.id) DESC


Men hur används detta i sql-satsen?





/* FASTSTÄLL SORTERINGSORDNING */
SELECT p_view.publication_type_id, p_view.publication_type_label_en, COUNT(DISTINCT p_view.id)
FROM dev_publications_view p_view
JOIN people2publications p2p ON p2p.publication_version_id=p_view.publication_version_id
JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id=p2p.id
JOIN departments d ON d.id=d2p2p.department_id
WHERE (d.id = 1284 OR d.parentid = 1284 OR d.grandparentid = 1284)
GROUP BY p_view.publication_type_id, p_view.publication_type_label_en
ORDER BY count(distinct p_view.id) DESC


/* PER PUBLIKATIONSTYP PER ÅR PER INSTITUTION/ENHET */
SELECT p_view.publication_type_label_en, p_view.pubyear, COUNT(DISTINCT p_view.id)
FROM dev_publications_view p_view
JOIN people2publications p2p ON p2p.publication_version_id=p_view.publication_version_id
JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id=p2p.id
JOIN departments d ON d.id=d2p2p.department_id
WHERE (d.id = 1284 OR d.parentid = 1284 OR d.grandparentid = 1284)
AND p_view.pubyear < 2018 AND p_view.pubyear > 2012
GROUP BY p_view.publication_type_label_en, p_view.pubyear
ORDER BY p_view.pubyear DESC, count(distinct p_view.id) DESC

