--Field Name 	    Type (Format) 	Description 	                                            Required? 	Unique?
--id 	            string 	        Each program must have a unique identifier. 	            True 	    True
--organization_id 	string (uuid) 	Each program must belong to a single organization. 
--                                  The identifier of the organization should be given here. 	True 	    False
--name 	            string 	        The name of the program 	                                True 	    False
--alternate_name 	string 	        An alternative name for the program 	                    False 	    False

create table hsds_program(
  id INT,
  organization_id INT,
  name TEXT,
  alternate_name TEXT
);

insert into hsds_program(
  id,
  organization_id,
  name,
  alternate_name
)
select agency.provider_id +1,
		coalesce(parent.provider_id,agency.provider_id) + 1 as organization_id,  -- Parent ID
		agency.provider_name, 
		agency.provider_aka
 from src_provider as [agency]
 left outer join src_provider as [parent] on agency.parent_provider_id = parent.provider_id;