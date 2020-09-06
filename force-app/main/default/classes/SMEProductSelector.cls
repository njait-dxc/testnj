/**
 * @author
 * @date
 * @description This class is a controller to SMEProductSelectorComponent and SMEProductSelectorInlineEditComponent lightning component
 */

public class SMEProductSelector
{
	/**
	* @param oppId
	* @return
	* @description This method is executed on initialisation of SMEProductSelectorComponent
	* Method fetches existing Line items if there are any with the Opportunity(Opportunity Id passed as parameter)
	* Rest of the products are fetched from the 'SME Solution Sales Processing Price book' Pricebook
	* It returns the list of existing line items and the products from pricebook as a  wrapper list
	*/
	public static string opp_record_type;
	public static string opp_type;
	@AuraEnabled
	public static List<SMEProductWrapperClass> getOpportunityLineItems(Id oppId)
	{
		Map<String, OpportunityLineItem> productNameToOppProductmap = new Map<String, OpportunityLineItem>();
		List<SMEProductWrapperClass> lineItems = new List<SMEProductWrapperClass>();
		Opportunity opportunityRecord = getOpportunityRecord(oppId);
		Map<String, Id> productNameToIdMap = new Map<String, Id>();
		String archieAccountId;
		//opp_record_type = opportunityRecord.Record_Type_Name__c;
		String pricebookName = getPricebookName();
		System.debug(pricebookName);
		System.debug(opp_record_type);
		System.debug(opp_type);

		//Fetch the Opportunity record and set the account client id if not blank
		if (opportunityRecord != null && opportunityRecord.AccountId != null &&
				opportunityRecord.Account.Client_ID__c != null && opportunityRecord.Account.Client_ID__c != '')
		{
			archieAccountId = opportunityRecord.Account.Client_ID__c;
		}

		//Get the existing line item if there are any on the opportunity
		for (OpportunityLineItem oppLineItemRec : [
				SELECT Id, PromoCode__c, Quantity, PricebookEntry.Product2.Name,
						PricebookEntry.Product2.ProductCatalogueID__c, UnitPrice,
						TotalPrice, Duration__c, FreePeriod__c,
						Initial_Purchase_Price_Ex_GST__c, Promo_Id__c,Promotion_Terms__c,Opportunity.Type
				FROM OpportunityLineItem
				WHERE OpportunityId = :oppId
				ORDER BY PricebookEntry.Product2.Name ASC NULLS LAST
		])
		{
			//Add the product name and line item map, map to ensure that already added products aren't added again from pricebook
			productNameToOppProductmap.put(oppLineItemRec.PricebookEntry.Product2.Name, oppLineItemRec);
			List<String> promoCodeList = new List<String>();
			Integer lQuantityRestriction = SETTINGS.QuantityRestrictions.get(oppLineItemRec.PricebookEntry.Product2.Name) != null ? SETTINGS.QuantityRestrictions.get(oppLineItemRec.PricebookEntry.Product2.Name) : SETTINGS.QuantityRestrictions.get(null);
			Integer maxAllowedQtyOnOpty = SETTINGS.MaxQtyOnOpty != null ? SETTINGS.MaxQtyOnOpty: 100000;
			//Add the existing line items/products in the wrapper with existing quantity, promo code & unit price
			lineItems.add(new SMEProductWrapperClass(oppLineItemRec.PricebookEntry.Product2.Name,
					Double.valueOf(oppLineItemRec.Quantity),
					oppLineItemRec.PromoCode__c, promoCodeList,
					Double.valueOf(oppLineItemRec.UnitPrice),
					Double.valueOf(oppLineItemRec.TotalPrice),
					archieAccountId,
					Integer.valueOf(oppLineItemRec.PricebookEntry.Product2.ProductCatalogueID__c),
					Integer.valueOf(oppLineItemRec.Duration__c),
					Integer.valueOf(oppLineItemRec.FreePeriod__c),
					Double.valueOf(oppLineItemRec.Initial_Purchase_Price_Ex_GST__c),
					opportunityRecord.CurrencyIsoCode,
					oppLineItemRec.Promo_Id__c,
					lQuantityRestriction,
					oppLineItemRec.Promotion_Terms__c,
					oppLineItemRec.Opportunity.Type,
                    opportunityRecord.Record_Type_Name__c,
					maxAllowedQtyOnOpty

			));
		}
		//Query the pricebook to add rest of the products which aren't already added in the wrapper class
		for (PricebookEntry priceBookEntryRec : [
				SELECT Id, Product2.Name, Product2Id, Product2.ProductCatalogueID__c
				FROM PricebookEntry
				WHERE Pricebook2.Name = :pricebookName
				AND CurrencyIsoCode = :opportunityRecord.CurrencyIsoCode
				AND IsActive = TRUE
				ORDER BY Product2.Name ASC NULLS LAST
		])
		{
			productNameToIdMap.put(priceBookEntryRec.Product2.Name, priceBookEntryRec.Id);
			List<String> promoCodeList = new List<String>();
			//If product isn't already added in the wrapper list, add them with default details
			if (!productNameToOppProductmap.containsKey(priceBookEntryRec.Product2.Name))
			{
				lineItems.add(new SMEProductWrapperClass(priceBookEntryRec.Product2.Name, 0, '',
						promoCodeList, 0, 0, archieAccountId,
						Integer.valueOf(priceBookEntryRec.Product2.ProductCatalogueID__c),
						null, null, 0, opportunityRecord.CurrencyIsoCode, null,
						SETTINGS.QuantityRestrictions.get(priceBookEntryRec.Product2.Name) != null ? SETTINGS.QuantityRestrictions.get(priceBookEntryRec.Product2.Name) : SETTINGS.QuantityRestrictions.get(null),
						'',opportunityRecord.Type,opportunityRecord.Record_Type_Name__c,
						SETTINGS.MaxQtyOnOpty != null ? SETTINGS.MaxQtyOnOpty : 100000
				));
			}
		}
		return lineItems;
	}

