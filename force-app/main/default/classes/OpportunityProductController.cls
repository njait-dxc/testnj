public class OpportunityProductController {
    
    public void init(OpportunityLineItem oli) {
        oli.Initial_Purchase_Price_Ex_GST__c = oli.PB_Initial_Purchase_Price_Ex_GST__c;
        oli.Per_User_Purchase_Price_Ex_GST__c = oli.PB_Per_User_Purchase_Price_Ex_GST__c;
        oli.Excluded_for_Discounting__c = oli.PB_Excluded_for_Discounting__c;
        //Added for price increase
        if (oli.Line_Description__c == null)
        {
            oli.Line_Description__c = oli.Product_Description__c;
        }
        //Added for SFDC-23
        oli.Line_Item_Product_Type__c = oli.Product_Type__c;
        oli.Product_Name__c = oli.PB_Product_Name__c;
    }

    public void setValue(OpportunityLineItem oli) {
                
        // calculate totalListValue
        if (oli.Initial_Purchase__c) {
            oli.Total_List_Value__c = oli.Initial_Purchase_Price_Ex_GST__c + oli.Per_User_Purchase_Price_Ex_GST__c * oli.Number_of_Users__c;            
        } else {
            oli.Total_List_Value__c = oli.Per_User_Purchase_Price_Ex_GST__c * oli.Number_of_Users__c;
        }
        System.debug('oli.Id:'+oli.Id);
        System.debug('oli.Discount_Percent__c:'+oli.Discount_Percent__c);
        System.debug('oli.Discount_Value__c:'+oli.Discount_Value__c);
        
        if (oli.Discount_Percent__c == null) {
            oli.Discount_Percent__c = 0;
        }
        if (oli.Discount_Value__c == null) {
            oli.Discount_Value__c = 0;
        }        
        
        // calculate discount percent, discount value and total value
        if (oli.Discount_Percent__c == 0 && oli.Discount_Value__c == 0) { 
            oli.Discount_Value__c = oli.Total_List_Value__c;
        } else if (oli.Discount_Percent__c > 0 && oli.Discount_Value__c == 0) {
            oli.Discount_Value__c = oli.Total_List_Value__c * ( 1 - oli.Discount_Percent__c / 100);
        //Added for price increase    
        //} else if (oli.Discount_Percent__c == 0 && oli.Discount_Value__c > 0) {
        } else if (oli.Discount_Percent__c == 0 && oli.Discount_Value__c > 0 && oli.Repriced__c != true) {
            oli.Discount_Percent__c = (oli.Total_List_Value__c - oli.Discount_Value__c) / oli.Total_List_Value__c * 100;
        } else if (oli.Discount_Percent__c == 0 && oli.Discount_Value__c > 0 && oli.Repriced__c == true) {
            oli.Discount_Value__c = oli.Total_List_Value__c;
        } else if(oli.Discount_Value__c < 0){
            
        }
        else{
            oli.Discount_Value__c = oli.Total_List_Value__c * ( 1 - oli.Discount_Percent__c / 100);
        }
        
        oli.Total_Value__c = oli.Discount_Value__c;
        
        // calculate specific value        
        if (oli.Product_Type__c == 'Maintenance') {
            oli.AMV_Value__c = oli.Total_Value__c;
            oli.Services_Value__c = 0;
            oli.Software_Value__c = 0;
            if(oli.PB_Excluded_for_Discounting__c == true){
                oli.AMV_Discounted_Value__c = 0;
                oli.Total_List_Value__c = oli.Discount_Value__c;
            }else{
                oli.AMV_Discounted_Value__c = oli.Total_List_Value__c - oli.Total_Value__c;
            }
        } else if (oli.Product_Type__c == 'Consulting') {
            oli.AMV_Value__c = 0;
            oli.Services_Value__c = oli.Total_Value__c;
            oli.Software_Value__c = 0;
            oli.Services_Discounted_Value__c = oli.Total_List_Value__c - oli.Total_Value__c;
        } else if (oli.Product_Type__c == 'Software') {
            oli.AMV_Value__c = 0;
            oli.Services_Value__c = 0;
            oli.Software_Value__c = oli.Total_Value__c;
            oli.Software_Discounted_Value__c = oli.Total_List_Value__c - oli.Total_Value__c;
        } 
        
        // calculate GST
        Double gstPercent = 0;
        for (GST__c gst : GST__c.getAll().values()) {
            if (gst.Currency_Iso_Code__c == oli.CurrencyIsoCode) {
                gstPercent = gst.GST_Percent__c / 100;
            }
        }
        
        oli.Total_Value_Inc_GST__c = oli.Total_Value__c * (1 + gstPercent);
        oli.Discount_Value_inc_GST__c = oli.Discount_Value__c * ( 1 + gstPercent);
        oli.Total_List_Value_Inc_GST__c = oli.Total_List_Value__c * (1 + gstPercent);
        oli.AMV_Value_Inc_GST__c = oli.AMV_Value__c * ( 1 + gstPercent);
        oli.Services_Value_Inc_GST__c = oli.Services_Value__c * ( 1 + gstPercent);
        oli.Software_Value_Inc_GST__c = oli.Software_Value__c * ( 1 + gstPercent);  
        //Added for price increase 
        oli.Repriced__c = false;
    }

}