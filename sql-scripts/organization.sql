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

select *
from (
	select distinct s2.provider_id as id, --Issue 1: Format does not match HSDS
			s2.provider_name as name,
			s2.provider_aka as alternate_name,
			s2.provider_description as description,
			null as email,
			s2.website_address as url,
			null as tax_status,
			null as tax_id,
			null as year_incorporated,
			null as legal_status
	from src_provider s1
	inner join src_provider s2 on s1.parent_provider_id = s2.provider_id
	where s2.provider_id is not null
	union
	select distinct s1.provider_id as id, --Issue 1: Format does not match HSDS
			s1.provider_name as name,
			s1.provider_aka as alternate_name,
			s1.provider_description as description,
			null as email,
			s1.website_address as url,
			null as tax_status,
			null as tax_id,
			null as year_incorporated,
			null as legal_status
	from src_provider s1
	where s1.parent_provider_id is null
) organization
order by id;