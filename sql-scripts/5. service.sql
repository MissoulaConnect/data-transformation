--Field Name 	        Type (Format) 	Description 	                                                            Required? 	Unique?
--id 	                string 	        Each service must have a unique identifier. 	                            True 	    True
--organization_id 	    string 	        The identifier of the organization that provides this service. 	            True 	    False
--program_id 	        string 	        The identifier of the program this service is delivered under (optional) 	False 	    False
--location_id 	        string 	        The identifier of the location where this service is delivered. 	        False 	    False
--name 	                string 	        The official or public name of the service. 	                            True 	    False
--alternate_name 	    string 	        Alternative or commonly used name for a service. 	                        False 	    False
--url 	                string 	        URL of the service 	                                                        False 	    False
--email 	            string 	        Email address for the service 	                                            False 	    False
--status 	            string 	        The current status of the service. 	                                        True 	    False
--application_process 	string 	        The steps needed to access the service. 	                                False 	    False
--wait_time 	        string 	        Time a client may expect to wait before receiving a service. 	            False 	    False
-- description	required	Description of the service provided

  -- Enable use of foreign keys
PRAGMA foreign_keys = ON;

create table hsds_service(
  id INT PRIMARY KEY,
  organization_id INT,
  program_id INT,
  location_id INT,
  name TEXT,
  alternate_name TEXT,
  url TEXT,
  email TEXT,
  status TEXT,
  application_process TEXT,
  wait_time TEXT,
  description TEXT,
  taxonomy_ids TEXT,
  FOREIGN KEY (organization_id) references hsds_organization(id) ON DELETE CASCADE,
  FOREIGN KEY (location_id) references hsds_location(id) ON DELETE CASCADE,
  FOREIGN KEY (program_id) references hsds_program(id) ON DELETE CASCADE  
);

insert into hsds_service(
  id,
  organization_id,
  program_id,
  location_id,
  name,
  alternate_name,
  url,
  email,
  status,
  application_process,
  wait_time,
  description,
  taxonomy_ids
)
select tp.program_id as id,
		tp.organization_id,
		tp.program_id,
		l.id as location_id,
		sp.provider_name as name,
		null as alternate_name,
		sp.website_address as url,
		null as email,
		'active' as status,
		sp.intake_procedure as application_process,
		null as wait_time,
		'None provided' as description,
		t.taxonomy_ids
from src_provider sp
inner join tmp_program tp on sp.provider_id = tp.agency_id
inner join hsds_program p on tp.program_id = p.id
inner join hsds_organization o on tp.organization_id = o.id
inner join hsds_location l on tp.program_id = l.id
left outer join (
    select provider_id, GROUP_CONCAT(taxonomy_code) as taxonomy_ids
    from src_provider_taxonomy
    where taxonomy_code in (select TaxonomyCode from tmp_taxonomy)
    group by provider_id
) t on sp.provider_id = t.provider_id   
where sp.provider_id in (select provider_id from src_provider_taxonomy where taxonomy_facet = 'Service');