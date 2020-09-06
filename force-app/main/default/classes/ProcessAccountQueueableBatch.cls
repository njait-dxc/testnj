/**
 * @author
 * @date
 * @description ProcessAccountQueueableBatch
 */

public class ProcessAccountQueueableBatch implements Queueable
{
	List <Account> accounts;
	Map <Id, Account> oldMap;

	public ProcessAccountQueueableBatch(List <Account> accounts, Map <Id, Account> oldMap)
	{
		this.accounts = accounts;
		this.oldMap = oldMap;
	}

	public void execute(QueueableContext context)
	{
		List <Id> partnerManagerAccountIds = new List <Id>();
		List <Id> clientManagerAccountIds = new List <Id>();
		List <AccountTeamMember> partnerManagerAccountTeamMembersToInsert = new List <AccountTeamMember>();
		List <AccountTeamMember> clientManagerAccountTeamMembersToInsert = new List <AccountTeamMember>();
		Map <Id, String> clientMangerMap = new Map <Id, String>();
		Map <String, User> federatedUserMap = getFederatedUserMap();

		for (Account account : accounts)
		{
			if (account.OwnerId != oldMap.get(account.Id).OwnerId)
			{
				partnerManagerAccountIds.add(account.Id);

				AccountTeamMember accountTeamMember = new AccountTeamMember();
				accountTeamMember.AccountAccessLevel = 'Edit';
				accountTeamMember.AccountId = account.Id;
				accountTeamMember.CaseAccessLevel = 'Edit';
				accountTeamMember.ContactAccessLevel = 'Edit';
				accountTeamMember.OpportunityAccessLevel = 'Edit';
				accountTeamMember.TeamMemberRole = 'Partner Manager';
				accountTeamMember.UserId = account.OwnerId;
				partnerManagerAccountTeamMembersToInsert.add(accountTeamMember);
			}

			if (account.Client_Manager__c != oldMap.get(account.Id).Client_Manager__c)
			{
				clientManagerAccountIds.add(account.Id);

				if (account.Client_Manager__c != null)
				{
					clientMangerMap.put(account.Id, account.Client_Manager__c.toUpperCase());

					AccountTeamMember accountTeamMember = new AccountTeamMember();
					accountTeamMember.AccountAccessLevel = 'Edit';
					accountTeamMember.AccountId = account.Id;
					accountTeamMember.CaseAccessLevel = 'Edit';
					accountTeamMember.ContactAccessLevel = 'Edit';
					accountTeamMember.OpportunityAccessLevel = 'Edit';
					accountTeamMember.TeamMemberRole = 'Client Manager';

					if (federatedUserMap.containsKey(account.Client_Manager__c.toUpperCase()))
					{
						accountTeamMember.UserId = federatedUserMap.get(account.Client_Manager__c.toUpperCase()).Id;
					}
					else
					{
						accountTeamMember.UserId = account.OwnerId;
					}

					clientManagerAccountTeamMembersToInsert.add(accountTeamMember);
				}
				else
				{
					account.Client_Manager_New__c = null;
				}
			}
		}

		// Process deletion of AccountTeamMember records
		List <AccountTeamMember> partnerManagerAccountTeamMembersToDelete = [SELECT Id, TeamMemberRole, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :partnerManagerAccountIds AND TeamMemberRole = 'Partner Manager'];
		List <AccountTeamMember> clientManagerAccountTeamMembersToDelete = [SELECT Id, TeamMemberRole, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :clientManagerAccountIds AND TeamMemberRole = 'Client Manager'];
		List <AccountTeamMember> accountTeamMembersToDelete = new List <AccountTeamMember>();
		accountTeamMembersToDelete.addAll(partnerManagerAccountTeamMembersToDelete);
		accountTeamMembersToDelete.addAll(clientManagerAccountTeamMembersToDelete);

		if (accountTeamMembersToDelete.isEmpty() == false)
		{
			try
			{
				Database.delete(accountTeamMembersToDelete, true);
			}
			catch (Exception exceptionObject)
			{
				LogUtilityException.throwException('ProcessAccountQueueableBatch', 'execute', exceptionObject, accountTeamMembersToDelete);
			}
			accountTeamMembersToDelete = null;
		}
		
		// Process insertion of AccountTeamMember records
		List <AccountTeamMember> accountTeamMembersToInsert = new List <AccountTeamMember>();
		accountTeamMembersToInsert.addAll(clientManagerAccountTeamMembersToInsert);
		accountTeamMembersToInsert.addAll(partnerManagerAccountTeamMembersToInsert);

		if (accountTeamMembersToInsert.isEmpty() == false)
		{
			try
			{
				Database.insert(accountTeamMembersToInsert, true);
			}
			catch (Exception exceptionObject)
			{
				LogUtilityException.throwException('ProcessAccountQueueableBatch', 'execute', exceptionObject, accountTeamMembersToInsert);
			}
		}
	}

	private static Map <String, User> getFederatedUserMap()
	{
		Map<String, User> userMap = new Map<String, User>();

		for (User user : [SELECT Id, FederationIdentifier FROM User WHERE IsActive = TRUE AND FederationIdentifier != NULL])
		{
			userMap.put(user.FederationIdentifier.toUpperCase(), user);
		}

		return userMap;
	}
}