	/**
	* @param
	* @return
	* @description This method is executed on click of edit promo code on SMEProductSelectorInlineEditComponent component
	* Method uses wrapper class object as the parameter, uses the Archie Product Id and Archie Client Id from wrapper object
	*/
	@AuraEnabled
	public static List<promoCodeClass> getPromoCodeList(SMEProductWrapperClass wrapperRec)
	{
		List<promoCodeClass> promoCodeWrapper = new List<promoCodeClass>();
		promoCodeWrapper = getPromoCodes(wrapperRec.archieClientId, wrapperRec.archieProductId, wrapperRec.oppType, wrapperRec.oppRecordType);
		return promoCodeWrapper;
	}

	/**
	* @param
	* @return
	* @description This method is executed:
	* 1. When Quantity is changed and Unit Price is Zero i.e. fetches the best price from Archie with blank promo code
	* 2. When Promo Code is changed/selected, fetches the unit price applicable to the client using the promo code
	* Method uses wrapper class object as the parameter, uses the Archie Product Id and Archie Client Id from wrapper object
	* Method utilises Product Presentment Service to fetch the unit price
	*/
	@AuraEnabled
	public static unitPriceWrapperClass getUnitPrice(SMEProductWrapperClass wrapperRec)
	{
		//Default unit price to zero
		Double unitPrice = 0;
		Double priceExclusiveGST = 0;
		Integer duration;
		String dealId;
		Integer freePeriod;
		String promoCode = '';
		String channel = 'Salesforce';

		//Check if promo code passed is '--Select--' then treat it as blank
		if (wrapperRec.promoCode != null && wrapperRec.promoCode != '' &&
				!wrapperRec.promoCode.equalsIgnoreCase('--Select--'))
		{
			promoCode = wrapperRec.promoCode;
		}
		//Convert the archie product Id(Integer) to String
		String archieProductIdForAPI = String.valueOf(wrapperRec.archieProductId);
		//Check opty type to set correct channel for pricing service
		if(wrapperRec.oppType == 'Wholesale')
		{
			channel = 'SalesforceBulk';
		}
		//Product Presentment Service to return the productlist(Wrapper class)

		MYOBService_ProductPresentmentAPI.ProductList productList =
				MYOBService_ProductPresentmentAPI.getPromotionalPricingForAccount(wrapperRec.archieClientId, promoCode,
						new List<String>
						{
								archieProductIdForAPI
						}, channel);
		//Get the Unit price from the product list
		unitPrice = productList.data[0].attributes.myPrice.priceTaxInclusive;
		priceExclusiveGST = productList.data[0].attributes.myPrice.priceTaxExclusive;
		//System.debug(productList.data[0].attributes.deal.id);
		if (productList != null && productList.data != null && productList.data.size() > 0 &&
				productList.data[0].attributes != null && productList.data[0].attributes.deal != null)
		{
			if (productList.data[0].attributes.deal.duration != null)
			{
				duration = Integer.valueOf(productList.data[0].attributes.deal.duration);
			}
			if (productList.data[0].attributes.deal.freePeriod != null)
			{
				freePeriod = Integer.valueOf(productList.data[0].attributes.deal.freePeriod);
			}
			if (productList.data[0].attributes.deal.id != null)
			{
				dealId = String.valueOf(productList.data[0].attributes.deal.id);
			}
		}
		return new unitPriceWrapperClass(unitPrice, duration, freePeriod, priceExclusiveGST, dealId);
	}

