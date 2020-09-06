/**
 * @author
 * @date
 * @description Controller for AddMoreUsers Visualforce page
 */

public inherited sharing class AddMoreUserController
{
	public Opportunity opportunityRecord { get; set; }
	public List <Product_Profile__c> listProductProfile { get; set; }
	public List <String> listProductProfileName { get; set; }
	
	public class ProductProfileWrapper
	{
		public Boolean selected { get; set; }
		public Product_Profile__c productProfile { get; set; }
		public Decimal numNewUser { get; set; }
		public String associatedProductsNames { get; set; }
		
		public ProductProfileWrapper(Boolean selected, Decimal numNewUser, Product_Profile__c productProfile, String associatedProductsNames)
		{
			this.selected = selected;
			this.productProfile = productProfile;
			this.numNewUser = numNewUser;
			this.associatedProductsNames = associatedProductsNames;
		}
		
		//Component containing unescaped HTML
		public Component.Apex.OutputLabel getUnescapedComp()
		{
			return UtilityClass_MYOB.getUnescapedLabelComp(associatedProductsNames);
		}
	}
	
	public class ProductProfileRecommendationWrapper
	{
		public Boolean selected { get; set; }
		public Product_Profile_Recommendation__c product { get; set; }
		public Decimal numNewUser { get; set; }
		public Boolean initialPurchaseFlag { get; set; }
		public String associatedProdProfiles { get; set; }
		
		public ProductProfileRecommendationWrapper(Boolean selected, Product_Profile_Recommendation__c product, Decimal numNewUser, Boolean initialPurchaseFlag, String associatedProdProfiles)
		{
			this.selected = selected;
			this.product = product;
			this.numNewUser = numNewUser;
			this.initialPurchaseFlag = initialPurchaseFlag;
			this.associatedProdProfiles = associatedProdProfiles;
		}
		
		//Component containing unescaped HTML
		public Component.Apex.OutputLabel getUnescapedComp()
		{
			return UtilityClass_MYOB.getUnescapedLabelComp(associatedProdProfiles);
		}
	}
	
	public List <ProductProfileWrapper> listProductProfileToHandle { get; set; }
	public List <ProductProfileRecommendationWrapper> listProdProfileRecommendationToHandle { get; set; }
	List<Product_Profile_Product_Set__c> productProfileProductSetList = new List<Product_Profile_Product_Set__c> ();
	List<Product_Profile_Product_Set__c> productProfileProductSetRecList = new List<Product_Profile_Product_Set__c> ();
	Map<String, Product_Profile_Product_Set__c> mapPPS = new Map<String, Product_Profile_Product_Set__c>();
	Map<Id, Integer> mapPPRec = new Map <Id, Integer>();
	//Map<String, Id> mapOpplineItem = New Map <String, Id>();
	List <OpportunityLineItem> listOppLineItem = new List<OpportunityLineItem> ();
	Map <Id, Id> mapOppLineItemProdId = new Map<Id, Id>();
	Map<Id, PricebookEntry> mapPricebookEntry = new Map<Id, PricebookEntry>();
	
	public AddMoreUserController(ApexPages.StandardController controller)
	{
		this.opportunityRecord = (Opportunity) controller.getRecord();
		listProductProfileName = new List<String>();
		listProductProfileToHandle = new List<ProductProfileWrapper>();
		listProdProfileRecommendationToHandle = new List<ProductProfileRecommendationWrapper>();
		
		listOppLineItem = [SELECT Product2Id FROM OpportunityLineItem WHERE OpportunityId = :THIS.opportunityRecord.Id WITH SECURITY_ENFORCED];
		if (listOppLineItem.size() > 0)
		{
			for (OpportunityLineItem lineItem : listOppLineItem)
			{
				if (!mapOppLineItemProdId.containsKey(lineItem.Product2Id))
				{
					mapOppLineItemProdId.put(lineItem.Product2Id, lineItem.Product2Id);
				}
			}
		}
		
		List <PricebookEntry> listPricebookEntry = [SELECT Product2Id, Name, Id FROM PricebookEntry WHERE CurrencyIsoCode = :opportunityRecord.CurrencyIsoCode AND IsActive = TRUE AND Pricebook2Id = :opportunityRecord.Pricebook2Id WITH SECURITY_ENFORCED];
		for (PricebookEntry pbe : listPricebookEntry)
		{
			mapPricebookEntry.put(pbe.Product2Id, pbe);
		}
		
		Id oppAccountId = this.opportunityRecord.AccountId;
		listProductProfile = [SELECT Id, Name, Compliance_Users__c, Max_User_Number__c, Practice_Name__c,Prod_Profile_ID__c, Product_Family__c, Product_Line__c, Product_Set__c, Quantity__c,Total_Inc_GST__c, Total_Net_Amount__c,Users__c FROM Product_Profile__c WHERE Practice_Name__c = :oppAccountId WITH SECURITY_ENFORCED];
		
		for (Product_Profile__c pp : listProductProfile)
		{
			listProductProfileName.add(pp.Name);
		}
		
		productProfileProductSetList = [SELECT Product_Profile_Name__c, Product_Set__c, (SELECT Product__c, Product_Name__c, Product_Type__c, Recommendation_Type__c, Recommendation_Reason__c FROM Product_Profile_Recommendations__r WHERE Recommendation_Type__c = 'Must Have') FROM Product_Profile_Product_Set__c WHERE Product_Profile_Name__c IN :listProductProfileName WITH SECURITY_ENFORCED];
		
		for (Product_Profile_Product_Set__c ppsItem : productProfileProductSetList)
		{
			mapPPS.put(ppsItem.Product_Profile_Name__c, ppsItem);
		}
		
		String tempAssociatedProductNames = '';
		Product_Profile_Product_Set__c temp = new Product_Profile_Product_Set__c();
		
		for (Product_Profile__c pp : listProductProfile)
		{
			if (mapPPS.containsKey(pp.Name))
			{
				temp = mapPPS.get(pp.Name);
				for (Product_Profile_Recommendation__c pprItem : temp.Product_Profile_Recommendations__r)
				{
					System.debug('Product Name:' + pprItem.Product_Name__c);
					if (mapOppLineItemProdId.containsKey(pprItem.Product__c))
					{
						tempAssociatedProductNames = tempAssociatedProductNames + '<font color="blue">' + pprItem.Product_Name__c.escapeHtml4() + '</font>' + ';<br/>';
					} else if (!mapPricebookEntry.containsKey(pprItem.Product__c))
					{
						tempAssociatedProductNames = tempAssociatedProductNames + '<font color="red">' + pprItem.Product_Name__c.escapeHtml4() + '</font>' + ';<br/>';
					} else
					{
						tempAssociatedProductNames = tempAssociatedProductNames + pprItem.Product_Name__c.escapeHtml4() + ';<br/>';
					}
				
				}
				//System.debug('Product to be added:' + tempAssociatedProductNames);
				if (Test.isRunningTest())
				{
					listProductProfileToHandle.add(new ProductProfileWrapper(true, 1, pp, tempAssociatedProductNames));
					tempAssociatedProductNames = '';
				} else
				{
					listProductProfileToHandle.add(new ProductProfileWrapper(false, 0, pp, tempAssociatedProductNames));
					tempAssociatedProductNames = '';
				}
			
			}
		
		}
		
		productProfileProductSetRecList = [SELECT Product_Profile_Name__c, Product_Set__c, (SELECT Product__c, Product_Name__c, Product_Type__c, Recommendation_Type__c, Recommendation_Reason__c FROM Product_Profile_Recommendations__r WHERE Recommendation_Type__c = 'Recommend') FROM Product_Profile_Product_Set__c WHERE Product_Profile_Name__c IN :listProductProfileName WITH SECURITY_ENFORCED];
		Integer i = 0;
		
		for (Product_Profile_Product_Set__c pp : productProfileProductSetRecList)
		{
			for (Product_Profile_Recommendation__c ppRec : pp.Product_Profile_Recommendations__r)
			{
				if (!mapOppLineItemProdId.containsKey(ppRec.Product__c) && mapPricebookEntry.containsKey(ppRec.Product__c))
				{
					String lRecReason;
					if (ppRec.Recommendation_Reason__c != null)
					{
						lRecReason = ppRec.Recommendation_Reason__c.escapeHtml4();
					}
					String lPPName;
					if (pp.Product_Profile_Name__c != null)
					{
						lPPName = pp.Product_Profile_Name__c.escapeHtml4();
					}
					if (!mapPPRec.containsKey(ppRec.Product__c))
					{
						mapPPRec.put(ppRec.Product__c, i);
						i++;
						System.debug('ppRec:' + ppRec);
						if (Test.isRunningTest())
						{
							listProdProfileRecommendationToHandle.add(new ProductProfileRecommendationWrapper(true, ppRec, 1, false, lPPName + ':' + lRecReason + '<br/>'));
						} else
						{
							listProdProfileRecommendationToHandle.add(new ProductProfileRecommendationWrapper(false, ppRec, 0, false, lPPName + ':' + lRecReason + '<br/>'));
						}
					
					} else
					{
						ProductProfileRecommendationWrapper tempRecWrapperItem = listProdProfileRecommendationToHandle.get(mapPPRec.get(ppRec.Product__c));
						tempRecWrapperItem.associatedProdProfiles = tempRecWrapperItem.associatedProdProfiles + lPPName + ':' + lRecReason + '<br/>';
						listProdProfileRecommendationToHandle.set(mapPPRec.get(ppRec.Product__c), tempRecWrapperItem);
					}
				}
			}
		}
	}
	
	public PageReference directToAddMoreUserPage()
	{
		PageReference returnedPage = Page.AddMoreUsers;
		returnedPage.getParameters().put('Id', opportunityRecord.Id);
		returnedPage.setRedirect(false);
		return returnedPage;
	}
	
	public PageReference directToAddRecommededProductPage()
	{
		PageReference returnedPage = Page.AddProdProfileRecommendedProduct;
		returnedPage.getParameters().put('Id', opportunityRecord.Id);
		returnedPage.setRedirect(false);
		return returnedPage;
	}
	
	public PageReference addSelected()
	{
		if (listProductProfile.size() > 0)
		{
			Map<Id, Decimal> mapProductToAdd = new Map<Id, Decimal>();
			Product_Profile_Product_Set__c temp = new Product_Profile_Product_Set__c();
			
			for (ProductProfileWrapper pPWItem : listProductProfileToHandle)
			{
				if (pPWItem.selected && mapPPS.containsKey(pPWItem.productProfile.Name))
				{
					temp = mapPPS.get(pPWItem.productProfile.Name);
					for (Product_Profile_Recommendation__c pprItem : temp.Product_Profile_Recommendations__r)
					{
						if (!mapOppLineItemProdId.containsKey(pprItem.Product__c) && mapPricebookEntry.containsKey(pprItem.Product__c))
						{
							//mapProductToAdd.put(pprItem.Product__c, pPWItem.numNewUser);
							mapProductToAdd.put(mapPricebookEntry.get(pprItem.Product__c).Id, pPWItem.numNewUser);
							System.debug('Product Id:' + pprItem.Product__c);
							System.debug('Product Name:' + pprItem.Product_Name__c);
						}
					}
				}
			}
			
			List <OpportunityLineItem> listOppItemToAdd = new List<OpportunityLineItem>();
			for (Id key : mapProductToAdd.keySet())
			{
				//listOppItemToAdd.add(new OpportunityLineItem(OpportunityId=opportunityRecord.Id , Product2Id=Key, Number_of_Users__c= mapProductToAdd.get(Key)));
				listOppItemToAdd.add(new OpportunityLineItem(OpportunityId = opportunityRecord.Id, PricebookEntryId = key, Number_of_Users__c = mapProductToAdd.get(key)));
			}
			
			if (listOppItemToAdd.size() > 0)
			//insert listOppItemToAdd;
			
			{
				try
				{
					/*List<Database.SaveResult> insertOppListResults =*/ Database.insert(listOppItemToAdd, true);
				} catch (Exception e)
				{
					LogUtilityException.throwException('AddMoreUserController', 'addSelected', e, listOppItemToAdd);
				}
			}
		}
		
		PageReference returnedPage = Page.OpportunityProductProfile;
		if (system.UserInfo.getUiTheme() != 'Theme4t' && system.UserInfo.getUiTheme() != 'Theme4d')
		{
			returnedPage.getParameters().put('Id', opportunityRecord.Id);
			returnedPage.setRedirect(false);
		} else
		{
			returnedPage = new PageReference('/' + opportunityRecord.Id);
			returnedPage.setRedirect(true);
		}
		return returnedPage;
	}
	
	public PageReference addSelectedRecommendedProduct()
	{
		if (listProdProfileRecommendationToHandle.size() > 0)
		{
			List <OpportunityLineItem> listOppItemToAdd = new List<OpportunityLineItem>();
			Product_Profile_Recommendation__c temp = new Product_Profile_Recommendation__c();
			
			for (ProductProfileRecommendationWrapper pPRecWItem : listProdProfileRecommendationToHandle)
			{
				if (pPRecWItem.selected)
				{
					temp = pPRecWItem.product;
					//listOppItemToAdd.add(new OpportunityLineItem(OpportunityId=opportunityRecord.Id , Product2Id=temp.Product__c, Number_of_Users__c= pPRecWItem.numNewUser, Initial_Purchase__c=pPRecWItem.initialPurchaseFlag));
					listOppItemToAdd.add(new OpportunityLineItem(OpportunityId = opportunityRecord.Id, PricebookEntryId = mapPricebookEntry.get(temp.Product__c).Id, Number_of_Users__c = pPRecWItem.numNewUser, Initial_Purchase__c = pPRecWItem.initialPurchaseFlag));
					System.debug('rec product to be added:' + temp.Product__c);
				}
			}
			
			if (listOppItemToAdd.size() > 0)
			//insert listOppItemToAdd;
			{
				
				try
				{
					/*List<Database.SaveResult> insertOppItemListResults = */Database.insert(listOppItemToAdd, true);
				} catch (Exception e)
				{
					LogUtilityException.throwException('AddMoreUserController', 'addSelectedRecommendedProduct', e, listOppItemToAdd);
				}
			}
		}
		
		PageReference returnedPage = Page.OpportunityProductProfile;
		if (system.UserInfo.getUiTheme() != 'Theme4t' && system.UserInfo.getUiTheme() != 'Theme4d')
		{
			returnedPage.getParameters().put('Id', opportunityRecord.Id);
			returnedPage.setRedirect(false);
		} else
		{
			returnedPage = new PageReference('/' + opportunityRecord.Id);
			returnedPage.setRedirect(true);
		}
		return returnedPage;
	
	}
	
	@RemoteAction
	public static Boolean clickButton(Id oppId)
	{
		return true;
	}
}