--Field Name 	    Type (Format) 	Description 	                                            Required? 	Unique?
--id 	            string 	        Each program must have a unique identifier. 	            True 	    True
--organization_id 	string (uuid) 	Each program must belong to a single organization. 
--                                  The identifier of the organization should be given here. 	True 	    False
--name 	            string 	        The name of the program 	                                True 	    False
--alternate_name 	string 	        An alternative name for the program 	                    False 	    False

  -- Enable use of foreign keys
PRAGMA foreign_keys = ON;

create table hsds_program(
  id INT PRIMARY KEY,
  organization_id INT,
  name TEXT,
  alternate_name TEXT,
  FOREIGN KEY (organization_id) references hsds_organization(id) ON DELETE CASCADE
);

create table tmp_program as 
select distinct agency.provider_id agency_id, 	
        agency.provider_id + 1 program_id,
		parent.provider_id parent_id,
		coalesce(parent.provider_id,agency.provider_id) original_organization_id,
		coalesce(parent.provider_id,agency.provider_id) + 1 as organization_id,  -- Parent ID
		agency.provider_name name,
		agency.provider_aka alternate_name
from    tmp_organization t
inner join src_provider agency on t.original_id = coalesce(parent.provider_id,agency.provider_id)
 left outer join src_provider parent on agency.parent_provider_id = parent.provider_id;

insert into hsds_program(
  id,
  organization_id,
  name,
  alternate_name
)
select distinct program_id,
       organization_id,
       name,
       alternate_name        
from tmp_program;       