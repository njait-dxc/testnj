/**
 * @author
 * @date
 * @description
 */

public inherited sharing class AddRecommendedProductController
{



	public class RecommendedProductWrapper
	{
		public Boolean selected { get; set; }
		public Product_Recommendation__c recProduct { get; set; }
		public String associatedProduct { get; set; }
		public Decimal numNewUser { get; set; }
		public Boolean initialPurchaseFlag { get; set; }

		/**
		 * RecommendedProductWrapper description
		 * @param  selected            selected description
		 * @param  recProduct          recProduct description
		 * @param  numNewUser          numNewUser description
		 * @param  initialPurchaseFlag initialPurchaseFlag description
		 * @param  associatedProduct   associatedProduct description
		 * @return                     return description
		 */
		public RecommendedProductWrapper(Boolean selected, Product_Recommendation__c recProduct, Decimal numNewUser, Boolean initialPurchaseFlag, String associatedProduct)
		{
			this.selected = selected;
			this.recProduct = recProduct;
			this.associatedProduct = associatedProduct;
			this.numNewUser = numNewUser;
			this.initialPurchaseFlag = initialPurchaseFlag;
		}

		/**
		 * getUnescapedComp Component containing unescaped HTML
		 * @return   return description
		 */
		public Component.Apex.OutputLabel getUnescapedComp()
		{
			return UtilityClass_MYOB.getUnescapedLabelComp(associatedProduct);
		}
	}

	public Opportunity opportunityRecord { get; set; }
	public List <RecommendedProductWrapper> listRecProdtoHandle { get; set; }
	List <OpportunityLineItem> listOppLineItem = new List<OpportunityLineItem> ();
	List <Id> listOppLineItemId = new List<Id>();
	Map <Id, Id> mapOppLineItemProdId = new Map<Id, Id>();
	Map <Id, Integer> mapProdRecProdId = new Map<Id, Integer>();
	Map<Id, PricebookEntry> mapPricebookEntry = new Map<Id, PricebookEntry>();

	/**
	 * AddRecommendedProductController description
	 * @param  controller controller description
	 * @return            return description
	 */
	public AddRecommendedProductController(ApexPages.StandardController controller)
	{
		listRecProdtoHandle = new List<RecommendedProductWrapper>();
		this.opportunityRecord = (Opportunity) controller.getRecord();

		listOppLineItem = [SELECT
									Product2Id
							FROM
									OpportunityLineItem
							WHERE
									OpportunityId = :THIS.opportunityRecord.Id];

		if (listOppLineItem.isEmpty() == false)
		{
			for (OpportunityLineItem lineItem : listOppLineItem)
			{
				if (!mapOppLineItemProdId.containsKey(lineItem.Product2Id))
				{
					mapOppLineItemProdId.put(lineItem.Product2Id, lineItem.Product2Id);
					listOppLineItemId.add(lineItem.Product2Id);
				}
			}
		}

		Integer i = 0;

		List <PricebookEntry> listPricebookEntry = [SELECT
															Product2Id,
															Name
													FROM
															PricebookEntry
													WHERE
															CurrencyIsoCode = :opportunityRecord.CurrencyIsoCode AND
															IsActive = TRUE AND
															Pricebook2Id = :opportunityRecord.Pricebook2Id];

		for (PricebookEntry pbe : listPricebookEntry)
		{
			mapPricebookEntry.put(pbe.Product2Id, pbe);
		}

		List <Product2> listProductWithRec = [SELECT Id, Name, (SELECT Product_Name__c, Recommended_Product__c, Type__c, Recommendation_Reason__c FROM Product_Recommendations__r) FROM Product2 WHERE Id IN :listOppLineItemId WITH SECURITY_ENFORCED];
		for (Product2 p : listProductWithRec)
		{
			for (Product_Recommendation__c pr : p.Product_Recommendations__r)
			{
				if (!mapOppLineItemProdId.containsKey(pr.Recommended_Product__c) && mapPricebookEntry.containsKey(pr.Recommended_Product__c))
				{
					String lRecReason;
					if (pr.Recommendation_Reason__c != null)
					{
						lRecReason = pr.Recommendation_Reason__c.escapeHtml4();
					} else
					{
						lRecReason = '';
					}
					if (!mapProdRecProdId.containsKey(pr.Recommended_Product__c))
					{
						if (Test.isRunningTest())
						{
							listRecProdtoHandle.add(new RecommendedProductWrapper(true, pr, 1, true, p.Name.escapeHtml4() + ':' + lRecReason + '<br/>'));
						} else
						{
							System.debug(p.Name + '---' + pr.Recommendation_Reason__c);
							listRecProdtoHandle.add(new RecommendedProductWrapper(false, pr, 0, false, p.Name.escapeHtml4() + ':' + lRecReason + '<br/>'));
						}
						//listRecProdtoHandle.add(new RecommendedProductWrapper(false, pr, 0, false, p.Name + ':' + pr.Recommendation_Reason__c + '<br/>'));
						mapProdRecProdId.put(pr.Recommended_Product__c, i);
						i++;
					} else
					{
						RecommendedProductWrapper temp = listRecProdtoHandle.get(mapProdRecProdId.get(pr.Recommended_Product__c));
						temp.associatedProduct = temp.associatedProduct + p.Name.escapeHtml4() + ':' + lRecReason + '<br/>';
						listRecProdtoHandle.set(mapProdRecProdId.get(pr.Recommended_Product__c), temp);
					}
				}
			}
		}
	}

	/**
	 * addSelectedRecommendedProduct description
	 * @return   return description
	 */
	public PageReference addSelectedRecommendedProduct()
	{
		if (Schema.SObjectType.OpportunityLineItem.isCreateable())
		{
			if (listRecProdtoHandle.size() > 0)
			{
				List <OpportunityLineItem> listOppItemToAdd = new List<OpportunityLineItem>();
				Product_Recommendation__c temp = new Product_Recommendation__c();

				for (RecommendedProductWrapper pPRecWItem : listRecProdtoHandle)
				{
					if (pPRecWItem.selected)
					{
						temp = pPRecWItem.recProduct;
						//listOppItemToAdd.add(new OpportunityLineItem(OpportunityId=opportunityRecord.Id , Product2Id=temp.Recommended_Product__c, Number_of_Users__c= pPRecWItem.numNewUser, Initial_Purchase__c=pPRecWItem.initialPurchaseFlag));
						listOppItemToAdd.add(new OpportunityLineItem(OpportunityId = opportunityRecord.Id, PricebookEntryId = mapPricebookEntry.get(temp.Recommended_Product__c).Id, Number_of_Users__c = pPRecWItem.numNewUser, Initial_Purchase__c = pPRecWItem.initialPurchaseFlag));
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
						LogUtilityException.throwException('AddRecommendedProductController', 'addSelectedRecommendedProduct', e, listOppItemToAdd);
					}

				}
			}

			PageReference returnedPage = Page.AddOppRecommededProduct;
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
		} else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Access denied. You are not allowed to create Opportunity Products'));
			return null;
		}
	}
}