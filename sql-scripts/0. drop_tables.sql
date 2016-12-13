--------------------------
-- Drop all hsds tables --
--------------------------
PRAGMA FOREIGN_KEYS=0;
drop table if exists tmp_organization;
drop table if exists hsds_organization;
drop table if exists tmp_program;
drop table if exists hsds_program;
drop table if exists hsds_service;
drop table if exists hsds_location;
drop table if exists hsds_service_at_location;
drop table if exists hsds_contact;
drop table if exists hsds_phone;
drop table if exists hsds_physical_address;
drop table if exists meta_error;
drop table if exists hsds_taxonomy;
drop table if exists tmp_taxonomy;
