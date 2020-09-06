/**
 * @author
 * @date
 * @description
 */

public inherited sharing class CaseCreationExtension
{
	ApexPages.StandardController stdCtrl;
	public Case newCase { get; set; }
	public Attachment newAttachment { get; set; }
	public List<Case_Category_Map_Guidance__c> listCaseCategoryMapGuidance { get; set; }
	public Map <String, Case_Category_Map_Guidance__c> mapCaseCategoryMap { get; set; }
	public String jsonMap { get; set; }

	public CaseCreationExtension(ApexPages.StandardController controller)
	{
		if (!Test.isRunningTest())
		{
			controller.addFields(new List<String>
			{
					'Id', 'AccountId', 'ContactId', 'Categ__c', 'Sub_Category__c', 'Serial_Number__c', 'Refund_Required__c', 'Total_Value__c', 'Per_Month__c', 'Cancellation_Reason__c', 'Subject', 'Description', 'Cancellation_Reason__c', 'Cancellation_Reason_Competitor__c', 'Cancellation_Specific_Reason__c', 'Cancellation_Additional_Reason__c', 'Clear_Reason_For_the_Credit__c', 'Primary_Category__c', 'SubmittedEmail__c', 'Online_File_Removal_Serial_Number__c', 'Most_Appropriate_Contact_to_Liaise_With__c', 'Amicable_Merger__c', 'Practice_Merger_Client_IDs__c', 'Are_Services_Required__c', 'Practice_Merger_Date__c', 'Practice_Split_Date__c', 'Practice_Split_Client_IDs__c', 'Amicable__c', 'What_s_Offer_to_be_Applied__c', 'SubmittedCompany__c',
					'What_Product_to_Create_Quote_for__c', 'Quote_Creation_Send_To_Email__c', 'ARL_Basic__c', 'ARL_Plus__c', 'ARL_Standard__c', 'Connected_Ledger__c', 'EA_Starter__c', 'EA_Payroll_Unlimited__c', 'EA_Payroll_For_1__c', 'Concie__c'
			});
			System.debug('AddFields');
		}
		System.debug('Initial Controller');
		this.stdCtrl = controller;
		newCase = (Case) stdCtrl.getRecord();
		System.debug('AccountId:' + newCase.AccountId);
		newAttachment = new Attachment();
		//added limit 50000 as it's the governor limit for a single VF request. Potentially should be less.
		listCaseCategoryMapGuidance = [SELECT CategoryIdentity__c, Primary_Category__c, Category__c, Sub_Category__c, Content__c FROM Case_Category_Map_Guidance__c LIMIT 50000];
		mapCaseCategoryMap = new Map<String, Case_Category_Map_Guidance__c>();
		for (Case_Category_Map_Guidance__c a : listCaseCategoryMapGuidance)
		{
			mapCaseCategoryMap.put(a.CategoryIdentity__c, a);
		}


		jsonMap = JSON.serialize(mapCaseCategoryMap);
	}

	/**
	 * @description
	 * @return
	 */
	public PageReference validateSaveRedirect()
	{
		Account acc = [SELECT Id, Status__c FROM Account WHERE Id = :newCase.AccountId];
		System.debug('AccountId in save:' + acc.Id);
		System.debug('Account Status in save:' + acc.Status__c);
		if (acc.Status__c == 'Cancelled Client')
		{
			System.debug('Cannot create new case for Cancelled Client!');
			System.debug('Account Status' + newCase.Account.Status__c);
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Cannot create new case for Cancelled Client!');
			ApexPages.addMessage(myMsg);
			return null;
		}

		if ((newCase.Categ__c == null && (newCase.Primary_Category__c == 'Billing & Finance' || newCase.Primary_Category__c == 'Partner Program' || newCase.Primary_Category__c == 'Feedback' || newCase.Primary_Category__c == 'Ledger Success' || newCase.Primary_Category__c == 'Ledger Specialist')) || (newCase.Primary_Category__c != 'Billing & Finance' && newCase.Primary_Category__c != 'Partner Program' && newCase.Primary_Category__c != 'Feedback' && newCase.Primary_Category__c != 'Ledger Success' && newCase.Primary_Category__c != 'Ledger Specialist' && (newCase.Categ__c == null || newCase.Sub_Category__c == null)))
		{
			if (newCase.Categ__c == 'Project X' && newCase.Primary_Category__c == 'Onboarding Request')
			{
			}
			else
			{
				System.debug('Adding error message for primanry category, category and sub category validation');
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: For Billing & Finance, Partner Program, Feedback and Ledger Success case, the category field is required. For other case, the category and sub category fields are required. For Commission dispuate case, please go to MyHub to submit it.');
				ApexPages.addMessage(myMsg);
				return null;
			}
		}
		if (newCase.Called_Support_Before__c == 'No' && newCase.Primary_Category__c == 'Support Escalation')
		{
			System.debug('Adding error message for call support before validation');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Cannot create new case, and please advise partner to call Partner Technical Support to resolve their query first. Thanks!');
			ApexPages.addMessage(myMsg);
			return null;
		}
		if (newCase.Categ__c == 'Cancellations' && (newCase.Serial_Number__c == null || newCase.Cancellation_Reason__c == null || newCase.Refund_Required__c == null))
		{
			System.debug('Adding error message for cancellation validation');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Fields Product Name or Serial Number, Cancellation Reason and Refund Required must be filled in for cancellation case.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		else if (newCase.Categ__c == 'Credit Note' && newCase.Clear_Reason_For_the_Credit__c == null)
		{
			System.debug('Adding error message for credit note');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Field Clear Reason For the Credit Note must be filled in for credit note case.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		/*else if(newCase.Categ__c != 'Cancellations' && newCase.Sub_Category__c != 'Wholesale Order' && newCase.Categ__c != 'Credit Note' && newCase.Categ__c != 'License Reduction' && (newCase.Subject == null || newCase.Description == null)){
			system.debug('Adding error message for non cancellation validation');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Fields Subject and Description must be filled in for the case.');
			ApexPages.addMessage(myMsg);
			return null;
		}*/
		else if (newCase.Cancellation_Reason__c == 'Moving to Competitor' && (newCase.Cancellation_Reason_Competitor__c == null || newCase.Cancellation_Additional_Reason__c == null || newCase.Cancellation_Specific_Reason__c == null))
		{
			System.debug('Adding error message for cancellation reason');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Fields Competitor, Additional Reason & Specific Reason must be filled in if Canncellation Reason is set as Moving to Comppetitor.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		else if (newCase.Sub_Category__c == 'Dashboard Cleanup or Provisioning' && newCase.SubmittedEmail__c == null)
		{
			System.debug('Adding error message for cancellation reason');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Field Email Address for Cleanup or Provisioning must be filled in if it is for Dashboard Cleanup or Provisioning.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		else if (newCase.Sub_Category__c == 'Online File Removal' && newCase.Online_File_Removal_Serial_Number__c == null)
		{
			System.debug('Adding error message for Online File Removal');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Field Serial Number must be filled in if it is for Online File Removal.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		else if (newCase.Sub_Category__c == 'Practice Merger' && (newCase.Most_Appropriate_Contact_to_Liaise_With__c == null || newCase.Amicable_Merger__c == null || newCase.Practice_Merger_Client_IDs__c == null || newCase.Are_Services_Required__c == null || newCase.Practice_Merger_Date__c == null))
		{
			System.debug('Adding error message for Practice Merger');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Fields Most Appropriate Contact to Liaise With, Is the Merge Amicable, Are any technical or consulting services required to be scoped, Client IDs and Effective Date of Merge must be filled in if it is for Practice Merger.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		else if (newCase.Sub_Category__c == 'Practice Split' && (newCase.Most_Appropriate_Contact_to_Liaise_With__c == null || newCase.Amicable__c == null || newCase.Practice_Split_Client_IDs__c == null || newCase.Are_Services_Required__c == null || newCase.Practice_Split_Date__c == null))
		{
			System.debug('Adding error message for Practice Merger');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Fields Most Appropriate Contact to Liaise With, Is the Split Amicable, Are any technical or consulting services required to be scoped, Client IDs and Effective Date of Split must be filled in if it is for Practice Split.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		else if (newCase.Categ__c == 'Sales Promotion/Agreement Adjustment' && newCase.What_s_Offer_to_be_Applied__c == null)
		{
			System.debug('Adding error message for Sales Promotion/Agreement Adjustment');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Field Whats the Offer That should be Applied must be filled in for Sales Promotion/Agreement Adjustment.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		else if (newCase.Sub_Category__c == 'Quote Creation' && newCase.New_Account__c == 'Yes' && (newCase.SubmittedCompany__c == null || newCase.What_Product_to_Create_Quote_for__c == null || newCase.Quote_Creation_Send_To_Email__c == null))
		{
			System.debug('Adding error message for Quote Creation');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Fields Name of New Account, What Product to Create Quote for,  Email Address to send quote to must be filled in for Quote Creation --> Client Pays --> New Account: Yes.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		else if (newCase.Sub_Category__c == 'Wholesale Order' && newCase.ARL_Basic__c == null && newCase.ARL_Plus__c == null && newCase.ARL_Standard__c == null && newCase.Connected_Ledger__c == null && newCase.EA_Starter__c == null && newCase.EA_Payroll_Unlimited__c == null && newCase.EA_Payroll_For_1__c == null && newCase.EA_Payroll_NZ_Only__c == null && newCase.MYOB_Essentials_Connected_Ledger_w_Payro__c == null && newCase.MYOB_Essentials_Payroll__c == null)
		{
			System.debug('Adding error message for Wholesale Order');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: cannot submit a case until at least one of the product fields has a numerical value in it for Wholesale Order');
			ApexPages.addMessage(myMsg);
			return null;
		}
		//else if(newCase.Categ__c == 'BL - Essentials'){
		// system.debug('Adding error message for BL Essential Migration Service');
		//  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: cannot submit a case until all required fields are filled for BL Essentials migration service.');
		//  ApexPages.addMessage(myMsg);
		//  return null;
		// }
		else if (newCase.Categ__c == 'Certified Consultant On Boarding' && (newCase.What_professional_associations__c == null || newCase.Partner_on_new_Partner_Program__c == null || newCase.Has_your_Partner_completed_prework__c == null || newCase.Dashboard_Set_Up_10_Files_Linked__c == null))
		{
			System.debug('Adding error message for Certified Consultant On Boarding');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: cannot submit a case until all required fields are filled for Certified Consultant On Boarding.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		else if (((newCase.Categ__c == 'Cancellations' && newCase.Refund_Required__c == 'Yes') || (newCase.Categ__c == 'Credit Note') || (newCase.Categ__c == 'License Reduction' && newCase.Refund_Required__c == 'Yes') || (newCase.Categ__c == 'Invoicing Query' && newCase.Refund_Required__c == 'Yes') || (newCase.Categ__c == 'Referral Rebates & Commissions' && newCase.Refund_Required__c == 'Yes') || (newCase.Categ__c == 'Sales Promotion/Agreement Adjustment' && newCase.Refund_Required__c == 'Yes') || (newCase.Categ__c == 'Change Billing Contact/Details' && newCase.Refund_Required__c == 'Yes') || (newCase.Categ__c == 'Account in Arrears' && newCase.Refund_Required__c == 'Yes')) && newCase.Total_Value__c == null)
		{
			System.debug('Adding error message for credit note');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Field Total $ Value is required if Refund Requires is Yes.');
			ApexPages.addMessage(myMsg);
			return null;
		}
		else
		{
			//if(null==stdCtrl.save()){
			//    return null;
			//}
			/*try{
				stdCtrl.save();
			}
			catch(system.Exception e){
				ApexPages.Message msg = new apexPages.Message(Apexpages.Severity.ERROR, e.getdmlMessage(0));
				ApexPages.addMessage(msg);
				return null;
			}*/
			if (newCase.Subject == null)
			{
				newCase.Subject = newCase.Categ__c ;
			}

			stdCtrl.save();
			Case caseNew = (Case) stdCtrl.getRecord();
			Id caseIdNew = caseNew.Id;
			System.debug(caseIdNew);

			if (newAttachment.Body != null)
			{
				if (Schema.SObjectType.Case.isUpdateable())
				{
					System.debug('Adding Attachment');
					newAttachment.ParentId = caseIdNew ;
					try
					{
						insert newAttachment;
					} catch (system.Exception e)
					{
						ApexPages.Message msg = new apexPages.Message(Apexpages.Severity.ERROR, e.getdmlMessage(0));
						ApexPages.addMessage(msg);
						return null;
					}
				}
				else
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Access denied. You are not allowed to attach files to Cases'));
					return null;
				}
			}

			PageReference pr = new PageReference('/' + caseIdNew);
			pr.setRedirect(true);
			return pr;
		}
	}

	/**
	 * @description
	 * @return
	 */
	public PageReference cancelRedirect()
	{
		stdCtrl.cancel();
		String url = '';

		if (newCase.ContactId != null)
		{
			System.debug('Contact Id' + newCase.ContactId);
			url = newCase.ContactId;
		}
		else if (newCase.AccountId != null)
		{
			System.debug('Account Id' + newCase.AccountId);
			url = newCase.AccountId;
		}

		PageReference pr = new PageReference('/' + url);
		pr.setRedirect(true);
		return pr;
	}
}