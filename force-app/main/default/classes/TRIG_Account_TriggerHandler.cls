/**
 * @author
 * @date
 * @description Account - Trigger Handler
 */

public with sharing class TRIG_Account_TriggerHandler extends TriggerHandler
{
	public override void beforeInsert()
	{
		autoPopulateBillingAddress((List <Account>) Trigger.new);
		associateParent((List <Account>) Trigger.new, 'beforeInsert');
		processAccount_BeforeInsert((List <Account>) Trigger.new);
	}

	public override void beforeUpdate()
	{
		autoPopulateBillingAddress((List <Account>) Trigger.new);
		associateParent((List <Account>) Trigger.new, 'beforeUpdate');
		processAccount_BeforeUpdate((List <Account>) Trigger.new, (Map <Id, Account>) Trigger.oldMap);
        /*if(!UtilityClass_MYOB.isAsync()){
		System.enqueueJob(new ProcessAccountQueueableBatch((List <Account>) Trigger.new, (Map <Id, Account>) Trigger.oldMap));
        }*/
	}

	public override void afterInsert()
	{
		processAccount_AfterInsert((Set <Id>) Trigger.newMap.keySet());
	}

	public override void afterUpdate()
	{
        String jsonNewMap = JSON.serialize(Trigger.newMap);
        String jsonOldMap = JSON.serialize(Trigger.oldMap);
		if(!UtilityClass_MYOB.isAsync()) {
		      processAccount_AfterUpdate((Set <Id>) Trigger.newMap.keySet(), jsonNewMap, jsonOldMap);
        }
	}
    
	public static void autoPopulateBillingAddress(List <Account> accounts)
	{
		for (Account account : accounts)
		{
			if (account.Copy_Head_Office_Address_to_Billing__c == true)
			{
				if (account.Head_Office_Coutnry__c != null)
				{
					account.Billing_Country_new__c = account.Head_Office_Coutnry__c;
				}
				if (account.Head_Office_Street__c != null)
				{
					account.Billing_Street_new__c = account.Head_Office_Street__c;
				}
				if (account.Head_Office_City__c != null)
				{
					account.Billing_City_new__c = account.Head_Office_City__c;
				}
				if (account.Head_Office_State__c != null)
				{
					account.Billing_State_new__c = account.Head_Office_State__c;
				}
				if (account.Head_Office_Zip_Postal_Code__c != null)
				{
					account.Billing_Zip_new__c = account.Head_Office_Zip_Postal_Code__c;
				}
			}
		}
	}

	public static void associateParent(List <Account> accounts, String triggerContext)
	{
		Set <String> parentClientIds = new Set <String>();
		Map <String, String> clientIdMap = new Map <String, String>();

		// Get a list of all the external Id's for the partners
		for (Account account : accounts)
		{
			if (account.LP_Parent_Archie_Client_Id__c != null)
			{
				parentClientIds.add(account.LP_Parent_Archie_Client_Id__c);
			}
		}

		// Map the external Id's to their Salesforce Id's
		for (Account account : [SELECT Id, Client_ID__c FROM Account WHERE Client_ID__c IN :parentClientIds])
		{
			clientIdMap.put(account.Client_ID__c, account.Id);
		}

		try
		{
			for (Account account : accounts)
			{
				if (account.LP_Parent_Archie_Client_Id__c != null)
				{
					// If a parent has already been created in Salesforce then the Map will contain
					// the Id and associate with the same. In case a child which had a parent is updated
					// to another parent partner and the respective partner already exists in Salesforce
					// mapping will happen. If the updated parent does not exist in Salesforce then we
					// set is as NULL so that the scheduled job can identify the same and try to associate.
					if (clientIdMap.containsKey(account.LP_Parent_Archie_Client_Id__c))
					{
						account.ParentId = clientIdMap.get(account.LP_Parent_Archie_Client_Id__c);
						account.LP_Acc_Related_List__c = clientIdMap.get(account.LP_Parent_Archie_Client_Id__c);
					}
					else
					{
						account.ParentId = null;
						account.LP_Acc_Related_List__c = null;
					}
				}
				else
				{
					// If the parent partner associated is removed then clear it
					account.ParentId = null;
					account.LP_Acc_Related_List__c = null;
				}
			}
		}
		catch (Exception exceptionObject)
		{
			LP_ErrorLogHandler.log('Parent partner association failed on ' + triggerContext, String.valueOf(exceptionObject), 'LP_PartnerTriggerHandler');
		}
	}

	public static void processAccount_BeforeInsert(List <Account> accounts)
	{
		Map <String, User> federatedUserMap = getFederatedUserMap();

		List <Support_Setting__mdt> supportSettings = [SELECT Id, DeveloperName, Value__c FROM Support_Setting__mdt WHERE DeveloperName = 'TWS_Sync_Mode' OR DeveloperName = 'TWS_User'];

		String twoWaySyncMode = null;
		String twoWaySyncUser = null;

		for (Support_Setting__mdt supportSetting : supportSettings)
		{
			switch on supportSetting.DeveloperName
			{
				when 'TWS_Sync_Mode'
				{
					twoWaySyncMode = supportSetting.Value__c;
				}
				when 'TWS_User'
				{
					twoWaySyncUser = supportSetting.Value__c;
				}
			}
		}

		for (Account account : accounts)
		{
			if (account.Client_Manager__c != null)
			{
				if (federatedUserMap.containsKey(account.Client_Manager__c.toUpperCase()))
				{
					String clientManagerId = federatedUserMap.get(account.Client_Manager__c.toUpperCase()).Id;
					account.Client_Manager_New__c = clientManagerId;
				}
			}

			account.Legal_Entity_Picklist__c = account.Legal_Entity__c;

			if ((twoWaySyncMode == 'Subset With New' || twoWaySyncMode == 'All') && System.UserInfo.getUserId() != twoWaySyncUser)
			{
				account.Sync_Status__c = 'Pending';
			}
		}
	}

	private static Map <String, User> getFederatedUserMap()
	{
		Map <String, User> userMap = new Map<String, User>();

		for (User userRecord : [SELECT Id, FirstName, LastName, FederationIdentifier, Email FROM User WHERE IsActive = TRUE AND FederationIdentifier != NULL])
		{
			userMap.put(userRecord.FederationIdentifier.toUpperCase(), userRecord);
		}

		return userMap;
	}

	@Future
	public static void processAccount_AfterInsert(Set <Id> accountIds)
	{
		List <Account> accounts = [SELECT Id, OwnerId, Client_Manager_New__c FROM Account WHERE Id IN :accountIds];
		List <AccountTeamMember> accountTeamMembers = new List <AccountTeamMember>();
		Map <String, AccountTeamMember> partnerManagerMap = new Map <String, AccountTeamMember>();

		for (Account account : accounts)
		{
			String partnerManagerKey = '' + account.Id + account.OwnerId;

			AccountTeamMember accountTeamMember = new AccountTeamMember();
			accountTeamMember.AccountAccessLevel = 'Edit';
			accountTeamMember.AccountId = account.Id;
			accountTeamMember.CaseAccessLevel = 'Edit';
			accountTeamMember.ContactAccessLevel = 'Edit';
			accountTeamMember.OpportunityAccessLevel = 'Edit';

			/*if (partnerManagerMap.containsKey(partnerManagerKey) == false)
			{
				AccountTeamMember vPMMember = accountTeamMember.clone(false, true, false, false);
				vPMMember.TeamMemberRole = 'Partner Manager';
				vPMMember.UserId = account.OwnerId;
				partnerManagerMap.put(partnerManagerKey, vPMMember);
				accountTeamMembers.add(vPMMember);
			}*/

			if (account.Client_Manager_New__c != null)
			{
				accountTeamMember.TeamMemberRole = 'Client Manager';
				accountTeamMember.UserId = account.Client_Manager_New__c;
				accountTeamMembers.add(accountTeamMember);
			}
		}

		if (accountTeamMembers.isEmpty() == false)
		{
			try
			{
				Database.upsert(accountTeamMembers, true);
			}
			catch (Exception exceptionObject)
			{
				LogUtilityException.throwException('TRIG_Account_TriggerHandler', 'processAccount_AfterInsert', exceptionObject, accountTeamMembers);
			}
		}
	}

	public static void processAccount_BeforeUpdate(List <Account> accounts, Map <Id, Account> oldMap)
	{
		List <Support_Setting__mdt> supportSettings = [SELECT Id, DeveloperName, Value__c FROM Support_Setting__mdt WHERE DeveloperName = 'TWS_Sync_Mode' OR DeveloperName = 'TWS_User'];
		Map <String, User> federatedUserMap = getFederatedUserMap();
		String twoWaySyncMode = null;
		String twoWaySyncUser = null;

		for (Support_Setting__mdt supportSetting : supportSettings)
		{
			switch on supportSetting.DeveloperName
			{
				when 'TWS_Sync_Mode'
				{
					twoWaySyncMode = supportSetting.Value__c;
				}
				when 'TWS_User'
				{
					twoWaySyncUser = supportSetting.Value__c;
				}
			}
		}

		for (Account account : accounts)
		{
			Account accountOld = oldMap.get(account.Id);
            

			if (System.UserInfo.getUserId() != twoWaySyncUser)
			{
				if (twoWaySyncMode == 'All' || (twoWaySyncMode == 'Subset With New' && account.Subset_Sync__c == true) || (twoWaySyncMode == 'Subset With Existing Only') && account.Subset_Sync__c == true)
				{
					if (account.Name != accountOld.Name ||
							account.Status__c != accountOld.Status__c ||
							account.Commission_Option__c != accountOld.Commission_Option__c ||
							account.Trading_Name__c != accountOld.Trading_Name__c ||
							account.Website != accountOld.Website ||
							account.ABN__c != accountOld.ABN__c ||
							account.Total_Employees__c != accountOld.Total_Employees__c ||
							account.At_Risk__c != accountOld.At_Risk__c ||
							account.OwnerId != accountOld.OwnerId ||
							account.Client_Manager__c != accountOld.Client_Manager__c ||
							account.Client_Manager_New__c != accountOld.Client_Manager_New__c
							)
					{
						account.Sync_Status__c = 'Pending';
					}
				}
			}

			if (account.IsPartner != accountOld.IsPartner && account.IsPartner == true)
			{
				account.IsCommunity__c = true;
			}

			if (account.IsPartner != accountOld.IsPartner && account.IsPartner == false)
			{
				account.IsCommunity__c = false;
			}

			if (account.Legal_Entity__c != accountOld.Legal_Entity_Picklist__c)
			{
				account.Legal_Entity_Picklist__c = account.Legal_Entity__c;
			}
            
            if(account.Client_Manager__c != accountOld.Client_Manager__c)
            {
                if (account.Client_Manager__c != null)
                {
                    if (federatedUserMap.containsKey(account.Client_Manager__c.toUpperCase()))
                    {
                        String clientManagerId = federatedUserMap.get(account.Client_Manager__c.toUpperCase()).Id;
                        account.Client_Manager_New__c = clientManagerId;
                    }
                }                
            }
            
            if(account.Client_Manager__c == null)
            {
                account.Client_Manager_New__c = null;
            }
		}
	}
    
	@Future
	public static void processAccount_AfterUpdate(Set <Id> accountIds, String strnewMap, String stroldMap)
	{
        map<id, Account> oldMap = (Map<id, Account>) JSON.deserialize(stroldMap, map<id, Account>.class);
        map<id, Account> newMap = (Map<id, Account>) JSON.deserialize(strnewMap, map<id, Account>.class);
        List <AccountTeamMember> accountTeamMembersToAdd = new List <AccountTeamMember>();
        List <AccountTeamMember> accountTeamMembersToDelete = new List <AccountTeamMember>();
        map<id, Account> oldMapConverted = New map<id, Account>();
        map<id, Account> newMapConverted = New map<id, Account>();
        AccountTeamMember newAccountTeamMember;
        //Account tempAccount = New Account();
            
        List <AccountTeamMember> existingAccountTeamMember = [SELECT Id, AccountId, TeamMemberRole, UserId FROM AccountTeamMember WHERE AccountId IN :accountIds AND TeamMemberRole ='Client Manager'];
        
        for(Account tempAccount1 : oldMap.values())
        {
            if(tempAccount1 != null)
            {
                oldMapConverted.put(tempAccount1.Id, tempAccount1);
            }            
        }
        for(Account tempAccount2 : newMap.values())
        {
            if(tempAccount2 != null)
            {
            	newMapConverted.put(tempAccount2.Id, tempAccount2);
            }
        }
        
        for(Account tempAccount : newMapConverted.values())
        {
            if(tempAccount.Client_Manager__c !=  oldMapConverted.get(tempAccount.Id).Client_Manager__c)
            {

                for(AccountTeamMember tempATM : existingAccountTeamMember)
                {
                    if(tempATM.AccountId == tempAccount.Id)
                    {
                        accountTeamMembersToDelete.add(tempATM);                        
                    }
                }
                
                if(tempAccount.Client_Manager__c != null && tempAccount.Client_Manager_New__c != null)
                {
                    newAccountTeamMember = new AccountTeamMember();
                    newAccountTeamMember.AccountAccessLevel = 'Edit';
                    newAccountTeamMember.AccountId = tempAccount.Id;
                    newAccountTeamMember.CaseAccessLevel = 'Edit';
                    newAccountTeamMember.ContactAccessLevel = 'Edit';
                    newAccountTeamMember.OpportunityAccessLevel = 'Edit';                    
                    newAccountTeamMember.TeamMemberRole = 'Client Manager';
                    newAccountTeamMember.UserId = tempAccount.Client_Manager_New__c;
                    accountTeamMembersToAdd.add(newAccountTeamMember);
                }
            }
        }

		System.debug('List Size'+accountTeamMembersToDelete.size());
        if(accountTeamMembersToDelete.size()>0)
        {
            try
            {
				System.debug('Records To Delete'+accountTeamMembersToDelete);
            	delete accountTeamMembersToDelete;
            }
			catch (Exception exceptionObject)
			{
				LogUtilityException.throwException('TRIG_Account_TriggerHandler', 'processAccount_AfterUpdate', exceptionObject, accountTeamMembersToDelete);
			}
        }
		System.debug('List Size For Add'+accountTeamMembersToAdd.size());
        if(accountTeamMembersToAdd.size()>0)
        {
            try
            {    
            	insert accountTeamMembersToAdd;
            }
			catch (Exception exceptionObject)
			{
				LogUtilityException.throwException('TRIG_Account_TriggerHandler', 'processAccount_AfterUpdate', exceptionObject, accountTeamMembersToAdd);
			}
        }
    }
}