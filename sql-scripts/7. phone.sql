--Field Name 	    Type (Format) 	Description 	                                                        Required? 	Unique?
--id 	            string 	        Each entry must have a unique identifier 	                            False 	    False
--location_id 	    string 	        The identifier of the location where this phone number is located 	    False 	    False
--service_id 	    string 	        The identifier of the service for which this is the phone number 	    False 	    False
--organization_id 	string 	        The identifier of the organisation for which this is the phone number 	False 	    False
--contact_id 	    string 	        The identifier of the contact for which this is the phone number 	    False 	    False
--number 	        string 	        The phone number 	                                                    False 	    False
--extension 	    number 	        The extension of the phone number 	                                    False 	    False
--type 	            string 	        Whether the phone number relates to a fixed or cellular phone 	        False 	    False
--department 	    string 	        The department for which this is the phone number 	                    False 	    False

create table hsds_phone(
  id INTEGER PRIMARY KEY,
  location_id INT,
  service_id INT,
  organization_id INT,
  contact_id INT,
  number TEXT,
  extension INT,
  type TEXT,
  department TEXT
);

insert into hsds_phone(
  id,
  location_id,
  service_id,
  organization_id,
  contact_id,
  number,
  extension,
  type,
  department)
select sp.provider_id+1 as id, 
		sp.provider_id+1 as location_id,
		null as service_id,
		coalesce(sp.parent_provider_id, sp.provider_id) + 1 as organization_id,	
		 sp.provider_id+1 as contact_id,
		--ltrim(rtrim(coalesce(sp.contact_telephone_areacode,''))) || case when sp.contact_telephone_areacode is not null and sp.contact_phone is not null then '-' else '' end || ltrim(rtrim(coalesce(sp.contact_phone,''))) as  number, 
		sp.telephone_number,
		case when sp.contact_telephone_extension GLOB '*[0-9]*' then sp.contact_telephone_extension else null end as extension,
		case when coalesce(sp.contact_telephone_areacode,'') = '10' then 'cellular' else 'fixed' end as type,
		null as department
from   src_provider sp
where ltrim(rtrim(coalesce(sp.telephone_number,''))) > '' ;