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


create table hsds_service(
  id INT,
  organization_id INT,
  program_id INT,
  location_id INT,
  name TEXT,
  alternate_name TEXT,
  url TEXT,
  email TEXT,
  status TEXT,
  application_process TEXT,
  wait_time TEXT
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
  wait_time
)
select s.provider_service_code_id as id,
		coalesce(sp.parent_provider_id,s.provider_id) + 1 as organization_id,
		s.provider_id + 1 as program_id,
		s.provider_id + 1 as location_id,
		s.taxonomy_name as name,
		null as alternate_name,
		sp.website_address as url,
		null as email,
		'active' as status,
		sp.intake_procedure as application_process,
		null as wait_time
from src_provider_taxonomy s
inner join src_provider sp on s.provider_id = sp.provider_id
where s.taxonomy_facet = 'Service';