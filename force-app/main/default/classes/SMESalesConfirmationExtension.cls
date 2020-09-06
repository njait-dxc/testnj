public inherited sharing class SMESalesConfirmationExtension {
    ApexPages.StandardController stdCtrl;
    public Opportunity opp { get; set; }
    public Map <String, List<Order_Item__c>> mapOrderItem { get;set;}
    public List <OpportunityLineItem> listOppLineItems { get;set;}
    
    public SMESalesConfirmationExtension(ApexPages.StandardController controller)
    {
        if (!Test.isRunningTest()){controller.addFields(new List<String>{'Id'});}
        System.debug('Initial Controller');
        this.stdCtrl = controller;
        opp = (Opportunity) stdCtrl.getRecord();
                listOppLineItems = new List <OpportunityLineItem>();
        listOppLineItems = [SELECT Id, Product2.Name, Quantity,Initial_Purchase_Price_Ex_GST__c,UnitPrice,Duration__c,FreePeriod__c FROM OpportunityLineItem WHERE OpportunityId =:opp.Id ];
        
        mapOrderItem = new map<String, List<Order_Item__c>>();
        
        //Order_Item__c[] listOrderItem = [SELECT Id, File_Name__c, Link__c, Opportunity__c, Opportunity_Line_Item_Id__c, Product_Instance_ID__c, Purchase_ID__c, Serial_Number__c, Status__c FROM Order_Item__c WHERE Opportunity__c =:opp.Id AND (NOT File_Name__c LIKE '%AccountRight%') ];
        Order_Item__c[] listOrderItem = [SELECT Id, File_Name__c, Link__c, Opportunity__c, Opportunity_Line_Item_Id__c, Product_Instance_ID__c, Purchase_ID__c, Serial_Number__c, Status__c FROM Order_Item__c WHERE Opportunity__c =:opp.Id ];
        
        for(Order_Item__c temOrderItem: listOrderItem) 
        {
            String oppLinItemId = (String)temOrderItem.get('Opportunity_Line_Item_Id__c');
            if(!mapOrderItem.containsKey(oppLinItemId)) 
            {
              mapOrderItem.put(oppLinItemId, new Order_Item__c[0]);
            }
            mapOrderItem.get(oppLinItemId).add(temOrderItem);
        }

    }

    public Integer SizeOfMap { get { return mapOrderItem .size(); } }
}