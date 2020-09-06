public inherited sharing class CMOpportunityConsolidatedPageExtension 
{
    ApexPages.StandardController stdCtrl;
    public Opportunity opp { get; set; }
    public List <OpportunityLineItem> listOppLineItems { get;set;}
    public List <Product_Profile__c> listProductProfile {get;set;}
    public List <String> validationMessage {get;set;}
    public Map <String, String> mapValidationMessage {get;set;}
    //public List <String> warningMessage {get;set;}
    //public List <String> tipsHelpMessage {get;set;}
    public List <Opportunity_Product_Question__c> listOppConsultingQuestions{get;set;}
    public boolean disableConga {get;set;}
    public List <Case> listOppCases {get;set;}
    private List <Practice_Validation_Switch__mdt> practiceOppValidationMdt {get;set;}
    private Map <String, Practice_Validation_Switch__mdt> mapPracticeOppValidationMdt {get;set;}
   
    public CMOpportunityConsolidatedPageExtension(ApexPages.StandardController controller)
    {    
        if (!Test.isRunningTest()){controller.addFields(new List<String>{'Id','Account', 'AccountId','Account.Credit_Status__c','Onsite_Consulting__c', 'Credit_Status__c', 'Approval_Required__c', 'Approval_Status__c'});}
        //controller.addFields(new List<String>{'Id','Account', 'AccountId','Account.Credit_Status__c','Onsite_Consulting__c', 'Count_of_Travel_Product_Line_Items__c', 'Scoping_Question_Count__c', 'Credit_Status__c', 'Approval_Required__c', 'Approval_Status__c', 'Consulting_Count__c', 'Onsite_Consulting__c'});
        this.stdCtrl = controller;
        //opp = (Opportunity) stdCtrl.getRecord();
        opp = [SELECT Id, AccountId, Account.Credit_Status__c, Credit_Status__c, Approval_Required__c, Approval_Status__c, Onsite_Consulting__c FROM Opportunity WHERE Id = :controller.getId()];
        disableConga = false; 
        validationMessage = new List <String>();
        mapValidationMessage = new Map<String, String>();
        
        listOppLineItems = new List <OpportunityLineItem>();
        listOppLineItems = [SELECT Id, 
                            Number_of_Users__c,
                            Quantity,
                            Product2.Name, 
                            Product2.Delivery__c, 
                            Product2.Consulting_Question__c, 
                            Product2.Environment_Check_EC__c, 
                            Product2.Sub_Area__c,
                            Product2.Service_Type__c,
                            Product2.Delivered_By__c,
                            Product2.Additional_Requirements__c,
                            Product2.User_Recommendation__c,
                            Product2.Scope__c,
                            Product2.Historic_Licence__c,
                            Product2.Licence_Upgrade__c,
                            Product2.Data_Authority__c,
                            Product2.Maintenance_Credit_Comments__c,
                            Product2.Consulting_TL_Approval__c,
                            Product2.AU_Travel_Zones__c,
                            Product2.NZ_Travel_Zones__c,   
                            Product2.Product_Fact_Link__c,
                            Product2.Services_Sheet_LINK__c, 
                            Product2.FAQs_Matrix__c,                        
                            Line_Item_Product_Type__c,
                            Initial_Purchase__c,
                            Product2.Description
                            FROM OpportunityLineItem WHERE OpportunityId =:opp.Id ORDER BY SortOrder]; 
        
        listOppCases = new List <Case>();
        listOppCases = [SELECT Id, Subject, CaseNumber, Status, Sub_Status__c, AccountId, ContactId, Primary_Category__c, Categ__c, Sub_Category__c FROM Case WHERE Opportunity__c =:opp.Id];
        
        listOppConsultingQuestions = new List <Opportunity_Product_Question__c>();
        listOppConsultingQuestions = [SELECT Id, Type__c FROM Opportunity_Product_Question__c WHERE Opportunity__c =:opp.Id];

        listProductProfile =  new List <Product_Profile__c>();
        listProductProfile = [SELECT Id, Name, Asset_Status__c, Compliance_Users__c, Max_User_Number__c, Prod_Profile_ID__c, Product_Family__c, Product_Line__c, Product_Set__c, Quantity__c, Total_Inc_GST__c, Total_Net_Amount__c, Users__c FROM Product_Profile__c WHERE Practice_Name__c =:opp.AccountId];
              
        practiceOppValidationMdt = [SELECT 
                                    DeveloperName, 
                                    Active__c,
                                    Failure_Message__c,
                                    Success_Message__c,
                                    Validation_Message__c,
                                    Required__c,
                                    Value__c
                                    FROM Practice_Validation_Switch__mdt];    
        
        mapPracticeOppValidationMdt = new Map<String, Practice_Validation_Switch__mdt>();
        for(Practice_Validation_Switch__mdt pVS:practiceOppValidationMdt)
        {           
            mapPracticeOppValidationMdt.put(pVS.DeveloperName, pVS);
            
            switch on pVS.DeveloperName
            {
                when 'CM_Opp_Account_Credit_Status' 
                {
                    validateOppAccountCreditStatus();
                }
                when 'CM_Opp_Approval_Required' 
                {
                    validateOppApprovalStatus();
                }
                when 'CM_Opp_Open_EC_Case' 
                {
                    validateOppOpenECCase();
                }
                when 'CM_Opp_Onsite_Travel_Line_Item' 
                {
                    validateOppTravelCost(); 
                }
                when 'CM_Opp_Consulting_Question'
                {
                    validateOppConsultingQuestion();
                } 
                when 'CM_Opp_Software_Initial_Purchase'
                {
                    validateSoftwareInitialPurchase();
                }
                when 'CM_Opp_Adhoc_LineItem'
                {
                    validateAdHocLineItem();
                }
                when 'CM_Opp_Require_EC_Case'
                {
                    validateOppRequireECCase();
                }
                when 'CM_AO_AE'
                {
                    validateProductAOAE();
                }                   
            }
        }   
    }
    
    /*private void setDisableConga(Boolean toDisableConga)
    {
        if(disableConga == true)
        {
            //disableConga = true;
        }
        else if(toDisableConga == true)
        {
            disableConga = true;
        }       
    }*/

    private void setDisableConga2(String validatonRuleName, Boolean toDisableConga)
    {
        if(mapPracticeOppValidationMdt.containsKey(validatonRuleName))
        {
            if(disableConga == true)
            {
                //disableConga = true;
            }
            else if(mapPracticeOppValidationMdt.get(validatonRuleName).Required__c && toDisableConga)
            {
                disableConga = true;
            }             
        }
    }    
    
    /*private boolean getValidationSwitch (String ValidationSwitchName)
    {
        List<Support_Setting__mdt> validationSwitchList = [
                SELECT DeveloperName, Value__c
                FROM Support_Setting__mdt
                WHERE DeveloperName =: ValidationSwitchName
        ];
        
        system.debug(validationSwitchList);
      
        if (validationSwitchList != null && validationSwitchList.size() > 0)
        {
            system.debug(validationSwitchList[0] + ': ' + Boolean.valueOf(validationSwitchList[0].Value__c));
            return Boolean.valueOf(validationSwitchList[0].Value__c);
        }
        return true;        
    } */
    
    private void validateOppAccountCreditStatus()
    {
        //if(getValidationSwitch('CM_Opp_Account_Credit_Status'))
        if(mapPracticeOppValidationMdt.containsKey('CM_Opp_Account_Credit_Status'))
        {
            if(mapPracticeOppValidationMdt.get('CM_Opp_Account_Credit_Status').Active__c)
            {
                if(opp.Account.Credit_Status__c == 'Blocked')
                {
                    //validationMessage.add('Cannot proceed with the opportunity until the associated account credit status is not blocked: <b><font color="red">Failed</font></b>');
                    //validationMessage.add(mapPracticeOppValidationMdt.get('CM_Opp_Account_Credit_Status').Failure_Message__c);
                    mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Account_Credit_Status').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Account_Credit_Status').Failure_Message__c);
                    setDisableConga2('CM_Opp_Account_Credit_Status', true);
                }
                else
                {
                    //validationMessage.add('Cannot proceed with the opportunity until the associated account credit status is not blocked: <b><font color="green">Passed</font></b>');
                    //validationMessage.add(mapPracticeOppValidationMdt.get('CM_Opp_Account_Credit_Status').Success_Message__c);      
                    mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Account_Credit_Status').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Account_Credit_Status').Success_Message__c);
                    setDisableConga2('CM_Opp_Account_Credit_Status', false);
                }            
            }             
        }               
    }
    
    private void validateOppApprovalStatus()
    {
        //if(getValidationSwitch('CM_Opp_Approval_Required'))
        if(mapPracticeOppValidationMdt.containsKey('CM_Opp_Approval_Required'))
        {
            if(mapPracticeOppValidationMdt.get('CM_Opp_Approval_Required').Active__c)
            {
                if(opp.Approval_Required__c == true && opp.Approval_Status__c != 'Approved')
                {
                    //validationMessage.add('Cannot proceed with the opportunity until it is approved because of sales discount: <b><font color="red">Failed</font></b>');
                    //validationMessage.add(mapPracticeOppValidationMdt.get('CM_Opp_Approval_Required').Failure_Message__c);
                    mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Approval_Required').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Approval_Required').Failure_Message__c);
                    setDisableConga2('CM_Opp_Approval_Required', true);
                }
                else
                {
                    //validationMessage.add('Cannot proceed with the opportunity until it is approved because of sales discount: <b><font color="green">Passed</font></b>');     
                    //validationMessage.add(mapPracticeOppValidationMdt.get('CM_Opp_Approval_Required').Success_Message__c);
                    mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Approval_Required').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Approval_Required').Success_Message__c);
                    setDisableConga2('CM_Opp_Approval_Required', false);
                }                 
            }            
        }            
    }
    
    private void validateOppOpenECCase()
    {
        if(listOppCases.size() > 0 && mapPracticeOppValidationMdt.containsKey('CM_Opp_Open_EC_Case'))
        {
            boolean ECCaseMessagePopulated = false;
            String ECCaseNumber = '';
            
            if(mapPracticeOppValidationMdt.get('CM_Opp_Open_EC_Case').Active__c)
            {
                for(Case caseTemp : listOppCases)
                {
                    if(caseTemp.Primary_Category__c =='Administrative Request' && caseTemp.Categ__c == 'Technical Services Request' && caseTemp.Sub_Category__c == 'IT Assessment' && caseTemp.Status != 'Closed' && caseTemp.Subject == 'Client System Environment Check Request')
                    {
                        ECCaseMessagePopulated = true;
                        ECCaseNumber = ECCaseNumber + ' ' + caseTemp.CaseNumber;
                    } 
                }
                
                if(ECCaseMessagePopulated == true)
                {
                    //validationMessage.add('Cannot proceed with the opportunity due to open EC cases: ' + ECCaseNumber + '  <b><font color="red">Failed</font></b>');
                    //validationMessage.add(mapPracticeOppValidationMdt.get('CM_Opp_Open_EC_Case').Failure_Message__c + ECCaseNumber);
                    mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Open_EC_Case').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Open_EC_Case').Failure_Message__c + ' Open EC case:' + ECCaseNumber);
                    setDisableConga2('CM_Opp_Open_EC_Case', true);                              
                }                
                if(ECCaseMessagePopulated == false)
                {
                    //validationMessage.add(mapPracticeOppValidationMdt.get('CM_Opp_Open_EC_Case').Success_Message__c);
                    mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Open_EC_Case').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Open_EC_Case').Success_Message__c);
                    setDisableConga2('CM_Opp_Open_EC_Case', false);                              
                }                                
               
            }            
        }
        else if(listOppCases.size() == 0 && mapPracticeOppValidationMdt.containsKey('CM_Opp_Open_EC_Case'))
        {          
            //validationMessage.add(mapPracticeOppValidationMdt.get('CM_Opp_Open_EC_Case').Success_Message__c);
            mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Open_EC_Case').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Open_EC_Case').Success_Message__c);
            setDisableConga2('CM_Opp_Open_EC_Case', false);    
        }          
    }
    
    private void validateOppTravelCost()
    {
        if(mapPracticeOppValidationMdt.containsKey('CM_Opp_Onsite_Travel_Line_Item'))
        {
            if(mapPracticeOppValidationMdt.get('CM_Opp_Onsite_Travel_Line_Item').Active__c)
            {
                integer countTravelLineItem = 0;
                
                for(OpportunityLineItem lineItemTemp: listOppLineItems)
                {
                    if(lineItemTemp.Line_Item_Product_Type__c == 'Travel')
                    {
                        countTravelLineItem ++;
                    }    
                }   
                
                if((opp.Onsite_Consulting__c == 'Yes' && listOppLineItems.size() == 0) || (opp.Onsite_Consulting__c == 'Yes' && countTravelLineItem ==0))
                {
                    //validationMessage.add(mapPracticeOppValidationMdt.get('CM_Opp_Onsite_Travel_Line_Item').Failure_Message__c);
                    mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Onsite_Travel_Line_Item').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Onsite_Travel_Line_Item').Failure_Message__c);
                    setDisableConga2('CM_Opp_Onsite_Travel_Line_Item', true);                                        
                }
                else
                {
                    //validationMessage.add(mapPracticeOppValidationMdt.get('CM_Opp_Onsite_Travel_Line_Item').Success_Message__c);
                    mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Onsite_Travel_Line_Item').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Onsite_Travel_Line_Item').Success_Message__c);
                    setDisableConga2('CM_Opp_Onsite_Travel_Line_Item', false);
                }                
            }
        }
    }
    
    private void validateOppConsultingQuestion()
    {
        if(mapPracticeOppValidationMdt.containsKey('CM_Opp_Consulting_Question'))
        {
            if(mapPracticeOppValidationMdt.get('CM_Opp_Consulting_Question').Active__c)
            {
                if(listOppLineItems.size() > 0)
                {
                    Boolean blnConsultingQuestionRequired = false;
                    
                    for(OpportunityLineItem lineItemTemp: listOppLineItems)
                    {
                        if(lineItemTemp.Product2.Consulting_Question__c == 'Y')
                        {
                             blnConsultingQuestionRequired = true;
                             break;
                        }    
                    }                     
                
                    if(listOppConsultingQuestions.size() == 0  && blnConsultingQuestionRequired)
                    {
                        //validationMessage.add(mapPracticeOppValidationMdt.get('CM_Opp_Consulting_Question').Failure_Message__c);
                        mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Consulting_Question').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Consulting_Question').Failure_Message__c);
                        setDisableConga2('CM_Opp_Consulting_Question', true);                    
                    }
                    else
                    {                    
                        //validationMessage.add(mapPracticeOppValidationMdt.get('CM_Opp_Consulting_Question').Success_Message__c);
                        mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Consulting_Question').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Consulting_Question').Success_Message__c);
                        setDisableConga2('CM_Opp_Consulting_Question', false);
                    } 
                 }   
            }
        }
    }
    
    private void validateSoftwareInitialPurchase()
    {
        if(mapPracticeOppValidationMdt.containsKey('CM_Opp_Software_Initial_Purchase'))
        {
            if(mapPracticeOppValidationMdt.get('CM_Opp_Software_Initial_Purchase').Active__c)
            {
                if(listOppLineItems.size() > 0)
                {      
                    boolean blnSoftwareInitialPurchase = false;
                    
                    for(OpportunityLineItem lineItemTemp: listOppLineItems)
                    {
                        if(lineItemTemp.Line_Item_Product_Type__c == 'Software' && lineItemTemp.Initial_Purchase__c == false)
                        {
                             blnSoftwareInitialPurchase = true;
                             break;
                        }    
                    }
                    
                    if(blnSoftwareInitialPurchase)
                    {
                        mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Software_Initial_Purchase').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Software_Initial_Purchase').Success_Message__c);
                    }
                }
            }
        }
    }
    
    private void validateAdHocLineItem()
    {
        if(mapPracticeOppValidationMdt.containsKey('CM_Opp_Adhoc_LineItem'))
        {
            if(mapPracticeOppValidationMdt.get('CM_Opp_Adhoc_LineItem').Active__c)
            {
                if(listOppLineItems.size() > 0)
                {      
                    boolean blnAdHocLineItem= false;
                    
                    for(OpportunityLineItem lineItemTemp: listOppLineItems)
                    {
                        if(lineItemTemp.Product2.Description != null)
                        {
                            if(lineItemTemp.Product2.Description.contains('Adhoc Consulting'))
                            {
                                 blnAdHocLineItem = true;
                                 break;
                            }                             
                        }
                    }
                    
                    if(blnAdHocLineItem)
                    {
                        mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Adhoc_LineItem').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Adhoc_LineItem').Success_Message__c);
                    }
                }
            }
        }
    }  
    
    private void validateOppRequireECCase()
    {
        system.debug('1');
        if(mapPracticeOppValidationMdt.containsKey('CM_Opp_Require_EC_Case'))
        {            
            system.debug('2');
            if(mapPracticeOppValidationMdt.get('CM_Opp_Require_EC_Case').Active__c)
            {
                boolean blnHavingECCase = false;
                system.debug('3');
                if(listOppLineItems.size() > 0)
                {
                    Boolean blnECRequired = false;
                    system.debug('4');
                    for(OpportunityLineItem lineItemTemp: listOppLineItems)
                    {
                        if(lineItemTemp.Product2.Environment_Check_EC__c == 'Y')
                        {
                             blnECRequired = true;
                             system.debug('5');
                             break;
                        }    
                    } 
                
                    for(Case caseTemp : listOppCases)
                    {
                        if(caseTemp.Primary_Category__c =='Administrative Request' && caseTemp.Categ__c == 'Technical Services Request' && caseTemp.Sub_Category__c == 'IT Assessment' && caseTemp.Subject == 'Client System Environment Check Request')
                        {
                            blnHavingECCase = true;
                        } 
                    }
                    system.debug('6');
                    system.debug('blnHavingECCase:'+blnHavingECCase);
                    system.debug('blnECRequired:'+blnECRequired);
                    if((blnHavingECCase && blnECRequired) || (!blnECRequired && !blnHavingECCase))
                    {
                        system.debug('7');
                        mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Require_EC_Case').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Require_EC_Case').Success_Message__c);
                        setDisableConga2('CM_Opp_Require_EC_Case', false); 
                    }                
                    if(blnECRequired && !blnHavingECCase)
                    {
                        system.debug('8');
                        mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Require_EC_Case').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Require_EC_Case').Failure_Message__c);
                        setDisableConga2('CM_Opp_Require_EC_Case', true);    
                    }                                
                }
                else
                {
                    system.debug('9');
                    mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_Opp_Require_EC_Case').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_Opp_Require_EC_Case').Success_Message__c);
                    setDisableConga2('CM_Opp_Require_EC_Case', false);   
                    system.debug('listOppLineItems.size() ' + listOppLineItems.size() );
                }
            }            
        }         
    }

    private void validateProductAOAE()
    {
        if(mapPracticeOppValidationMdt.containsKey('CM_AO_AE'))
        {
            if(mapPracticeOppValidationMdt.get('CM_AO_AE').Active__c)
            {
                if(listOppLineItems.size() > 0)
                {      
                    boolean blnNewAOLineItem = false;
                    boolean blnNewAELineItem = false;
                    boolean blnExistingAOProductProfile = false;
                    boolean blnExistingAEProductProfile = false;
                    system.debug('size > 0');
                    for(OpportunityLineItem lineItemTemp: listOppLineItems)
                    {
                        if(!Test.isRunningTest())
                        {
                            if(lineItemTemp.Product2.Name.startsWith('AO') || lineItemTemp.Product2.Name.startsWith('MYOB AO'))
                            {
                                system.debug('Yes for new AO');
                                blnNewAOLineItem = true;
                            }
                            if(lineItemTemp.Product2.Name.startsWith('AE') || lineItemTemp.Product2.Name.startsWith('MYOB AE'))
                            {
                                system.debug('Yes for new AE');
                                blnNewAELineItem = true;
                            }
                        }
                    }
                    
                    if(listProductProfile.size()>0)
                    {
                        for(Product_Profile__c pp : listProductProfile)
                        {
                            if(pp.Name.startsWith('AE') || pp.Name.startsWith('MYOB AE'))
                            {
                                system.debug('Yes for existing AE');
                                blnExistingAEProductProfile = true;
                            }
                            if(pp.Name.startsWith('AO') || pp.Name.startsWith('MYOB AO'))
                            {
                                system.debug('Yes for existing AO');
                                blnExistingAOProductProfile = true;
                            }                            
                        }
                    }
                    system.debug('blnNewAOLineItem:'+ blnNewAOLineItem);
                    system.debug('blnNewAELineItem:'+ blnNewAELineItem);
                    system.debug('blnExistingAOProductProfile:'+ blnExistingAOProductProfile);
                    system.debug('blnExistingAEProductProfile:'+ blnExistingAEProductProfile);
                    
                    if((blnNewAOLineItem && blnExistingAEProductProfile && !blnExistingAOProductProfile) || (blnNewAELineItem && blnExistingAOProductProfile && !blnExistingAEProductProfile))
                    {
                        mapValidationMessage.put(mapPracticeOppValidationMdt.get('CM_AO_AE').Validation_Message__c, mapPracticeOppValidationMdt.get('CM_AO_AE').Success_Message__c);
                    }
                }
            }
        }
    }     
}