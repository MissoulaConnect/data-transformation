--Field Name 	    Type (Format) 	Description 	                                                                            Required? 	Unique?
--id 	            string 	        Each location must have a unique identifier 	                                            False 	    False
--organization_id 	string 	        Each location must belong to a single organization. 
--                                  The identifier of the organization should be given here. 	                                False 	    False
--name 	            string 	        The name of the location 	                                                                False 	    False
--alternate_name 	string 	        An alternative name for the location 	                                                    False 	    False
--transportation 	string 	        A description of the access to public or private transportation to and from the location. 	False 	    False
--latitude 	        number 	        Y coordinate of location expressed in decimal degrees in WGS84 datum. 	                    False 	    False
--longitude 	    number 	        X coordinate of location expressed in decimal degrees in WGS84 datum. 	                    False 	    False

-----------------------------------------------------------------------------------------------
-- Assumptions: --
-----------------------------------------------------------------------------------------------
-- Services are provided at locatons attached to each program
-----------------------------------------------------------------------------------------------
drop table if exists hsds_location;

create table hsds_location(
  id INTEGER PRIMARY KEY,
  organization_id INT,
  name TEXT,
  alternate_name TEXT,
  transportation TEXT,
  latitude REAL,
  longitude REAL,
  src_provider_id INT
);

insert into hsds_location(
  organization_id,
  name,
  alternate_name,
  transportation,
  latitude,
  longitude,
  src_provider_id
)
select o.id as organization_id, 
		coalesce(sp.name, '-None Given-') as name,
		null as alternate_name,
		null as transportation,
		sp.Latitude as latitude,
		sp.Longitude as longitude,
		sp.provider_id
from hsds_organization o
left outer join (
	select distinct parent_provider_id, provider_id, coalesce(city,'') || case when city is not null and county is not null then ', ' else '' end || coalesce(county, '') as name,
			Latitude,
			Longitude
	from src_provider
	where coalesce(city,county) is not null
) sp on o.id = coalesce(sp.parent_provider_id, sp.provider_id);