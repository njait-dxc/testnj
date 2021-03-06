//TODO:This autogenerated class includes the basics for a Registration
//Handler class. You will need to customize it to ensure it meets your needs and
//the data provided by the third party.

global class AutocreatedRegHandler1481026076263 implements Auth.RegistrationHandler
{
/*global boolean canCreateUser(Auth.UserData data) {
    //TODO: Check whether we want to allow creation of a user with this data
    //Set<String> s = new Set<String>{'usernamea', 'usernameb', 'usernamec'};
    if(data.identifier!=null) {
        return true;
    }
    return false;
}*/

	global User createUser(Id portalId, Auth.UserData data)
	{
		//System.debug('Create = ' + data);

		String dataUniqueVal = data.attributeMap.get('username');

		//Check if Username is found in any Contact  Email Address
		List<Contact> listOfContact = [SELECT Id,LastName,Email FROM Contact WHERE Is_User_Active__c = TRUE AND Email = :dataUniqueVal];
		//If Found{
		if (listOfContact.size() == 1)
		{
			Contact resultantContact = listOfContact[0];
			//If already Linked{
			List<User> usr = [
					SELECT Id, Username
					FROM User
					WHERE IsPortalEnabled = TRUE AND IsActive = TRUE AND
					ContactId = :resultantContact.Id
			];
			if (usr.size() == 1)
			{
				//System.debug('Matching User found with Id = ' + usr[0].Id + ' and Username = ' + usr[0].Username);
				return usr[0];
			}
			else if (usr.size() > 1)
			{
				System.debug('Expected 1 Matching Contact found ' + usr.size());
				return null;
			}
			else
			{
				return null;
				//Create User
				/*User newUser = new User(Username=dataUniqueVal,IsActive=true,profileId=partnerComProfile.Id);
				newUser.ContactId=resultantContact.id;
				newUser.LastName=resultantContact.LastName;
				newUser.Email=resultantContact.Email;
				newUser.Alias=resultantContact.LastName;
				newUser.EmailEncodingKey='ISO-8859-1';
				newUser.LanguageLocaleKey='en_US';
				newUser.LocaleSidKey='en_AU';
				newUser.TimeZoneSidKey='Australia/Sydney';
				try{
					Database.DMLOptions dlo = new Database.DMLOptions();
					dlo.EmailHeader.triggerUserEmail= false;
					//Database.saveresult sr = Database.insert(newUser,dlo);
					//insert newUser;
					System.debug('Created a new User with Id = '+newUser.Id+' and Username = '+newUser.username);
					return newUser;
				}catch(Exception e){
					System.debug('Exception While Provisioning User ='+e.getMessage());
					return null;
				}*/
			}
		}
		else
		{
			System.debug('Expected 1 Matching Contact found ' + listOfContact.size());
			return null;
		}
	}

	global void updateUser(Id userId, Id portalId, Auth.UserData data)
	{
		System.debug('Update ' + data);
	}
}