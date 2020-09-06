/**
 * @author alexvolkov
 * @date 19/11/19
 * @description Constants class
 */
public with sharing class Constants
{
	//Opportunity Record Types
	public static final Id OPP_CM_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Client Manager April.2017').getRecordTypeId();
	public static final Id OPP_SME_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SME_Solution_Sales_Processing').getRecordTypeId();
	public static final Id OPP_SME_PURCHASE_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SME_Purchase_opportunity').getRecordTypeId();

	//Opportunity Type
	public static final String OPP_TYPE = 'Wholesale';

	//Profile Names
	public static final String MYSUCCESS_LOGIN_PROFILE = 'MYOB Partner Community Login User';

	//API modes used to create a generic queueable class used for all asynchronous api callouts. Add enum for new API
	public enum API_MODE {PRODUCT_PURCHASING}

	//Opportunity Stages
	public static final String OPP_FOR_PROVISIONING = 'Released for Provisioning';
}