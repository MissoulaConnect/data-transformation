--Field Name 	    Type (Format) 	Description 	                                            Required? 	Unique?
--id 	            string 	        Each program must have a unique identifier. 	            True 	True
--organization_id 	string (uuid) 	Each program must belong to a single organization. 
--                                  The identifier of the organization should be given here. 	True 	False
--name 	            string 	        The name of the program 	                                True 	False
--alternate_name 	string 	        An alternative name for the program 	                    False 	False

select agency.provider_id as id,
		coalesce(parent.provider_id,agency.provider_id) as organization_id,
		agency.provider_name as name,
		agency.provider_aka as alternate_name
 from src_provider as [agency]
 left join src_provider as [parent] on agency.parent_provider_id = parent.provider_id
