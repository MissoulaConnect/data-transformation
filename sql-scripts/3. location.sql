--Field Name 	    Type (Format) 	Description 	                                                                            Required? 	Unique?
--id 	            string 	        Each location must have a unique identifier 	                                            False 	    False
--organization_id 	string 	        Each location must belong to a single organization. 
--                                  The identifier of the organization should be given here. 	                                False 	    False
--name 	            string 	        The name of the location 	                                                                False 	    False
--alternate_name 	string 	        An alternative name for the location 	                                                    False 	    False
--transportation 	string 	        A description of the access to public or private transportation to and from the location. 	False 	    False
--latitude 	        number 	        Y coordinate of location expressed in decimal degrees in WGS84 datum. 	                    False 	    False
--longitude 	    number 	        X coordinate of location expressed in decimal degrees in WGS84 datum. 	                    False 	    False
-- description	required	Description of services provided at the location
--------------------------------------------------------------------------------------------------------------------------
--                                                                     Assumptions:                                                        --
--------------------------------------------------------------------------------------------------------------------------
-- Services are provided at locations attached to each program (agency)
-- Services are provided at locations attached to  each provider (parent)
--------------------------------------------------------------------------------------------------------------------------

-- Enable use of foreign keys
PRAGMA foreign_keys = ON;

create table hsds_location(
  id INTEGER PRIMARY KEY,
  organization_id INT,
  name TEXT,
  alternate_name TEXT,
  transportation TEXT,
  latitude REAL,
  longitude REAL,
  description TEXT,
  FOREIGN KEY (organization_id) references hsds_organization(id) ON DELETE CASCADE  
);

insert into hsds_location(
  id,
  organization_id,
  name,
  alternate_name,
  transportation,
  latitude,
  longitude,
  description
)
select tp.program_id id,
		tp.organization_id,
		ltrim(rtrim(coalesce(sp.city,''))) || case when sp.city is not null and sp.province is not null then ', ' else '' end || ltrim(rtrim(coalesce(sp.province, ''))) as name,
		null as alternate_name,
		null as transportation,
		sp.Latitude,
		sp.Longitude,
		'See listed services'	      
from    tmp_program tp
inner join src_provider sp on tp.agency_id = sp.provider_id
