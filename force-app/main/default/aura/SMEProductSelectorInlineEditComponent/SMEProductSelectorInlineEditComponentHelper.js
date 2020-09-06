({
    getUnitPrice: function (component, event, helper) {
        var action = component.get("c.getUnitPrice");
        action.setParams({
            "wrapperRec": component.get("v.singleRec")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                component.set('v.singleRec.duration', returnVal.duration);
                component.set('v.singleRec.freePeriod', returnVal.freePeriod);
                component.set('v.singleRec.dealId', returnVal.dealId);
                var priceExclGST = returnVal.priceExclGST;
                priceExclGST = priceExclGST.toFixed(2);
                component.set('v.singleRec.priceExclGST', priceExclGST);
                var data = returnVal.unitPrice;
                data = data.toFixed(2);
                component.set('v.unitPrice', data);
                component.set('v.singleRec.netPrice', data);
                var totalNetPrice = data * component.get("v.singleRec.quantity");
                totalNetPrice = totalNetPrice.toFixed(2);
                component.set("v.totalPrice", totalNetPrice);
                component.set('v.processing', !component.get('v.processing'));
            } else if (state === "ERROR") {
                var errorToastEvent = $A.get("e.force:showToast");
                errorToastEvent.setParams({
                    "title": "Error",
                    "message": "An error occured while retrieving the sale price for this product. Please contact your System Administrator.",
                    "type": "error",
                    "mode": "sticky"
                });
                component.set('v.processing', !component.get('v.processing'));
                errorToastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    editPromoCode: function (component, event, helper) {

        var flagForPromoCodeList = component.get("v.retrievePromoCodeList");
        var promoCodeKeyMap = component.get("v.promoCodeWrapperMap");
        if (flagForPromoCodeList) {
            component.set('v.loaded', !component.get('v.loaded'));
            component.set("v.retrievePromoCodeList", false);
            var action = component.get("c.getPromoCodeList");
            action.setParams({
                'wrapperRec': component.get("v.singleRec")
            });
            action.setCallback(this, function (response) {

                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    var promoList = [];
                    // set wrapperList list with return value from server.
					for(var i=0; i < storeResponse.length; i++) {
					promoList.push(storeResponse[i].promoCode);
                        promoCodeKeyMap[storeResponse[i].promoCode] = storeResponse[i].tncLink;
    				}
                    console.log(promoCodeKeyMap);
                    component.set("v.promoCodePicklistOpts", promoList);
                    component.set("v.prmoEditMode", true);

                    setTimeout(function () {
                        component.find("oppPromoCode").focus();
                    }, 0);
                } else if (state === "ERROR") {
                    var errorToastEvent = $A.get("e.force:showToast");
                    errorToastEvent.setParams({
                        "title": "Error",
                        "message": "An error occured while retrieving the promo codes for this product. Please contact your System Administrator.",
                        "type": "error",
                        "mode": "sticky"
                    });
                    errorToastEvent.fire();
                }
                component.set('v.loaded', !component.get('v.loaded'));
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.prmoEditMode", true);
            setTimeout(function () {
                component.find("oppPromoCode").focus();
            }, 100);
        }
    },
})