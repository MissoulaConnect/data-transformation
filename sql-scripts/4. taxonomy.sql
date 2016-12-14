--Column		Requirement					Detail
--taxonomy_id	required						The category's unique taxonomy id.
--name			required						The name of the category.
--parent_id		required for child categories	The taxonomy_id of the parent category.
--parent_name	required for child categories	The name of the parent category.

  -- Enable use of foreign keys
PRAGMA foreign_keys = ON;

create table hsds_taxonomy(
taxonomy_id	TEXT PRIMARY KEY,
name			TEXT NOT NULL,
parent_id		TEXT,
parent_name	TEXT);

insert into hsds_taxonomy(
taxonomy_id,
name,
parent_id,
parent_name
)
select distinct a.TaxonomyCode as taxonomy_id,
	      a.Term as name,
	      coalesce(b.TaxonomyCode, c.TaxonomyCode) as parent_id,
	      coalesce(b.Term, c.Term) as parent_name
from tmp_taxonomy a
left outer join tmp_taxonomy b on a.ParentCode_Updated = b.TaxonomyCode_Updated and a.TaxonomyCode <> b.TaxonomyCode
left outer join tmp_taxonomy c on substr(a.TaxonomyCode,1,1) = c.TaxonomyCode and a.TaxonomyCode <> c.TaxonomyCode -- for top level e.g. match BD to B
order by a.TaxonomyCode;