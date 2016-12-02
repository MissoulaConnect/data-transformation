--Field Name 	    Type (Format) 	Description 	                                                Required? 	Unique?
--id 	            string 	        Each contact must have a unique identifier 	                    False 	    False
--organization_id 	string 	        The identifier of the organization for which this is a contact 	False 	    False
--service_id 	    string 	        The identifier of the service for which this is a contact 	    False 	    False
--name 	            string 	        The name of the person 	                                        False 	    False
--title 	        string 	        The job title of the person 	                                False 	    False
--department 	    string 	        The department that the person is part of 	                    False 	    False
--email 	        string 	        The email address of the person 	                            False 	    False

create table hsds_contact(
  id INTEGER PRIMARY KEY,
  organization_id INT,
  service_id INT,
  name TEXT,
  title TEXT,
  department TEXT,
  email TEXT
);

insert into hsds_contact(
  id,
  organization_id,
  service_id,
  name,
  title,
  department ,
  email)
select sp.provider_id + 1 as id,
		coalesce(sp.parent_provider_id, sp.provider_id) + 1 as organization_id,
		null as service_id,
		sp.contact_name as name,
		sp.contact_title as title,
		null as department,
		sp.contact_email as email
from src_provider sp
where sp.contact_name is not null and ltrim(rtrim(sp.contact_name)) > '';