({
    doInit: function(component, event, helper) {
        //Setting variable values for unit price and total price
        var netprice = component.get("v.singleRec.netPrice");
        console.log(netprice);
        netprice = netprice.toFixed(2);
        component.set("v.unitPrice", netprice);
        var totalNetPrice = component.get("v.singleRec.totalNetPrice");
        console.log(totalNetPrice);
        totalNetPrice = totalNetPrice.toFixed(2);
        component.set("v.totalPrice", totalNetPrice);
        var exGSTPrice = component.get("v.singleRec.priceExclGST");
        console.log(totalNetPrice);
        if(exGSTPrice == null || exGSTPrice == '')
        {
            exGSTPrice = 0;
        }
        exGSTPrice = exGSTPrice.toFixed(2);
        component.set("v.singleRec.priceExclGST", exGSTPrice);
    },
    inlineEditQty : function(component,event,helper){
        // show the name edit field popup
        component.set("v.qtyEditMode", true);
        // after the 100 millisecond set focus to input field
        setTimeout(function(){
            component.find("inputId").focus();
        }, 100);
    },
    inlineEditPromoCode : function(component,event,helper){
        helper.editPromoCode(component,event, helper);
    },
    onQtyChange : function(component,event,helper){
        var qty = component.get("v.singleRec.quantity");
        let qtyRestriction = component.get("v.singleRec.quantityRestriction");
        let optyType = component.get("v.singleRec.oppType");
        let optyRecType = component.get("v.singleRec.oppRecordType");
        console.log(optyType);
        console.log(qtyRestriction);
        console.log(optyRecType);
        console.log(qty);
        /* Quantity validation only for opportunity type "Wholesale" edit by Ankit and Ruchi*/
        /*Opportunity record Type is included in custom metadeta record and checked for quantity restiction crietria for direct Sales initiative by Ruchi & Ankit*/
        
        if (( qtyRestriction != null && qtyRestriction != "") && ((qty < 0) || (qtyRestriction > 0 && qtyRestriction < qty)))
        {
            var errorToastEvent = $A.get("e.force:showToast");
         let msg = qty < 0 ? "Quantity cannot be less than zero" : "Quantity for this product is restricted to " + qtyRestriction + " items";
var errorToastEvent = $A.get("e.force:showToast");
            errorToastEvent.setParams({
                "title": "Error",
                "message": msg,
                "type": "error",
                "mode": "sticky"
            });
            errorToastEvent.fire();
    }


        else{
            component.set("v.showSaveCancelBtn",true);
            var netprice = component.get("v.unitPrice");
            //Ankit Bhardwaj 29/4/2020: Changed the condition from (netprice === 0.00) to (netprice <= 0.00) as it was never executing the if condition
            if(netprice <= 0.00){
                component.set('v.processing', !component.get('v.processing'));
                helper.getUnitPrice(component,event, helper);
            }else{
                netprice = netprice * component.get("v.singleRec.quantity");
                netprice = netprice.toFixed(2);
                component.set("v.totalPrice",netprice);
            }
        }
        },
    onPromoCodeChange : function(component,event,helper){
        // if picklist value change,
        // then show save and cancel button by set attribute to true
        component.set("v.showSaveCancelBtn",true);
        component.set('v.processing', !component.get('v.processing'));
        helper.getUnitPrice(component,event, helper);
        var tncMap = component.get("v.promoCodeWrapperMap");
        console.log(tncMap.length);
        console.log(tncMap[component.get("v.singleRec.promoCode")]);
        component.set("v.singleRec.tnc",tncMap[component.get("v.singleRec.promoCode")]);
    },
    closeQtyBox : function (component, event, helper) {
        // on focus out, close the input section by setting the 'qtyEditMode' att. as false
        component.set("v.qtyEditMode", false);
    },
    closePromoCodeBox : function (component, event, helper) {
        // on focus out, close the input section by setting the 'prmoEditMode' att. as false
        component.set("v.prmoEditMode", false);
    },
})