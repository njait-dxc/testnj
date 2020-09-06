/**
 * @author
 * @date
 * @description
 */

public inherited sharing class ProductLicenseExtension
{
	public String CaseCategory { get; set; }
	public Case CaseAssociated { get; set; }
	public Product_License__c ProductLicense { get; set; }
	public ProductLicenseExtension(ApexPages.StandardController controller)
	{
		this.ProductLicense = (Product_License__c) controller.getRecord();
		CaseAssociated = [SELECT Id, Categ__c, Sub_Category__c, Primary_Category__c FROM Case WHERE Id = :ProductLicense.Case__c WITH SECURITY_ENFORCED];
		CaseCategory = CaseAssociated.Categ__c;
	}
}