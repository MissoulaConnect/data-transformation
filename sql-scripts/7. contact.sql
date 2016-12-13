--Field Name 	    Type (Format) 	Description 	                                                Required? 	Unique?
--id 	            string 	        Each contact must have a unique identifier 	                    False 	    False
--organization_id 	string 	        The identifier of the organization for which this is a contact 	False 	    False
--service_id 	    string 	        The identifier of the service for which this is a contact 	    False 	    False
--name 	            string 	        The name of the person 	                                        False 	    False
--title 	        string 	        The job title of the person 	                                False 	    False
--department 	    string 	        The department that the person is part of 	                    False 	    False
--email 	        string 	        The email address of the person 	                            False 	    False

-- Enable use of foreign keys
PRAGMA foreign_keys = ON;

create table hsds_contact(
  id INTEGER PRIMARY KEY,
  organization_id INT,
  service_id INT,
  name TEXT,
  title TEXT,
  department TEXT,
  email TEXT,
  FOREIGN KEY (organization_id) references hsds_organization(id) ON DELETE CASCADE  
);

insert into hsds_contact(
  id,
  organization_id,
  service_id,
  name,
  title,
  department ,
  email)
select tp.program_id as id,
		tp.organization_id,
		null as service_id,
		sp.contact_name as name,
		sp.contact_title as title,
		null as department,
		sp.contact_email as email
from src_provider sp
inner join tmp_program tp on sp.provider_id = tp.agency_id
where sp.contact_name is not null;
