/**
 * @author
 * @date
 * @description
 */

global without sharing class DeleteInactiveContacts implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		List<Contact> contactToDelete = [SELECT Id FROM Contact WHERE Active_Contact__c = FALSE];
		if (!contactToDelete.isEmpty())
		{
			//delete contactToDelete;
			List<Database.DeleteResult> dbResultList = new List<Database.DeleteResult>();
			try
			{
				dbResultList = Database.delete(contactToDelete, true);
			} catch (Exception e)
			{
				LogUtilityException.throwException('DeleteInactiveContacts', 'execute', e, contactToDelete);
			}
			for (Database.DeleteResult dr : dbResultList)
			{
				if (dr.isSuccess())
				{
					System.debug('Successfully deleted contact with ID: ' + dr.getId());
				}
				else
				{
					for (Database.Error err : dr.getErrors())
					{
						System.debug('The following error has occurred.');
						System.debug(err.getStatusCode() + ': ' + err.getMessage());
					}
				}
			}
		}

	}
}