	/**
	* @param
	* @return
	* @description This method returns the Opportunity record using the passed opportunity Id
	* Opportunity record contains Id, Currency, AccountId and Archie Client Id for the Account
	*/
	private static Opportunity getOpportunityRecord(Id opportunityId)
	{
		Opportunity opp = [
				SELECT Id, CurrencyIsoCode, AccountId, Account.Archie_Client_ID__c, Account.Client_ID__c,Type,Record_Type_Name__c
				FROM Opportunity
				WHERE Id = :opportunityId
		];
		if (opp != null)
		{
			opp_record_type = opp.Record_Type_Name__c;
			opp_type = opp.Type;
		}
		return opp;
	}

	/**
	* @param
	* @return
	* @description This method returns the Pricebook name where all the SME products are stored
	* Method uses custom metadata to retrieve the name but if custom metadata is not present then returns hard coded value
	*/
	private static String getPricebookName()
	{
		/* List<SME_Solution_Sales_Processing_Metadata__mdt> smeMetadataList = [
				SELECT DeveloperName, MasterLabel
				FROM SME_Solution_Sales_Processing_Metadata__mdt
				WHERE DeveloperName = 'PricebookName'
		];
		if (smeMetadataList != null && smeMetadataList.size() > 0 && smeMetadataList[0].MasterLabel != null &&
				smeMetadataList[0].MasterLabel != '')
		{
			return smeMetadataList[0].MasterLabel;
		} */
		return SETTINGS.PricebookName != null ? SETTINGS.PricebookName : 'SME Solution Sales Processing Price book';
	}

	private static SMESettings SETTINGS
	{
		get
		{
			if (SETTINGS == null)
			{
				SETTINGS = new SMESettings();
				SETTINGS.QuantityRestrictions = new Map<String, Integer>();
				//Custom metadata settings have to be retrieved in 2 queries as Custom Metadata doesn't support "OR"
				for (SME_Solution_Sales_Processing_Metadata__mdt smeMetadata : [SELECT DeveloperName, MasterLabel
				FROM SME_Solution_Sales_Processing_Metadata__mdt WHERE Functionality__c = 'PricebookName' AND oppRecordType__c = :opp_record_type AND oppType__c = :opp_type])
				{
					SETTINGS.PricebookName = smeMetadata.MasterLabel;
				}
				for (SME_Solution_Sales_Processing_Metadata__mdt smeMetadata : [SELECT Product__c, Integer_Value__c,Max_Num_Of_Qty_In_Opty__c
				FROM SME_Solution_Sales_Processing_Metadata__mdt
				WHERE Functionality__c = 'Product_Quantity_Restriction' AND oppRecordType__c = :opp_record_type AND oppType__c = :opp_type])
				{
					SETTINGS.QuantityRestrictions.put(smeMetadata.Product__c, (Integer) smeMetadata.Integer_Value__c);
					SETTINGS.MaxQtyOnOpty = (Integer)smeMetadata.Max_Num_Of_Qty_In_Opty__c;
				}
			}
			return SETTINGS;
		}
		private set;
	}

	private class SMESettings
	{
		String PricebookName;
		Integer MaxQtyOnOpty;
		Map<String, Integer> QuantityRestrictions;
	}

