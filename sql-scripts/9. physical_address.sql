--Field Name 	Type (Format) 	Description 	Required? 	Unique?
--id 	string 	Each physical address must have a unique identifier 	False 	False
--location_id 	string 	The identifier of the location for which this is the address 	False 	False
--attention 	string 	The person or entity whose attention should be sought at the location 	False 	False
--address_1 	string 	The first line of the address 	False 	False
--address_2 	string 	The second line of the address 	False 	False
--address_3 	string 	The third line of the address 	False 	False
--address_4 	string 	The fourth line of the address 	False 	False
--city 	string 	The city in which the address is located 	False 	False
--state_province 	string 	The state or province in which the address is located 	False 	False
--postal_code 	string 	The postal code for the address 	False 	False
--country 	string 	The country in which the address is located 	False 	False

-- Enable use of foreign keys
PRAGMA foreign_keys = ON;

create table hsds_physical_address(
    id	INTEGER PRIMARY KEY,
    location_id	INT,
    attention	TEXT,
    address_1	TEXT,
    address_2	TEXT,
    address_3	TEXT,
    address_4	TEXT,
    city	TEXT,
    state_province	TEXT,
    postal_code	TEXT,
    country	TEXT,
    FOREIGN KEY (location_id) references hsds_location(id) ON DELETE CASCADE);

insert into hsds_physical_address(
	id,
	location_id,
	attention,
	address_1,
	address_2,
	address_3,
	address_4,
	city,
	state_province,
	postal_code,
	country
)
select tp.program_id as id,
		hl.id as location_id, 
		null as attention,
		case when length(trim(sp.line1)) = 0 then sp.line2 else sp.line1 end as address_1,
		case when length(trim(sp.line1)) = 0 then '' else sp.line2 end as address_2,
		null as address_3,
		null as address_4,
		sp.city,
		sp.province as state_province,
		sp.postal_code,
		case when length(trim(coalesce(sp.country,'US'))) = 0 then 'US' else trim(coalesce(sp.country,'US')) end as country
from src_provider sp
inner join tmp_program tp on sp.provider_id = tp.agency_id
inner join hsds_location hl on tp.program_id = hl.id;
