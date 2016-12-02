--Field Name 	        Type (Format) 	Description 	                                                                            Required? 	Unique?
--id 	                string 	        Each entry must have a unique identifier 	                                                True 	    True
--service_id 	        string 	        The identifier of the service at a given location. 	                                        True 	    False
--location_id 	        string 	        The identifier of the location where this service operates. 	                            True 	    False
--url 	                string 	        If the service at this location has a specific URL, that can be provided here. 	            False 	    False
--email 	            string 	        If the service at this location has a specific email address, that can be provided here. 	False 	    False

create table hsds_service_at_location(
  id INTEGER PRIMARY KEY,
  service_id INT,
  location_id INT,  
  url TEXT,
  email TEXT
);

-- Improve performance on joins to hsds_service
create index hsds_service_at_location_service_id_idx on hsds_service_at_location (service_id);

insert into hsds_service_at_location(
  id,
  service_id,
  location_id,  
  url ,
  email)
 select s.provider_service_code_id as id,
		s.provider_service_code_id as service_id,
		sp.provider_id+1 as location_id,
		sp.website_address as url,
		null as email
 from src_provider_taxonomy s
inner join src_provider sp on s.provider_id = sp.provider_id
where s.taxonomy_facet = 'Service';
		