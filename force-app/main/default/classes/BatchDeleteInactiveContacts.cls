/**
 * @author
 * @date
 * @description
 */

public without sharing class BatchDeleteInactiveContacts implements Database.Batchable<SObject>{

	/**
	 * @param bc
	 * @return
	 * @description
	 */
	public Database.QueryLocator start (Database.BatchableContext bc) {
		Id vPGContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('PayGlobal Contacts').getRecordTypeId();
		return Database.getQueryLocator('Select Id FROM Contact WHERE Active_Contact__c = false and RecordtypeId !=:vPGContactRecordTypeId');
	}

	/**
	 * @description
	 * @param bc
	 * @param scope
	 */

	public void execute (Database.BatchableContext bc, List<SObject> scope) {
		//List<Contact> contactToDelete  = new List<Contact>();
		if(!scope.isEmpty()){
			//delete contactToDelete;
			List<Database.DeleteResult> dbResultList = new List<Database.DeleteResult>();

			dbResultList = Database.delete(scope, false);

			LogUtilityException.logSaveResults('BatchDeleteInactiveContacts','execute',scope,dbResultList);

			for(Database.DeleteResult dr : dbResultList)
			{
				if(!dr.isSuccess())
				{
					for(Database.Error err : dr.getErrors()) {
						System.debug('The following error has occurred.');
						System.debug(err.getStatusCode() + ': ' + err.getMessage());
					}
				}
				/*    if (dr.isSuccess()) {
						//System.debug('Successfully deleted contact with ID: ' + dr.getId());
					}
					else {
						for(Database.Error err : dr.getErrors()) {
							System.debug('The following error has occurred.');
							System.debug(err.getStatusCode() + ': ' + err.getMessage());
						}
					} */
			}
			//Database.emptyRecycleBin(scope);
		}
	}

	/**
	 * @description
	 * @param bc
	 */
	public void finish(Database.BatchableContext bc){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		// Below code will fetch the job Id
		AsyncApexJob a = [SELECT a.TotalJobItems, a.Status, a.NumberOfErrors,
				a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById,
				a.CompletedDate FROM AsyncApexJob a WHERE Id = :bc.getJobId()];
		// get the job Id
		System.debug('$$$ Jobid is'+bc.getJobId());

		// below code will send an email to User about the status
		String[] toaddress = new String[] {'rui.wang@myob.com'};
		mail.setToAddresses(toaddress);
		mail.setReplyTo('rui.wang@myob.com');
		mail.setSenderDisplayName('Apex Batch Deleting Inactive Contacts');
		mail.setSubject('Batch Processing '+a.Status);
		mail.setPlainTextBody('The Batch Apex job processed '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures'+' Job Item processed are'+a.JobItemsProcessed);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
	}
}