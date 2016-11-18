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

select s.provider_service_code_id as id,
		p.organization_id,
		p.id as program_id,
		null as location_id,
		s.taxonomy_name as name,
		null as alternate_name,
		o.url,
		null as email,
		'active' as status,
		sp. intake_procedure as application_process,
		null as wait_time
from src_provider_taxonomy s
left outer join hsds_program p on s.provider_id = p.id
left outer join hsds_organization o on p.organization_id = o.id
left outer join src_provider sp on sp.provider_id = o.id
where taxonomy_facet = 'Service';