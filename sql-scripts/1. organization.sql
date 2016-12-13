--Field Name          Type (Format)   Description                                                                                 Required    Unique
--id 	                string (uuid)   Each organization must have a unique identifier. 	                                        True 	    True
--name 	                string 	        The official or public name of the organization. 	                                        True 	    False
--alternate_name 	    string 	        Alternative or commonly used name for the organization. 	                                False 	    False
--description 	        string 	        A brief summary about the organization. It can contain markup such as HTML or Markdown. 	True 	    False
--email 	            string (email) 	The contact e-mail address for the organization. 	                                        False 	    False
--url 	                string 	        The URL (website address) of the organization. 	                                            False 	    False
--tax_status 	        string 	        Government assigned tax designation for for tax-exempt organizations. 	                    False 	    False
--tax_id 	            string 	        A government issued identifier used for the purpose of tax administration. 	                False 	    False
--year_incorporated     date (yyyy) 	The year in which the organization was legally formed. 	                                    False 	    False
--legal_status 	        string 	        The legal status defines the conditions that an organization is operating under; 
--                                    e.g. non-profit, private corporation or a government organization. 	                        False 	    False

-- Enable use of foreign keys
PRAGMA foreign_keys = ON;

create table hsds_organization(
  id INTEGER PRIMARY KEY,
  name TEXT,
  alternate_name TEXT,
  description TEXT,
  email TEXT,
  url TEXT,
  tax_status TEXT,
  tax_id TEXT,
  year_incorporated TEXT,
  legal_status TEXT
);

create table tmp_organization as
-- Has Parent and parent exists in the src_provider table
select distinct s2.provider_id +1 as id, --Issue 1: Format does not match HSDS
        s2.provider_id as original_id,
		s2.provider_name as name,
		s2.provider_aka as alternate_name,
		coalesce(s2.provider_description,'No description provided') as description,
		null as email,
		s2.website_address as url,
		null as tax_status,
		null as tax_id,
		null as year_incorporated,
		null as legal_status
from src_provider s1
inner join src_provider s2 on s1.parent_provider_id = s2.provider_id -- < this is the parent provider
union
-- Top Level Agencies: No parents
select distinct s1.provider_id +1 as id, --Issue 1: Format does not match HSDS
        s1.provider_id as original_id,
		s1.provider_name as name,
		s1.provider_aka as alternate_name,
		coalesce(s1.provider_description,'No description provided') as description,
		null as email,
		s1.website_address as url,
		null as tax_status,
		null as tax_id,
		null as year_incorporated,
		null as legal_status
from src_provider s1
left outer join src_provider s2 on s1.parent_provider_id = s2.provider_id -- < this is the parent provider
where s1.parent_provider_id is null
or    s2.provider_id is null;

insert into hsds_organization(
  id,
  name,
  alternate_name,
  description,
  email,
  url,
  tax_status,
  tax_id,
  year_incorporated,
  legal_status
)
select   distinct id,
          name,
          alternate_name,
          description,
          email,
          url,
          tax_status,
          tax_id,
          year_incorporated,
          legal_status
from tmp_organization
order by id;