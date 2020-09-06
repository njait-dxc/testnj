/**
 * @author alexvolkov
 * @date 22/11/19
 * @description 
 */
@IsTest
public with sharing class TEST_RegistrationHandler
{
    @TestSetup
    static void setupData()
    {
        User vCurrUser = [
                SELECT Id, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, TimeZoneSidKey, ProfileId
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];
        Id vUsrRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1].Id;
        User vAdminUsr = (User) TestDataFactory.createSObject(new User(UserRoleId = vUsrRoleId, Alias = 'uniqtst1', Email = 'admintestuser@invalid.com', ProfileId = vCurrUser.ProfileId, Username = 'admintestuser@invalid.com'), true);
        System.runAs(vAdminUsr)
        {
            Account vAcc = (Account) TestDataFactory.createSObject(new Account(), true);
            Contact vCont = (Contact) TestDataFactory.createSObject(new Contact(Email = 'testuser@invalid.com', AccountId = vAcc.Id, Is_User_Active__c = true), true);
            Id vProfId = [SELECT Id FROM Profile WHERE Name = :Constants.MYSUCCESS_LOGIN_PROFILE].Id;
            TestDataFactory.createSObject(new User (IsActive = true, ProfileId = vProfId, Username = 'testuser_84938759@invalid.com', Email = 'testuser@invalid.com', Alias = 'uniqtst2',
                                                    ContactId = vCont.Id, CommunityNickname = 'testuser12345' + Datetime.now().getTime()), true);
        }
    }

    private static Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@invalid.com', null, 'testuser_84938759@invalid.com', 'en_US', 'testProvider',
            null, new Map<String, String>
            {
                    'sfdc_networkid' => 'testCommunity',
                    'username' => 'testuser@invalid.com'
            });


    static testMethod void testCreateUserPositive()
    {
        AutocreatedRegHandler1481026076263 brHandler = new AutocreatedRegHandler1481026076263();
        Test.startTest();
        System.assertEquals(sampleData.username, brHandler.createUser(null, sampleData).Username, 'createUser failed');
        Test.stopTest();
    }

    static testMethod void testUpdateUser()
    {
        AutocreatedRegHandler1481026076263 brHandler = new AutocreatedRegHandler1481026076263();
        User vUser = [SELECT Id, FederationIdentifier FROM User WHERE IsActive = TRUE AND Email LIKE '%@invalid.com' LIMIT 1];
        brHandler.updateUser(vUser.Id, null, sampleData);
    }

    static testMethod void testCreateUserNegative()
    {
        AutocreatedRegHandler1481026076263 brHandler = new AutocreatedRegHandler1481026076263();
        sampleData.attributeMap.put('username', 'non-existent@invalid.com');
        Test.startTest();
        System.assertEquals(null, brHandler.createUser(null, sampleData));
        Test.stopTest();
    }
}