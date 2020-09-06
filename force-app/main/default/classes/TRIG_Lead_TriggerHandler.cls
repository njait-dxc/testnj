/**
 * Created by nikhiljaitly on 17/10/19.
 * This is the Handler for Lead Trigger.
 */

public with sharing class TRIG_Lead_TriggerHandler extends TriggerHandler {


public TRIG_Lead_TriggerHandler(){

}

public override void afterInsert(){

	ConvertLead((List<Lead>) Trigger.new, (Map<Id, Lead>) Trigger.oldMap, 'AfterNew');

}

public override void afterUpdate(){

	ConvertLead((List<Lead>) Trigger.new, (Map<Id, Lead>) Trigger.oldMap, 'AfterUpdate');

}

public static void ConvertLead (List <Lead> leadList, Map <Id, Lead> oldMap, String triggerType){
	List <Support_Setting__mdt> MCIUser = [SELECT DeveloperName, Value__c FROM Support_Setting__mdt WHERE DeveloperName = 'Marketing_Cloud_Integration_User'];
	String MCIUserString = null;
	if(MCIUser != null && MCIUser.size() > 0) {
		MCIUserString = MCIUser[0].Value__c;
		System.debug('Marketing Cloud Integration user is) ' + MCIUserString);
	}

	Set <Id> leadIdSet = new Set <Id>();
	for(Lead l : leadList) {
		if(l.Lead_Convert_in_Marketing_Cloud__c) {
			leadIdSet.add(l.Id);
		}
	}
	if(MCIUserString.contains(System.UserInfo.getUserId()) && leadIdSet.size() > 0) {

		List <String> supportEmailAddresses = new List <String> ();
		for(Outbound_Email_Addresses__mdt i :[SELECT Email__c FROM Outbound_Email_Addresses__mdt WHERE DeveloperName = 'Marketing_Cloud_Integration']) {
			supportEmailAddresses.add(i.Email__c);
		}
		Integer NoOfIssueLeads = 0;
		String TextBody = 'Please review the following Lead records, either Client ID or Contact Row Id was missed when Marketing Cloud tried to convert them: ';
		Set <String> ClientIdSet = new Set <String>();
		Set <String> crIdSet = new Set <String>();
		Set <String> emailSet = new Set <String>();

		for(Lead l : leadList) {
			if(l.Lookup_Client_ID__c != null && l.Lead_Convert_in_Marketing_Cloud__c) {
				ClientIdSet.add(l.Lookup_Client_ID__c);
			}
			if(l.Archie_Contact_Row_ID__c !=null && l.Lead_Convert_in_Marketing_Cloud__c) {
				crIdSet.add(l.Archie_Contact_Row_ID__c);
			}
			if(l.Email != null && l.Lead_Convert_in_Marketing_Cloud__c) {
				emailSet.add(l.Email);
			}
		}

		List <Lead> emailMatchedLeads = new List <Lead> ();
		if(emailSet.size() > 0) {
			emailMatchedLeads = [SELECT Id, Email, Lookup_Client_ID__c, Archie_Contact_Row_ID__c,Lead_Convert_in_Marketing_Cloud__c FROM Lead WHERE Id NOT IN :leadIdSet AND Email IN :emailSet AND IsConverted = FALSE];

		}

		Map <String, Account> AccountMap = new Map <String, Account>();
		for(Account a : [SELECT Client_ID__c, Name, Id FROM Account WHERE Client_ID__c IN :ClientIdSet]) {
			AccountMap.put(a.Client_ID__c, a);
		}
		Map <String, Contact> ContactMap = new Map <String, Contact>();
		for(Contact c : [SELECT Contact_Siebel_Row_Id__c, Id FROM Contact WHERE Contact_Siebel_Row_Id__c IN :crIdSet]) {
			ContactMap.put(c.Contact_Siebel_Row_Id__c, c);
		}
		List <Database.LeadConvert> leadConverts = new List <Database.LeadConvert>();
		if(triggerType == 'AfterNew') {
			for(Lead l : leadList) {
				if(l.Lead_Convert_in_Marketing_Cloud__c) {
					if(AccountMap.containsKey(l.Lookup_Client_ID__c) && ContactMap.containsKey(l.Archie_Contact_Row_ID__c)) {
						Database.LeadConvert leadConvert = new database.LeadConvert();
						leadConvert.setLeadId(l.Id);
						leadConvert.setAccountId(AccountMap.get(l.Lookup_Client_ID__c).Id);
						leadConvert.setContactId(ContactMap.get(l.Archie_Contact_Row_ID__c).Id);
						leadConvert.convertedStatus = 'Qualified';
						leadConvert.setDoNotCreateOpportunity(true);
						leadConverts.add(leadConvert);
					} else {
						NoOfIssueLeads = NoOfIssueLeads +1;
						TextBody = TextBody + '\n Lead ID: ' + l.Id + '\n Client ID: ' + l.Lookup_Client_ID__c + '\n Contact Row ID: ' + l.Archie_Contact_Row_ID__c;
					}
				}
			}
		}
		if(triggerType == 'AfterUpdate') {
			for(Lead l : leadList) {
				if(!l.IsConverted && l.Lead_Convert_in_Marketing_Cloud__c && !oldMap.get(l.Id).Lead_Convert_in_Marketing_Cloud__c) {
					if(AccountMap.containsKey(l.Lookup_Client_ID__c) && ContactMap.containsKey(l.Archie_Contact_Row_ID__c)) {
						Database.LeadConvert leadConvert = new database.LeadConvert();
						leadConvert.setLeadId(l.Id);
						leadConvert.setAccountId(AccountMap.get(l.Lookup_Client_ID__c).Id);
						leadConvert.setContactId(ContactMap.get(l.Archie_Contact_Row_ID__c).Id);
						leadConvert.convertedStatus = 'Qualified';
						leadConvert.setDoNotCreateOpportunity(true);
						leadConverts.add(leadConvert);
					} else {
						NoOfIssueLeads = NoOfIssueLeads +1;
						TextBody = TextBody + '\n Lead ID: ' + l.Id + '\n Client ID: ' + l.Lookup_Client_ID__c + '\n Contact Row ID: ' + l.Archie_Contact_Row_ID__c;
					}
				}
			}
		}
		//Update emailMatchedLeads have same Lookup_Client_Id__c and Archie_Contact_Row_Id__c with leadList

		for(Lead i : leadList) {
			for(Lead j : emailMatchedLeads) {
				if(i.Email == j.Email) {
					j.Lookup_Client_ID__c = i.Lookup_Client_ID__c;
					j.Archie_Contact_Row_ID__c = i.Archie_Contact_Row_ID__c;
				}
			}
		}

		//Convert all Lead has same email address as the trigger input leads
		if(triggerType == 'AfterNew' || triggerType == 'AfterUpdate') {
			for(Lead l : emailMatchedLeads) {
				if(AccountMap.containsKey(l.Lookup_Client_ID__c) && ContactMap.containsKey(l.Archie_Contact_Row_ID__c)) {
					Database.LeadConvert leadConvert = new database.LeadConvert();
					leadConvert.setLeadId(l.Id);
					leadConvert.setAccountId(AccountMap.get(l.Lookup_Client_ID__c).Id);
					leadConvert.setContactId(ContactMap.get(l.Archie_Contact_Row_ID__c).Id);
					leadConvert.convertedStatus = 'Qualified';
					leadConvert.setDoNotCreateOpportunity(true);
					leadConverts.add(leadConvert);
				} else {
					NoOfIssueLeads = NoOfIssueLeads +1;
					TextBody = TextBody + '\n Lead ID: ' + l.Id + '\n Client ID: ' + l.Lookup_Client_ID__c + '\n Contact Row ID: ' + l.Archie_Contact_Row_ID__c;
				}
			}
		}
		if(!leadConverts.isEmpty()) {
			try {
				List<Database.LeadConvertResult> leadConvertResultList = Database.convertLead(leadConverts, true);
				System.debug(leadConvertResultList);
			} catch (Exception e){
				System.debug('The following exception has occurred: ' + e.getMessage());
				LogUtilityException.logException('TRIG_Lead_TriggerHandler', 'ConvertLead ', e,leadConverts,false);
			}

		}
		if(NoOfIssueLeads > 0) {
			sendEmailNotification(supportEmailAddresses, NoOfIssueLeads, TextBody);
		}
	}
}

public static void sendEmailNotification (String[] toAddresses, Integer NoOfIssueLeads, String TextBody){
	System.debug(toAddresses);
	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	mail.setToAddresses(toAddresses);
	mail.setReplyTo(toAddresses[0]);
	mail.setSenderDisplayName('Lead Trigger Handler');
	mail.setSubject('Marketing Cloud cannot convert Leads: ' + NoOfIssueLeads);
	mail.setBccSender(false);
	mail.setUseSignature(false);
	mail.setPlainTextBody(TextBody);

	try {
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	} catch (Exception e){
		System.debug('The following exception has occurred: ' + e.getMessage());
	}
}


}