/*
    Date        : 12 Nov 2016
    Author      : SMS Management & Technology
    Description : Unit test factory for building test data
*/
public without sharing class LP_UnitTestFactory
{
    // Build new partner
    public static Account buildTestPartner()
    {
        Account objAcc = new Account();

        objAcc.Name = 'Test Partner';
        objAcc.Client_ID__c = 'ARCH-ID-1001';
        objAcc.LP_Partner_GUID__c = 'GUID-ID-1001';
        objAcc.LP_Program_Agreement__c = 'Current';
        //objAcc.Legal_Entity__c = 'MYOB Australia Pty Ltd';

        return objAcc;
    }

    // Build new activities
    public static LP_Partner_Activities__c buildTestActivities()
    {
        LP_Partner_Activities__c objActivities = new LP_Partner_Activities__c();

        // The partner id can be associated in the calling class
        objActivities.Name = 'GUID-ID-1001';
        objActivities.LP_Activity__c = 'Certification Completed';
        objActivities.LP_Activity_GUID__c = 'GUID-ID-1001';
        objActivities.LP_Activity_Date__c = System.today();
        objActivities.LP_Activity_Quantity__c = 1;

        return objActivities;
    }

    // Create user
    public static User createUser()
    {
        Datetime dt = Datetime.now();

        User objUser = new User();
        objUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        objUser.EmailEncodingKey = 'ISO-8859-1';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.TimeZoneSidKey = 'America/New_York';
        objUser.LocaleSidKey = 'en_US';
        objUser.FirstName = 'firstUser';
        objUser.LastName = 'lastUser';
        objUser.Username = 'test' + dt.second() + '_' + dt.minute() + '_' + Math.random() + '@testmyob.com';
        objUser.Alias = 't1';

        objUser.Title = 't1';
        objUser.Phone = 't1';
        objUser.MobilePhone = 't1';
        objUser.Email = 'no@email.com';
        objUser.IsActive = true;

        return objUser;
    }

    // Create a tier
    public static LP_Tier__c createTier()
    {
        LP_Tier__c objTier = new LP_Tier__c();

        objTier.Name = 'Purple';
        objTier.LP_Minimum_Point__c = 0;
        objTier.LP_Maximum_Point__c = 29;
        objTier.LP_Tier_Start_Date__c = System.today();
        objTier.LP_Tier_End_Date__c = System.today();

        return objTier;
    }

    // Create a tier - Silver
    public static LP_Tier__c createTierSilver()
    {
        LP_Tier__c objTier = new LP_Tier__c();

        objTier.Name = 'Silver';
        objTier.LP_Minimum_Point__c = 30;
        objTier.LP_Maximum_Point__c = 119;
        objTier.LP_Tier_Start_Date__c = System.today();
        objTier.LP_Tier_End_Date__c = System.today();

        return objTier;
    }

}