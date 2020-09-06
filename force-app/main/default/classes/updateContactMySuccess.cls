global class updateContactMySuccess{

   @InvocableMethod
   public static void updateContact(List<Id> contactId) {

      //List<Contact> contacts = [select Id, My_Success_Access__c from Contact WHERE Id in :contactId];
      User newCommunitiesUser = new User();
          
       List<Contact> contacts = [SELECT FirstName,LastName,Email,AccountId,PartnerCommunityUser__c FROM Contact WHERE Id IN :contactId];
      for (Contact objectContact: contacts) {

  
        //Create user 
          newCommunitiesUser = new User(ContactId=objectContact.Id,
                          Username=objectContact.Email,
                          FirstName=objectContact.FirstName,
                          LastName=objectContact.LastName,
                          Email=objectContact.Email,
                          CommunityNickname = objectContact.LastName + '_'+Math.random(),
                          Alias = String.valueOf(objectContact.FirstName.substring(0,1) +
                                  objectContact.LastName.substring(0,1) + Math.random() ).substring(0,5), 
                          ProfileId = '00e28000001sYmQ',
                          EmailEncodingKey='UTF-8',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_AU',
                          TimeZoneSidKey='Australia/Sydney');
      //insert newCommunitiesUser;
      
     


         try
         {
            /*Database.SaveResult insertCommunitiesUserResult = */Database.insert(newCommunitiesUser , true);
         }
         catch(Exception e)
         {
            LogUtilityException.throwException('updateContactMySuccess', 'updateContact', e, new List<User>{newCommunitiesUser});
         } 
      }
      
        for (Contact objectContact: contacts) {
            objectContact.PartnerCommunityUser__c  = newCommunitiesUser.Id;
        }
         try
         {
            Database.update(contacts, true);
         }
         catch(Exception e)
         {
            LogUtilityException.throwException('updateContactMySuccess', 'updateContact', e, contacts);
         } 

      }
}