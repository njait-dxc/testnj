({
    myAction: function (component, event, helper) {
    },

    doInit: function (component, event, helper) {
        var action = component.get("c.getCurrentCommission");
        action.setCallback(this, function (response) {
            var commissionResult = response.getReturnValue();
            component.set("v.OTE", commissionResult.Monthly_OTE__c);
            component.set("v.PLOTE", commissionResult.PL_OTE__c);
            component.set("v.NetRevenuePercentage", commissionResult.Net_Revenue_Percentage__c);
            component.set("v.UnitOTEPercentage", 0.7);
            component.set("v.UniqueTargetOTEPercentage", 0.3);
            component.set("v.CommissionUnit", 0);
            component.set("v.CommissionUnique", 0);
            component.set("v.CommissionPL", 0);
            component.set("v.CommissionRevenue", 0);
            component.set("v.CommissionEarning", 0);
            component.set("v.UnitTarget", commissionResult.Units_Target__c);
            component.set("v.UnitActual", commissionResult.Units_Achieved__c);
            component.set("v.UniqueRefTarget", commissionResult.Unique_Target__c);
            component.set("v.UniqueRefActual", commissionResult.Unique_Achieved__c);
            component.set("v.DIYTarget", commissionResult.DIY_Target__c);
            component.set("v.DIYActual", commissionResult.DIY_Achieved__c);
            component.set("v.PLTarget", commissionResult.PL_Target__c);
            component.set("v.PLActual", commissionResult.PL_Actual__c);
            component.set("v.NetBookingTarget", commissionResult.Net_Bookings_Target__c);
            component.set("v.NetBookingActual", commissionResult.Net_Bookings_Actual__c);
            component.set("v.NetRevenueActual", commissionResult.Net_Revenue__c);
        });
        $A.enqueueAction(action);

        var actionUser = component.get("c.getCurrentUser");
        actionUser.setCallback(this, function (response) {
            var userResult = response.getReturnValue();
            if (userResult.Work_Type__c == null) {
                component.set("v.WorkType", "PM");
            } else {
                component.set("v.WorkType", userResult.Work_Type__c);
            }

            component.set("v.SubChannel", userResult.Sub_Channel__c);
        })
        $A.enqueueAction(actionUser);
    },

    calculate: function (component, event, helper) {
        //var workType = component.get("v.WorkType");
        //var channel = component.find("InputSelectSingle");	

        var OTE = component.get("v.OTE");
        /*var PLOTE = component.get("v.PLOTE");
        var NetRevenuePercentage = component.get("v.NetRevenuePercentage");
        var UnitOTEPercentage = component.get("v.UnitOTEPercentage");
        var UniqueTargetOTEPercentage = component.get("v.UniqueTargetOTEPercentage");
        */

        var UnitTarget = component.get("v.UnitTarget");
        var UnitActual = component.get("v.UnitActual");
        /*
        var UniqueRefTarget = component.get("v.UniqueRefTarget");
        var UniqueRefActual = component.get("v.UniqueRefActual");
        var DIYTarget = component.get("v.DIYTarget");
        var DIYActual = component.get("v.DIYActual");
        var PLTarget = component.get("v.PLTarget");
        var PLActual = component.get("v.PLActual");
        var NetBookingTarget = component.get("v.NetBookingTarget");
        var NetBookingActual = component.get("v.NetBookingActual");
        var NetRevenueActual = component.get("v.NetRevenueActual"); 
        */
        var Multiplier = component.get("v.Multiplier");

        //var CommissionUit = 0;
        //var CommissionUnique = 0;
        //var CommissionPL = 0;
        //var CommissionRevenue = 0;
        var CommissionEarning = 0;

        if (Multiplier >= 2.5) {
            Multiplier = 2.5;
        } else if (Multiplier <= 0.8) {
            Multiplier = 0.8
        }
        CommissionEarning = OTE * (UnitActual / UnitTarget) * Multiplier;
        //debugger;
        //$A.log("CommissionEarning", CommissionEarning);
        component.set("v.CommissionEarning", CommissionEarning);
    }
})