	/**
	* @param
	* @return
	* @description This method returns the list of promo codes applicable for the client for a specific product
	* Method uses archie account id and archie product id
	* Method utilises Pricing Service API to fetch the promo codes
	*/
	private static List<promoCodeClass> getPromoCodes(String archieAccountId, Integer productId, String oppType , String oppRecordType)
	{
		System.debug('ArchieAccountId'+archieAccountId);
		System.debug('ProductId'+productId);
		//List<String> promoCodes = new List<String>();
		List<promoCodeClass> promoList = new List<promoCodeClass>();
		String channel = 'Salesforce';
		//Adding default value in the list
		promoList.add(new promoCodeClass('--Select--','NA'));
		//promoList.add('--Select--');
		//API call to Pricing Service to get the list of promotion list(Wrapper Class)
		//Check opty type to set correct channel for pricing service
		if(oppType == 'Wholesale')
		{
			channel = 'SalesforceBulk';
		}
		List<MYOBService_PricingServiceAPI.Promotion> promotionList =
				MYOBService_PricingServiceAPI.getPromoCodes(archieAccountId, productId, channel);
		if (promotionList != null && promotionList.size() > 0)
		{
			//Iterate over the promotionlist wrapper object
			for (MYOBService_PricingServiceAPI.Promotion promotion : promotionList)
			{
				//If promocode isn't blank, add it in the list to return
				if (promotion.promoCode != null && promotion.promoCode != '')
				{
					promoCodeClass pm = new promoCodeClass(promotion.promoCode,promotion.promotionTerms);
					promoList.add(pm);
				}
			}
		}
		return promoList;
	}

