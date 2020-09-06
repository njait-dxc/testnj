/**
 * @author alexvolkov
 * @date 7/1/20
 * @description 
 */
public with sharing class MYOBService_PurchasingAPI implements Queueable, Database.AllowsCallouts
{
	private static final String API_NAME = 'Purchasing API';
	private static final String BULK_API_NAME = 'Purchasing API Bulk';
	private static final String API_PATH_PURCHASES_BULK = '/api/bulkPurchases';
	private static final String API_PATH_PURCHASES_SINGLE = '/api/purchases';
	public enum BULKIFICATION_LEVEL
	{
		ORDER_ITEM, LINE_ITEM, TOP
	}

	private List<PurchaseRequest> req;
	private BULKIFICATION_LEVEL bulkLevel;

	public MYOBService_PurchasingAPI(List<PurchaseRequest> req, BULKIFICATION_LEVEL bulkLevel)
	{
		this.req = req;
		this.bulkLevel = bulkLevel;
	}

	/**
	 * @description
	 * @param pReq
	 * @param pBulkLevel
	 * @return
	 */
	public static void postPurchases(List<PurchaseRequest> pReq, BULKIFICATION_LEVEL pBulkLevel)
	{
		MYOB_Service_API__mdt myobServiceAPI = pBulkLevel == BULKIFICATION_LEVEL.ORDER_ITEM ? MYOBService.getMYOBService(API_NAME) : MYOBService.getMYOBService(BULK_API_NAME);
		MYOBService_AuthorisationAPI.AccessToken_Response accessTokenResponse = MYOBService_AuthorisationAPI.getAccessToken(myobServiceAPI.Resource_Id__c);
		Integer vCalloutLimit = Limits.getLimitCallouts() - Limits.getCallouts();
		List<PurchaseResponse> vRes = new List<PurchaseResponse>();
		if (vCalloutLimit > 0)
		{
			Integer vReqCount = 0;
			String endpoint = myobServiceAPI.Endpoint__c;
			endpoint += pBulkLevel == BULKIFICATION_LEVEL.ORDER_ITEM ? API_PATH_PURCHASES_SINGLE : API_PATH_PURCHASES_BULK;
			while (vReqCount < vCalloutLimit && !pReq.isEmpty())
			{
				if (pBulkLevel == BULKIFICATION_LEVEL.TOP)
				{
					vRes.add((PurchaseResponse)JSON.deserialize(executeCallout(endpoint, accessTokenResponse.access_token, JSON.serialize(pReq[0], true)), PurchaseResponse.class));
					vReqCount++;
				}
				else
				{
					//Have to clone Purchase Request as to not make changes to initial parameters
					PurchaseRequest vRequest = new PurchaseRequest();
					vRequest.data = new PurchaseRequestData();
					vRequest.data.attributes = new PurchaseRequestDataAttributes();
					vRequest.data.attributes.sourceInitiative = pReq[0].data.attributes.sourceInitiative;
					vRequest.data.attributes.account = pReq[0].data.attributes.account;
					vRequest.data.attributes.billingAccount = pReq[0].data.attributes.billingAccount; //change made by NJ on 23012020

					
					while (vReqCount < vCalloutLimit && !pReq[0].data.attributes.products.isEmpty())
					{
						PurchaseProduct vProd = pReq[0].data.attributes.products[0];
						vRequest.data.attributes.products = new List<PurchaseProduct>
						{
								vProd
						};
						//PurchaseRequestProduct vReqProd = pReq[0].data.attributes.products[0].clone();
						if (pBulkLevel == BULKIFICATION_LEVEL.LINE_ITEM)
						{
							vRequest.data.type = 'bulkPurchases';
							vRequest.data.attributes.account.name = vProd.name;
							vRequest.data.attributes.referringAccount = pReq[0].data.attributes.referringAccount; //change made by NJ on 23012020
							PurchaseResponse lSingleRes = new PurchaseResponse();
							try {
								lSingleRes = (PurchaseResponse) JSON.deserialize(executeCallout(endpoint, accessTokenResponse.access_token, JSON.serialize(vRequest, true)), PurchaseResponse.class);
							}
							catch (Exception e)
							{
								LogUtilityException.throwException('MYOBService_PurchasingAPI','post bulk purchase',e, new List<String>{'error processing bulk purchase request'});
							}
							lSingleRes.parentId = pReq[0].parentId;
							for (PurchaseResponseData prd : lSingleRes.data)
							{
								for (PurchaseProduct pp : prd.attributes.products)
								{
									pp.lineItemId = vProd.lineItemId;
								}
							}
							vRes.add(lSingleRes);
							vReqCount++;
						}
						else if (pBulkLevel == BULKIFICATION_LEVEL.ORDER_ITEM)
						{
							vRequest.data.type = 'purchases';
							vRequest.data.attributes.account.id = pReq[0].data.attributes.billingAccount.id;
							while (vReqCount < vCalloutLimit && vProd.quantity > 0)
							{
								PurchaseResponse lSingleRes = new PurchaseResponse();
								try {
									if(!Test.isRunningTest()) {
										PurchaseResponseData lSingleResData = ((PurchaseResponseSingleItem) JSON.deserialize(executeCallout(endpoint, accessTokenResponse.access_token, JSON.serialize(vRequest, true)), PurchaseResponseSingleItem.class)).data;
										lSingleResData.attributes.products[0].lineItemId = vProd.lineItemId;
										lSingleRes.data = new List<PurchaseResponseData>{lSingleResData};
									}
									else {
										lSingleRes = (PurchaseResponse) JSON.deserialize(executeCallout(endpoint, accessTokenResponse.access_token, JSON.serialize(vRequest, true)), PurchaseResponse.class);
									}
								}
								catch(Exception e)
								{
									LogUtilityException.throwException('MYOBService_PurchasingAPI','post single purchase',e, new List<String>{'error processing single purchase request'});
								}

								lSingleRes.parentId = pReq[0].parentId;
								for (PurchaseResponseData prd : lSingleRes.data)
								{
									for (PurchaseProduct pp : prd.attributes.products)
									{
										pp.lineItemId = vProd.lineItemId;
									}
								}
								vRes.add(lSingleRes);
								vReqCount++;
								vProd.quantity--;
							}
						}
						if (pBulkLevel == BULKIFICATION_LEVEL.LINE_ITEM || vProd.quantity == 0)
						{
							pReq[0].data.attributes.products.remove(0);
						}
					}
				}
				if (pBulkLevel == BULKIFICATION_LEVEL.TOP || pReq[0].data.attributes.products.isEmpty())
				{
					pReq.remove(0);
				}
			}
		}
		APICallLogger.insertLogs();
		if (!vRes.isEmpty())
		{
			List<Order_Item__c> vOrderItems = new List<Order_Item__c>();
			Set<Id> optyLineIds = new Set<Id>(); // AB 24/1/2020 added for bulk purchase Ids logic
			Map<String,String> bulkIds = new Map<String, String>(); // // AB 24/1/2020 added for bulk purchase Ids logic
			for (PurchaseResponse pr : vRes)
			{
				for (PurchaseResponseData prd: pr.data)
				{
					System.debug('bulk purchase id from meta is'+ prd.meta.purchaseBatchId);
					for (PurchaseProduct pp: prd.attributes.products)
					{
						vOrderItems.add(new Order_Item__c(Opportunity__c = pr.parentId, Opportunity_Line_Item_Id__c = pp.lineItemId, Status__c = 'Pending',
								Product_Instance_ID__c = pp.productInstanceId, Serial_Number__c = pp.serialNumber, Purchase_ID__c = prd.id, Link__c = prd.links.self, File_Name__c = prd.attributes.account.name));

						// AB 24/1/2020 added for bulk purchase Ids logic
						optyLineIds.add(pp.lineItemId);
						bulkIds.put(pp.lineItemId,prd.meta.purchaseBatchId);

					}
				}


			}
			try {
				Database.insert(vOrderItems);
				//AB 24/1/2020 - call method to update the bulk purchase Ids from the response on opty Line Items
				updateBulkPurchaseIds(bulkIds, optyLineIds);
			}
			catch(Exception e)
			{
				LogUtilityException.throwException('MYOBService_PurchasingAPI','error creating OrderItems/updating purchaseId',e, new List<String>{'error creating OrderItems/updating purchaseId'});
			}
		}
		if (!pReq.isEmpty())
		{
			System.enqueueJob(new MYOBService_PurchasingAPI(pReq, pBulkLevel));
		}
		//return vRes;
	}

	//AB 24/1/2020 - new method added to update the bulk purchase Ids on the opty line items.
	private static void updateBulkPurchaseIds(Map<String, String> bulkIds, Set<Id> optyLineItemIds)
	{
		List<OpportunityLineItem> optyLineItems = [SELECT Id,Bulk_Purchase_Id__c FROM OpportunityLineItem WHERE Id IN:optyLineItemIds];
		for (OpportunityLineItem opl : optyLineItems)
		{
			opl.Bulk_Purchase_Id__c = bulkIds.get(opl.Id);
			opl.Provisioning_Status__c = 'In Progress';
		}
		Database.update(optyLineItems);
	}

	private static String executeCallout(String pEndpoint, String pAccessToken, String pRequest)
	{
		HttpRequest httpRequest = new HttpRequest();
		httpRequest.setMethod('POST');
		httpRequest.setTimeout(30000);
		httpRequest.setEndpoint(pEndpoint);
		Map <String, String> requestHeaders = new Map <String, String>();
		requestHeaders.put('X-MYOBAPI-VERSION', 'v2');
		requestHeaders.put('Content-Type', 'application/json');
		//requestHeaders.put('Accept', 'application/json');
		requestHeaders.put('Authorization', 'Bearer ' + pAccessToken);
		for (String key : requestHeaders.keySet())
		{
			httpRequest.setHeader(key, requestHeaders.get(key));
		}
		httpRequest.setBody(pRequest);
		System.debug('RequestBody'+pRequest);
		HttpResponse httpResponse = APICallLogger.send(httpRequest, requestHeaders);
		System.debug('ResponseBody'+httpResponse.getBody());
		return httpResponse.getBody();
	}

	public class PurchaseRequest
	{
		public Id parentId;
		public PurchaseRequestData data;
	}

	public class PurchaseRequestData
	{
		public String type;
		public PurchaseRequestDataAttributes attributes;
	}

	public class PurchaseRequestDataAttributes
	{
		public String sourceInitiative;
		public List<PurchaseProduct> products;
		public PurchaseAccount account;
		public PurchaseBillingAccount billingAccount;
		public PurchaseReferringAccount referringAccount;
	}

	public class PurchaseProduct
	{
		public Integer productId;
		public Integer quantity;
		public String dealId;
		public String productInstanceId;
		public String serialNumber;
		public Id lineItemId;
		public String name;
	}

	public class PurchaseAccount
	{
		public String name;
		public String id;
		public String legalEntity;
		public PurchaseContact contact;
	}

	public class PurchaseBillingAccount
	{
		public String id;
		public PurchaseContact billingContact;
		public PaymentProfile paymentProfile;
	}

	public class PaymentProfile
	{
		public String id;
	}

	public class PurchaseReferringAccount
	{
		public String id;
		public PurchaseContact referringContact;
	}

	public class PurchaseContact
	{
		public String id;
		public String emailId;
		public String firstName;
		public String lastName;
		public String identityId;
		public String phoneNumber;
		public Boolean doNotEmail;
		public Boolean sendPromotions;
		public Boolean partnerPromotions;
	}

	public class PurchaseResponse
	{
		public List<PurchaseResponseData> data;
		public Id parentId;
	}

	public class PurchaseResponseSingleItem
	{
		public PurchaseResponseData data;
	}

	private class PurchaseResponseData
	{
		public String id;
		public String type;
		public PurchaseResponseDataAttributes attributes;
		public PurchaseResponseDataLinks links;
		public PurchaseResponseDataMeta	meta;
	}

	private class PurchaseResponseDataAttributes
	{
		public String sourceInitiative;
		public List<PurchaseProduct> products;
		public PurchaseAccount account;
		public PurchaseBillingAccount billingAccount;
		public PurchaseReferringAccount referringAccount;
	}

	private class PurchaseResponseDataLinks
	{
		public String self;
	}

	private class PurchaseResponseDataMeta
	{
		public String purchaseBatchId;
        //public String newProductPurchase;
	}

	public void execute(QueueableContext context)
	{
		postPurchases(req, bulkLevel);
	}
}