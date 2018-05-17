CREATE OR REPLACE VIEW public.dev_publications_view AS 

SELECT
  p.id,
  p.published_at as publication_published_at,
  p.deleted_at as publication_deleted_at,
  p.current_version_id,
  p.epub_ahead_of_print,
  p.created_at as publication_created_at,
  p.updated_at as publication_updated_at,
  p.process_state,

  pv.id as publication_version_id,
  pv.publication_id,
  pv.content_type,
  pv.title,
  pv.alt_title,
  pv.abstract,
  pv.pubyear,
  pv.publanguage,
  pv.url,
  pv.keywords,
  pv.pub_notes,
  pv.journal_id,
  pv.sourcetitle,
  pv.sourcevolume,
  pv.sourceissue,
  pv.sourcepages,
  pv.issn,
  pv.eissn,
  pv.article_number,
  pv.extent,
  pv.publisher,
  pv.place,
  pv.isbn,
  pv.artwork_type,
  pv.dissdate,
  pv.dissopponent,
  pv.patent_applicant,
  pv.patent_application_number,
  pv.patent_application_date,
  pv.patent_number,
  pv.patent_date,
  pv.is_saved,
  pv.created_by as publication_version_created_by,
  pv.updated_by as publication_version_updated_by,
  pv.xml,
  pv.datasource,
  pv.extid,
  pv.sourceid,
  pv.biblreviewed_at,
  pv.biblreviewed_by,
  pv.created_at as publication_version_created_at,
  pv.updated_at as publication_version_updated_at,
  pv.ref_value,

  pt.id as publication_type_id,
  pt.code,
  pt.ref_options,
  pt.created_at as publication_type_created_at,
  pt.updated_at as publication_type_updated_at,
  pt.label_sv as publication_type_label_sv,
  pt.label_en as publication_type_label_en,
  pt.description_sv as publication_type_description_sv,
  pt.description_en as publication_type_description_en

FROM publications p
JOIN publication_versions pv ON pv.id=p.current_version_id
JOIN publication_types pt ON pt.id=pv.publication_type_id
WHERE p.deleted_at IS NULL
AND (p.process_state NOT IN ('DRAFT', 'PREDRAFT') OR p.process_state IS NULL)
;

ALTER TABLE public.dev_publications_view
  OWNER TO gup;