	/**
	* @param
	* @return
	* @description This method returns saves/delete the opportunity line items
	* 1. If a new product is added, then new line item will be added
	* 2. If existing line item's quantity or promo code is changed, then existing line item record will be updated with price
	* 3. If quantity is changed to zero for a product where quantity was non-zero, line item will be deleted
	*/
	@AuraEnabled
	public static void updateOpportunityProducts(List<SMEProductWrapperClass> oppLineItem, Id oppId)
	{
		Map<String, OpportunityLineItem> productNameToOppProductmap = new Map<String, OpportunityLineItem>();
		List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
		List<OpportunityLineItem> oppLineItemListToDelete = new List<OpportunityLineItem>();
		Map<String, Id> productNameToIdMap = new Map<String, Id>();

		Opportunity opportunityRecord = getOpportunityRecord(oppId);
		System.debug(opp_record_type);
		//opp_record_type = opportunityRecord.Record_Type_Name__c;
		String pricebookName = getPricebookName();

		//Get all the pricebookentry records
		for (PricebookEntry priceBookEntryRec : [
				SELECT Id, Product2.Name, Product2Id
				FROM PricebookEntry
				WHERE Pricebook2.Name = :pricebookName
				AND CurrencyIsoCode = :opportunityRecord.CurrencyIsoCode
		])
		{
			productNameToIdMap.put(priceBookEntryRec.Product2.Name, priceBookEntryRec.Id);
		}

		//Get all existing line items for the opportunity, will be utilised to update and delete the line item
		for (OpportunityLineItem oppLineItemRec : [
				SELECT Id, PromoCode__c, Quantity, PricebookEntry.Product2.Name,
						Duration__c, FreePeriod__c,Promo_Id__c, Initial_Purchase_Price_Ex_GST__c,
						UnitPrice, TotalPrice,Promotion_Terms__c
				FROM OpportunityLineItem
				WHERE OpportunityId = :oppId
		])
		{
			productNameToOppProductmap.put(oppLineItemRec.PricebookEntry.Product2.Name, oppLineItemRec);
		}

		for (SMEProductWrapperClass wrapperObj : oppLineItem)
		{

			if (wrapperObj.productName != null && wrapperObj.productName != ''
					&& productNameToIdMap.containsKey(wrapperObj.productName))
			{
				//If product already exists in line items
				if (productNameToOppProductmap.containsKey(wrapperObj.productName))
				{
					//Fetch the existing line item record
					OpportunityLineItem opportunityLineItemRec = productNameToOppProductmap.get(wrapperObj.productName);
					//Check if quantity is changed or promo code is modified, then modify the line items else skip
					if (opportunityLineItemRec.Quantity != wrapperObj.quantity ||
							opportunityLineItemRec.PromoCode__c != wrapperObj.promoCode)
					{
						//Set the new unit price
						opportunityLineItemRec.UnitPrice = wrapperObj.netPrice;
						//Set the Price exclusive of GST
						opportunityLineItemRec.Initial_Purchase_Price_Ex_GST__c = wrapperObj.priceExclGST;
						//Set the free period and duration
						opportunityLineItemRec.Duration__c = wrapperObj.duration;
						opportunityLineItemRec.FreePeriod__c = wrapperObj.freePeriod;
						opportunityLineItemRec.Promo_Id__c = wrapperObj.dealId;
						//Set the new quantity and number of users if quantity was changed
						if (wrapperObj.quantity != opportunityLineItemRec.Quantity)
						{
							opportunityLineItemRec.Quantity = wrapperObj.quantity;
							opportunityLineItemRec.Number_of_Users__c = wrapperObj.quantity;
						}
						//Set the promo code if promo code was changed
						if (wrapperObj.promoCode != opportunityLineItemRec.PromoCode__c)
						{
							String promo = wrapperObj.promoCode;
							String promoId = wrapperObj.dealId;
							if (promo != null && promo != '' && promo.equalsIgnoreCase('--Select--'))
							{
								promo = null;
								promoId = null;
							}
							opportunityLineItemRec.PromoCode__c = promo;
							opportunityLineItemRec.Promo_Id__c = promoId;
							//AB 18/6/20 Added the logic to set promo terms
							opportunityLineItemRec.Promotion_Terms__c = wrapperObj.tnc;

						}
						//Add to delete list if updated quanitity is zero, i.e. delete, else add into upsert list
						if (wrapperObj.quantity == null || wrapperObj.quantity == 0)
						{
							oppLineItemListToDelete.add(opportunityLineItemRec);
						}
						else
						{
							oppLineItemList.add(opportunityLineItemRec);
						}
					}
					//If quantity is more than zero and product isn't already in line items
				}
				else if (wrapperObj.quantity > 0)
				{
					//Create line item record using the details from wrapper object
					OpportunityLineItem oppLineItemRec = new OpportunityLineItem();
					oppLineItemRec.OpportunityId = oppId;
					oppLineItemRec.PricebookEntryId = productNameToIdMap.get(wrapperObj.productName);
					oppLineItemRec.Quantity = wrapperObj.quantity;
					oppLineItemRec.UnitPrice = wrapperObj.netPrice;
					oppLineItemRec.Initial_Purchase_Price_Ex_GST__c = wrapperObj.priceExclGST;
					oppLineItemRec.Duration__c = wrapperObj.duration;
					oppLineItemRec.FreePeriod__c = wrapperObj.freePeriod;
					oppLineItemRec.Promo_Id__c = wrapperObj.dealId;
					//oppLineItemRec.PromoCode__c = wrapperObj.promoCode;
					oppLineItemRec.Number_of_Users__c = wrapperObj.quantity;

					String promo = wrapperObj.promoCode;
					if (promo != null && promo != '' && promo.equalsIgnoreCase('--Select--'))
					{
						promo = null;
					}
					oppLineItemRec.PromoCode__c = promo;
					//AB 18/6/20 Added the logic to set promo terms
					oppLineItemRec.Promotion_Terms__c = wrapperObj.tnc;

					oppLineItemList.add(oppLineItemRec);
				}
			}
		}
		//Flag that will let the code save the line items
		//OpportunityProductTriggerHandler.showErrorForSMEOP = false;
		TRIG_OpportunityLineItem_Handler.showErrorForSMEOP = false;
		if (oppLineItemList != null && oppLineItemList.size() > 0)
		{
			//upsert oppLineItemList;
			try
			{
				/*List<Database.UpsertResult> upsertOppLineItemsResults = */Database.upsert(oppLineItemList, true);
			} catch (Exception e)
			{
				System.debug(e.getMessage() + '---' + e.getStackTraceString());
				LogUtilityException.throwException('SMEProductSelector', 'updateOpportunityProducts', e, oppLineItemList);
			}

			Opportunity opp = new Opportunity(Id = oppId, Provisioning_Status__c = 'Submitted');
			try
			{
				/*Database.SaveResult upsertOppLineItemsResults = */Database.update(opp, true);
			} catch (Exception e)
			{
				LogUtilityException.throwException('SMEProductSelector', 'updateOpportunityProducts', e, new List<Opportunity>
				{
						opp
				});
			}
		}
		if (oppLineItemListToDelete != null && oppLineItemListToDelete.size() > 0)
		{
			//delete oppLineItemListToDelete;

			try
			{
				/*List<Database.DeleteResult> oppLineItemListToDeleteResults = */Database.delete(oppLineItemListToDelete, true);
			} catch (Exception e)
			{
				LogUtilityException.throwException('SMEProductSelector', 'updateOpportunityProducts', e, oppLineItemListToDelete);
			}

		}

	}

