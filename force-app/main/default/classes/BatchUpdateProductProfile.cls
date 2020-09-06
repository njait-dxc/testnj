/**
 * @author
 * @date
 * @description
 */

public class BatchUpdateProductProfile implements Database.Batchable<SObject>
{
	/**
	 * @description
	 * @param bc
	 * @return
	 */
	public Database.QueryLocator start (Database.BatchableContext bc) {
		return Database.getQueryLocator('Select Id, Name, Product_Set__c FROM Product_Profile__c WHERE Product_Set__c = null');
	}

	/**
	 * @description
	 * @param bc
	 * @param scope
	 */
	public void execute (Database.BatchableContext bc, List<Product_Profile__c> scope)
	{
		/**
		* Rewritten to minimise # of retrieved records
		*/

		Map<String, Set<Product_Profile__c>> vPPToUpdateMap = new Map<String, Set<Product_Profile__c>>();
		List<Product_Profile__c> vPPToUpdate = new List<Product_Profile__c>();

		for(Product_Profile__c pp:scope)
		{
			pp.Product_Set__c = 'Unknown';
			if (vPPToUpdateMap.containsKey(pp.Name))
			{
				vPPToUpdateMap.get(pp.Name).add(pp);
			}
			else
			{
				vPPToUpdateMap.put(pp.Name, new Set<Product_Profile__c>{pp});
			}
		}

		for (Product_Profile_Product_Set__c pps : [SELECT Product_Profile_Name__c, Product_Set__c FROM Product_Profile_Product_Set__c WHERE Product_Profile_Name__c IN :vPPToUpdateMap.keySet()])
		{

			if (pps.Product_Profile_Name__c != null)
			{
				for (Product_Profile__c pp: vPPToUpdateMap.get(pps.Product_Profile_Name__c))
				{
					pp.Product_Set__c = pps.Product_Set__c;
				}
			}
		}

		for (Set<Product_Profile__c> ppSet: vPPToUpdateMap.values())
		{
			vPPToUpdate.addAll(ppSet);
		}

		List<Database.SaveResult> results = Database.update(vPPToUpdate, false);
		LogUtilityException.logSaveResults('BatchUpdateProductProfile','execute',vPPToUpdate,results);


		/*     List<Product_Profile_Product_Set__c> productProfileProductSetList  = new List<Product_Profile_Product_Set__c>();
			 productProfileProductSetList = [Select Product_Profile_Name__c,  Product_Set__c from Product_Profile_Product_Set__c];
			 Map<String, String> matrixMap = new Map<String, String>();
			 String temp = null;
			 For(Product_Profile_Product_Set__c ppps: productProfileProductSetList){
				 matrixMap.put(ppps.Product_Profile_Name__c, ppps.Product_Set__c);
			 }

			 if(!scope.isEmpty() && !productProfileProductSetList.isEmpty()){
				 for(Product_Profile__c pp:scope){
					 temp = matrixMap.get(pp.Name);
					 if(temp == null)
						 temp = 'Unknown';
					 pp.Product_Set__c = temp;
				 }
				 //update scope;
				 Database.update(scope, false);
			 }
			 */
	}

	/**
	 * @description
	 * @param bc
	 */
	public void finish(Database.BatchableContext bc){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		// Below code will fetch the job Id
			AsyncApexJob a = [
					SELECT a.TotalJobItems, a.Status, a.NumberOfErrors,
							a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById,
							a.CompletedDate
					FROM AsyncApexJob a
					WHERE Id = :bc.getJobId()
			];
			// get the job Id
			System.debug('$$$ Jobid is' + bc.getJobId());
		// below code will send an email to User about the status

		String[] toaddress = new String[] {'rui.wang@myob.com'};
		mail.setToAddresses(toaddress);
		mail.setReplyTo('rui.wang@myob.com');
		mail.setSenderDisplayName('Apex Batch Updating Product Profiles');
		mail.setSubject('Batch Processing '+a.Status);
		mail.setPlainTextBody('The Batch Apex job processed '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures.'+' Job Item processed are '+a.JobItemsProcessed);
		Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});
	}
}