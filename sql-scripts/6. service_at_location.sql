--Field Name 	        Type (Format) 	Description 	                                                                            Required? 	Unique?
--id 	                string 	        Each entry must have a unique identifier 	                                                True 	    True
--service_id 	        string 	        The identifier of the service at a given location. 	                                        True 	    False
--location_id 	        string 	        The identifier of the location where this service operates. 	                            True 	    False
--url 	                string 	        If the service at this location has a specific URL, that can be provided here. 	            False 	    False
--email 	            string 	        If the service at this location has a specific email address, that can be provided here. 	False 	    False

-- Enable use of foreign keys
PRAGMA foreign_keys = ON;

create table hsds_service_at_location(
  id INTEGER PRIMARY KEY,
  service_id INT,
  location_id INT,  
  url TEXT,
  email TEXT,
  FOREIGN KEY (service_id) references hsds_service(id) ON DELETE CASCADE,
  FOREIGN KEY (location_id) references hsds_location(id) ON DELETE CASCADE  
);

-- Improve performance on joins to hsds_service
create index hsds_service_at_location_service_id_idx on hsds_service_at_location (service_id);
create index hsds_service_at_location_location_id_idx on hsds_service_at_location (location_id);

insert into hsds_service_at_location(
  id,
  service_id,
  location_id,  
  url ,
  email)
select tp.program_id as id,
	   tp.program_id as service_id,
	   tp.program_id as location_id,
	   sp.website_address as url,
	   null as email
from src_provider sp
inner join tmp_program tp on sp.provider_id = tp.agency_id
inner join hsds_program p on tp.program_id = p.id
inner join hsds_organization o on tp.organization_id = o.id
inner join hsds_location l on tp.program_id = l.id
where sp.provider_id in (select provider_id from src_provider_taxonomy where taxonomy_facet = 'Service');
		