	//Wrapper Class to display data on the Component
	public class SMEProductWrapperClass
	{

		@AuraEnabled public String productName { get; set; }
		@AuraEnabled public Double quantity { get; set; }
		@AuraEnabled public String promoCode { get; set; }
		@AuraEnabled public List<String> promoCodeList { get; set; }
		@AuraEnabled public Double netPrice { get; set; }
		@AuraEnabled public Double priceExclGST { get; set; }
		@AuraEnabled public Double totalNetPrice { get; set; }
		@AuraEnabled public String archieClientId { get; set; }
		@AuraEnabled public Integer archieProductId { get; set; }
		@AuraEnabled public Integer duration { get; set; }
		@AuraEnabled public Integer freePeriod { get; set; }
		@AuraEnabled public String currencyISOCode { get; set; }
		@AuraEnabled public String dealId { get; set; }
		@AuraEnabled public Integer quantityRestriction { get; set;}
		@AuraEnabled public String tnc { get; set; }
		@AuraEnabled public String oppType { get; set; }
        @AuraEnabled public String oppRecordType { get; set; }
		@AuraEnabled public Integer maxAllowedQtyOnOpty { get; set; }
		//Default parameterless constructor
		public SMEProductWrapperClass()
		{

		}

		//Parametrised constructor to create wrapper object
		public SMEProductWrapperClass(String name, Double qty, String code, List<String> promoCodeList,
				Double netPrice, Double totalPrice, String clientId, Integer productId,
				Integer duration, Integer freeperiod, Double priceExclusiveGST,
				String currencyCode, String dealId, Integer quantityRestriction, String tnc, String oppType, String oppRecordType,
				Integer maxAllowedQtyOnOpty

		)
		{
			this.productName = name;
			this.quantity = qty;
			this.promoCode = code;
			this.promoCodeList = promoCodeList;
			this.netPrice = netPrice;
			this.totalNetPrice = totalPrice;
			this.archieClientId = clientId;
			this.archieProductId = productId;
			this.duration = duration;
			this.freePeriod = freeperiod;
			this.priceExclGST = priceExclusiveGST;
			this.currencyISOCode = currencyCode;
			this.dealId = dealId;
			this.quantityRestriction = quantityRestriction;
			this.tnc = tnc;
			this.oppType = oppType;
            this.oppRecordType = oppRecordType;
			this.maxAllowedQtyOnOpty = maxAllowedQtyOnOpty;
           
		}
	}

	//Wrapper class to return unit price along with duration and free period to the JS controller
	public class unitPriceWrapperClass
	{

		@AuraEnabled public Double unitPrice { get; set; }
		@AuraEnabled public Double priceExclGST { get; set; }
		@AuraEnabled public Integer duration { get; set; }
		@AuraEnabled public Integer freePeriod { get; set; }
		@AuraEnabled public String dealId { get; set; }

		public unitPriceWrapperClass(Double unitPrice, Integer duration, Integer freePeriod, Double priceExclusiveGST,String dealId)
		{
			this.unitPrice = unitPrice;
			this.duration = duration;
			this.freePeriod = freePeriod;
			this.priceExclGST = priceExclusiveGST;
			this.dealId = dealId;
		}
	}
	public class promoCodeClass
	{
		@AuraEnabled public String promoCode { get; set; }
		@AuraEnabled public String tncLink { get; set; }

		public promoCodeClass(String promoCode,String tncLink)
		{
			this.promoCode = promoCode;
			this.tncLink = tncLink;
		}
	}
}