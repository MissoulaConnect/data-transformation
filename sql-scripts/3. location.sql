--Field Name 	    Type (Format) 	Description 	                                                                            Required? 	Unique?
--id 	            string 	        Each location must have a unique identifier 	                                            False 	    False
--organization_id 	string 	        Each location must belong to a single organization. 
--                                  The identifier of the organization should be given here. 	                                False 	    False
--name 	            string 	        The name of the location 	                                                                False 	    False
--alternate_name 	string 	        An alternative name for the location 	                                                    False 	    False
--transportation 	string 	        A description of the access to public or private transportation to and from the location. 	False 	    False
--latitude 	        number 	        Y coordinate of location expressed in decimal degrees in WGS84 datum. 	                    False 	    False
--longitude 	    number 	        X coordinate of location expressed in decimal degrees in WGS84 datum. 	                    False 	    False

--------------------------------------------------------------------------------------------------------------------------
--                                                                     Assumptions:                                                        --
--------------------------------------------------------------------------------------------------------------------------
-- Services are provided at locations attached to each program (agency)
-- Services are provided at locations attached to  each provider (parent)
--------------------------------------------------------------------------------------------------------------------------

create table hsds_location(
  id INTEGER PRIMARY KEY,
  organization_id INT,
  name TEXT,
  alternate_name TEXT,
  transportation TEXT,
  latitude REAL,
  longitude REAL
);

insert into hsds_location(
  id,
  organization_id,
  name,
  alternate_name,
  transportation,
  latitude,
  longitude
)
select provider_id+1 as id, 
	coalesce(parent_provider_id, provider_id) + 1 as organization_id, 
	ltrim(rtrim(coalesce(city,''))) || case when city is not null and province is not null then ', ' else '' end || ltrim(rtrim(coalesce(province, ''))) as name,
	null as alternate_name,
	null as transportation,
	Latitude,
	Longitude
from src_provider;