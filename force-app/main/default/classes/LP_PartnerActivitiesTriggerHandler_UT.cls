/*
    Date            : 27-10-2016
    Author          : SMS Management & Technology
    Description     : Unit test class for LP_PartnerActivitiesTriggerHandler
*/
@IsTest
public with sharing class LP_PartnerActivitiesTriggerHandler_UT {
    
    // Test insertion of activities
    public static testMethod void testActivityInsertion() {
        // Create a partner 
        Account objPartner = LP_UnitTestFactory.buildTestPartner();
        insert objPartner;

        // List of activities 
        List<LP_Partner_Activities__c> lstActivities = new List<LP_Partner_Activities__c>();
        
        // Create an activity 1 for the partner 
        LP_Partner_Activities__c objActivities1 = LP_UnitTestFactory.buildTestActivities();
        objActivities1.LP_Activity_GUID__c = 'GUID-ID-1011'; // GUID has to be unique
        objActivities1.LP_Partner_GUID__c = objPartner.LP_Partner_GUID__c;
        objActivities1.LP_Partner_Archie_ID__c = objPartner.Client_ID__c;
        lstActivities.add(objActivities1);

        // Create an activity 2 for the partner
        LP_Partner_Activities__c objActivities2 = LP_UnitTestFactory.buildTestActivities();
        objActivities2.LP_Activity_GUID__c = 'GUID-ID-1012'; // GUID has to be unique
        objActivities2.LP_Partner_GUID__c = objPartner.LP_Partner_GUID__c;
        objActivities2.LP_Partner_Archie_ID__c = objPartner.Client_ID__c;
        lstActivities.add(objActivities2);

        insert lstActivities;
        
        //LP_PartnerActivitiesTriggerHandler.associatePartnerInsertion(lstActivities);
        //TRIG_LP_Partner_Activities_Handler.associatePartnerInsertion(lstActivities);
        TRIG_LP_Partner_Activities_Handler.partnerActivityInsert(lstActivities);
    }
    
    // Test insertion of activities when the partner is not yet 
    // created in Salesforce
    public static testMethod void testActivityPartnerNotFound() {
        // Create a partner 
        Account objPartner = LP_UnitTestFactory.buildTestPartner();
        insert objPartner;

        List<LP_Partner_Activities__c> lstActivities = new List<LP_Partner_Activities__c>();
        
        // Create an activity 1 for the partner 
        LP_Partner_Activities__c objActivities1 = LP_UnitTestFactory.buildTestActivities();
        objActivities1.LP_Activity_GUID__c = 'GUID-ID-1011'; // GUID has to be unique
        objActivities1.LP_Partner_GUID__c = 'Test1-GUID-001';
        objActivities1.LP_Partner_Archie_ID__c = 'Test-ARCH-001';
        objActivities1.LP_Partner_Name__c=objPartner.Id;
        lstActivities.add(objActivities1);

        // Create an activity 2 for the partner
        LP_Partner_Activities__c objActivities2 = LP_UnitTestFactory.buildTestActivities();
        objActivities2.LP_Activity_GUID__c = 'GUID-ID-1012'; // GUID has to be unique
        objActivities2.LP_Partner_Name__c=objPartner.Id;
        objActivities2.LP_Partner_GUID__c = objPartner.LP_Partner_GUID__c;
        objActivities2.LP_Partner_Archie_ID__c = objPartner.Client_ID__c;
        lstActivities.add(objActivities2);

        insert lstActivities;
        
        //LP_PartnerActivitiesTriggerHandler.associatePartnerInsertion(lstActivities);
        //TRIG_LP_Partner_Activities_Handler.associatePartnerInsertion(lstActivities);
        TRIG_LP_Partner_Activities_Handler.partnerActivityInsert(lstActivities);
    }
    
    // Testing activity updation
    public static testMethod void testActivityUpdate() {
        // Create a partner
        Account objPartner = LP_UnitTestFactory.buildTestPartner();
        insert objPartner;

        // List of activities 
        List<LP_Partner_Activities__c> lstActivities = new List<LP_Partner_Activities__c>();
        
        // Create an activity for the partner 
        LP_Partner_Activities__c objActivities1 = LP_UnitTestFactory.buildTestActivities();
        objActivities1.LP_Partner_GUID__c = objPartner.LP_Partner_GUID__c;
        objActivities1.LP_Partner_Archie_ID__c = objPartner.Client_ID__c;
        lstActivities.add(objActivities1);
        insert lstActivities;
        
        // Update the activity 
        objActivities1.LP_Partner_Archie_ID__c = 'Test-ARCH-001';
        update lstActivities;

        //LP_PartnerActivitiesTriggerHandler.associatePartnerInsertion(lstActivities);
        //TRIG_LP_Partner_Activities_Handler.associatePartnerInsertion(lstActivities);
        TRIG_LP_Partner_Activities_Handler.partnerActivityInsert(lstActivities);
    }
    
    // Testing if the activities delta flag is updated - this flag helps
    // determine which activities need to be sent to the service post point
    // calculation
    public static testMethod void testActivityDeltas() {
        // Create partner 1
        Account objPartner1 = LP_UnitTestFactory.buildTestPartner();
        objPartner1.Client_ID__c = 'ARCH-ID-1001';
        insert objPartner1;
        
        // List of activities 
        List<LP_Partner_Activities__c> lstActivities = new List<LP_Partner_Activities__c>();
        
        // Create an activity for the partner 
        LP_Partner_Activities__c objActivities1 = LP_UnitTestFactory.buildTestActivities();
        objActivities1.LP_Partner_GUID__c = objPartner1.LP_Partner_GUID__c;
        objActivities1.LP_Partner_Archie_ID__c = objPartner1.Client_ID__c;
        lstActivities.add(objActivities1);
        insert lstActivities;
        
        objActivities1.LP_Points__c = 10;
        update lstActivities;
    }
    
    // Test for change of partner on an activity
    public static testMethod void testActivityPartnerChange() {
        // Create partner 1
        Account objPartner1 = LP_UnitTestFactory.buildTestPartner();
        objPartner1.LP_Partner_GUID__c = 'GUID-ID-1001';
        objPartner1.Client_ID__c = 'ARCH-ID-1001';
        insert objPartner1;
        
        // Create partner 2
        Account objPartner2 = LP_UnitTestFactory.buildTestPartner();
        objPartner2.LP_Partner_GUID__c = 'GUID-ID-1002';
        objPartner2.Client_ID__c = 'ARCH-ID-1002';
        insert objPartner2;

        // List of activities 
        List<LP_Partner_Activities__c> lstActivities = new List<LP_Partner_Activities__c>();
        
        // Create an activity for the partner 
        LP_Partner_Activities__c objActivities1 = LP_UnitTestFactory.buildTestActivities();
        objActivities1.LP_Partner_GUID__c = objPartner1.LP_Partner_GUID__c;
        objActivities1.LP_Partner_Archie_ID__c = objPartner1.Client_ID__c;
        lstActivities.add(objActivities1);
        insert lstActivities;
        
        objActivities1.LP_Partner_Archie_ID__c = objPartner2.Client_ID__c;
        update lstActivities;
    }
    
    // Test for statement only activities the partner name should
    // not be associated until the activity expires
    public static testMethod void testActivityStatement() {
        // Create partner 1
        Account objPartner1 = LP_UnitTestFactory.buildTestPartner();
        objPartner1.LP_Partner_GUID__c = 'GUID-ID-1001';
        objPartner1.Client_ID__c = 'ARCH-ID-1001';
        insert objPartner1;
        
        // Create partner 2
        Account objPartner2 = LP_UnitTestFactory.buildTestPartner();
        objPartner2.LP_Partner_GUID__c = 'GUID-ID-1002';
        objPartner2.Client_ID__c = 'ARCH-ID-1002';
        insert objPartner2;

        // List of activities 
        List<LP_Partner_Activities__c> lstActivities = new List<LP_Partner_Activities__c>();
        
        // Create an activity for the partner 
        LP_Partner_Activities__c objActivities1 = LP_UnitTestFactory.buildTestActivities();
        objActivities1.LP_Partner_GUID__c = objPartner1.LP_Partner_GUID__c;
        objActivities1.LP_Partner_Archie_ID__c = objPartner1.Client_ID__c;
        objActivities1.LP_Statement_Only__c = true;
        Account associatedPartner = [SELECT Id FROM Account WHERE Id =:objPartner1.Id LIMIT 1];
        objActivities1.LP_Partner_Name__c=associatedPartner.Id;
        lstActivities.add(objActivities1);
        insert objActivities1;
        
        objActivities1.LP_Partner_Archie_ID__c = objPartner2.Client_ID__c;
        update lstActivities;
    }

}