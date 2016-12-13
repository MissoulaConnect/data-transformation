--
-- Runs error checks based on required fields for both Ohana and hsds. 
-- Drops any rows which don't make the cut
-- Adds rows to meta_error table
-- 

  -- Enable use of foreign keys
PRAGMA foreign_keys = ON;

create table meta_error(
id	INTEGER PRIMARY KEY,
table_name TEXT,
original_id INT,
current_id INT,
error_text TEXT,
Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

--------------------------
-- Organization --
--------------------------

-- Mark duplicate hsds_organization id
insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_organization', id-1, id, 'provider_id is a duplicate'
from (
	select id
	from    hsds_organization
	group by id
	having count(*) > 1
) dup;

-- Mark blank or null name or description
insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_organization', id-1, id, 'provider_name is blank - All associated Organization information removed'
from hsds_organization
where trim(coalesce(name,'')) = '';

insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_organization', id-1, id, 'provider_description is blank - All associated Organization information removed'
from hsds_organization
where trim(coalesce(description,'') = '');

-- Remove organizations
delete from hsds_organization where id in (select current_id from meta_error where table_name = 'hsds_organization');

-------------------
-- Program --
-------------------

-- Mark blank or null name or description
insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_program', id-1, id, 'program name is blank'
from hsds_program
where trim(coalesce(name,'')) = '';

-- Remove programs
delete from hsds_program where id in (select current_id from meta_error where table_name = 'hsds_program');

-------------------
-- Location --
-------------------

-- Mark blank or null name or description
insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_location', id-1, id, 'location (city + province) is blank'|| name
from hsds_location
where trim(coalesce(name,'')) = '';

insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_location', id-1, id, 'description is blank'
from hsds_location
where trim(coalesce(description,'') = '');

-- Remove locations
delete from hsds_location where id in (select current_id from meta_error where table_name = 'hsds_location');

-----------------
-- Service --
-----------------

-- Mark Service without Location
insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_service', id-1, id, 'Location is missing: ' || id
from hsds_service
where location_id not in (select id from hsds_location);

-- Mark blank or null status, name or description
insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_service', id-1, id, 'name is blank'|| name
from hsds_service
where trim(coalesce(name,'')) = '';

insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_service', id-1, id, 'description is blank'
from hsds_service
where trim(coalesce(description,'') = '');

insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_service', id-1, id, 'status is blank'
from hsds_service
where trim(coalesce(status,'') = '');

-- Remove Services
delete from hsds_service where id in (select current_id from meta_error where table_name = 'hsds_service');

-------------------
-- Contact --
-------------------

-- Mark blank or null name
insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_contact', id-1, id, 'name is blank'|| name
from hsds_contact
where trim(coalesce(name,'')) = '';

-- Remove Contacts
delete from hsds_contact where id in (select current_id from meta_error where table_name = 'hsds_contact');

------------------
-- Phone --
------------------
-- Mark blank or null number
insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_phone', id-1, id, 'number is blank'|| number
from hsds_phone
where trim(coalesce(number,'')) = '';

-- Mark numbers that aren't formatted correctly
insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_phone', id-1, id, 'number is formatted badly '|| number
from hsds_phone 
where NOT (number GLOB '???-???-????'
or number GLOB '??? ???-????'
or number GLOB '???.???.????'
or number GLOB '??????????'
or number GLOB '(???) ???-????'
or number GLOB '(???)???-????')
or ABS(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(number, '.',''),'-',''),' ',''),'(',''),')','')) = 0;

-- Remove Phone
delete from hsds_phone where id in (select current_id from meta_error where table_name = 'hsds_phone');

------------------
-- Address --
------------------
-- Mark blank or null address_1,city, postal_code, country
insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_physical_address', id-1, id, 'address_1 is blank'
from hsds_physical_address
where trim(coalesce(address_1,'')) = '';

insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_physical_address', id-1, id, 'city is blank'
from hsds_physical_address
where trim(coalesce(city,'')) = '';

insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_physical_address', id-1, id, 'postal_code is blank'
from hsds_physical_address
where trim(coalesce(postal_code,'')) = '';

insert into meta_error(table_name, original_id, current_id, error_text)
select 'hsds_physical_address', id-1, id, 'country is blank'
from hsds_physical_address
where trim(coalesce(country,'')) = '';

-- Remove Address
delete from hsds_physical_address where id in (select current_id from meta_error where table_name = 'hsds_physical_address');

-- Remove location with no physical_address
delete from hsds_location where id not in (select location_id from hsds_physical_address);

