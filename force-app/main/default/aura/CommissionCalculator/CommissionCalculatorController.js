({
	myAction : function(component, event, helper) {
		
	},
    
    doInit : function(component, event, helper) {
        var action = component.get("c.getCurrentCommission");
        action.setCallback(this, function(response) {
            var commissionResult = response.getReturnValue();
            component.set("v.OTE", commissionResult.Monthly_OTE__c);
            component.set("v.PLOTE", commissionResult.PL_OTE__c);
            component.set("v.OnlineFlowOTE", commissionResult.OnlineFlowOTE__c);
            component.set("v.NetRevenuePercentage", commissionResult.Net_Revenue_Percentage__c);
            
            //component.set("v.UnitOTEPercentage", 0.7);
            //component.set("v.UniqueTargetOTEPercentage", 0.3);
            
            component.set("v.CommissionUnit", null);
            component.set("v.CommissionUnique", null);
            component.set("v.CommissionPL", null);
            component.set("v.CommissionRevenue", null);
            component.set("v.CommissionEarning", null);
            component.set("v.CommissionUnitBoost", null);
            component.set("v.CommissionUniqueRefBoost", null);
            component.set("v.CommissionUniqueRefTotal", null);
            component.set("v.CommissionUnitTotal", null);
            component.set("v.CommissionUniqueRefTotal", null);
            
            component.set("v.CommissionBooking", null);
            component.set("v.CommissionBookingBoost", null);
            component.set("v.CommissionPLBoost", null);
            component.set("v.CommissionBookingTotal", null);
            component.set("v.CommissionPLTotal", null);
            component.set("v.Boost", null);
            
            component.set("v.CommissionOnlineFlowTotal", null);
            component.set("v.CommissionOnlineFlow", null);
            component.set("v.CommissionOnlineFlowBoost", null);
                                   
            component.set("v.UnitTarget", commissionResult.Units_Target__c);
            component.set("v.UnitActual", commissionResult.Units_Achieved__c);            
            component.set("v.UniqueRefTarget", commissionResult.Unique_Target__c);
            component.set("v.UniqueRefActual", commissionResult.Unique_Achieved__c);
            component.set("v.DIYTarget", commissionResult.DIY_Target__c);
            component.set("v.DIYActual", commissionResult.DIY_Achieved__c);

            component.set("v.PLTarget", commissionResult.PL_Target__c);
            component.set("v.PLActual", commissionResult.PL_Actual__c);  
            component.set("v.OnlineFlowTarget", commissionResult.OnlineFlowTarget__c);
            component.set("v.OnlineFlowActual", commissionResult.OnlineFlowActual__c);    
            component.set("v.NetBookingTarget", commissionResult.Net_Bookings_Target__c);
            component.set("v.NetBookingActual", commissionResult.Net_Bookings_Actual__c); 
            component.set("v.NetRevenueActual", commissionResult.Net_Revenue__c);
            component.set("v.UnitOTEPercentage", commissionResult.Unit_OTE__c);
            component.set("v.UniqueTargetOTEPercentage", commissionResult.Unique_Referral_OTE__c);
            component.set("v.PLOTEPercentage", commissionResult.PL_OTE_Percentage__c);
            component.set("v.OnlineFlowOTEPercentage", commissionResult.OnlineFlowOTEpercentage__c);
            component.set("v.BookingOTEPercentage", commissionResult.Booking_OTE_Percentage__c);
			component.set("v.BoostMark", commissionResult.BoostMark__c); 
            component.set("v.Multiplier", commissionResult.Multiplier__c); 
            
            component.set("v.Comp1Commission", null);
            component.set("v.Comp2Commission", null);
            component.set("v.Comp3Commission", null);
            component.set("v.Comp4Commission", null);
            
                  
            component.set("v.Component1Target", commissionResult.Component1_Target__c);
            component.set("v.Component1Actual", commissionResult.Component1_Actual__c); 
            component.set("v.Component2Target", commissionResult.Component2_Target__c);
            component.set("v.Component2Actual", commissionResult.Component2_Actual__c); 
            component.set("v.Component3Target", commissionResult.Component3_Target__c);
            component.set("v.Component3Actual", commissionResult.Component3_Actual__c); 
			component.set("v.Component4Target", commissionResult.Component4_Target__c);
            component.set("v.Component4Actual", commissionResult.Component4_Actual__c); 

            
            component.set("v.Component1OTEPercentage", (commissionResult.Component1_OTEPercentage__c/100));
            component.set("v.Component2OTEPercentage", (commissionResult.Component2_OTEPercentage__c/100));
            component.set("v.Component3OTEPercentage", (commissionResult.Component3_OTEPercentage__c/100));
            component.set("v.Component4OTEPercentage", (commissionResult.Component4_OTEPercentage__c/100));

                        
        })
        $A.enqueueAction(action);
        
        var actionUser = component.get("c.getCurrentUser");
        actionUser.setCallback(this, function(response) {
            var userResult = response.getReturnValue();
            if(userResult.Work_Type__c ==null){
                component.set("v.WorkType", "PM");
            }else{
                component.set("v.WorkType", userResult.Work_Type__c);
            }

            component.set("v.SubChannel", userResult.Sub_Channel__c);
        })
        $A.enqueueAction(actionUser);
    },
    
    calculate: function(component, event, helper) {
        var workType = component.get("v.WorkType");
        
        var OTE = component.get("v.OTE");
        var PLOTE = component.get("v.PLOTE");
        var OnlineFlowOTE = component.get("v.OnlineFlowOTE");
        var NetRevenuePercentage = component.get("v.NetRevenuePercentage");
        var UnitOTEPercentage = component.get("v.UnitOTEPercentage");
        var UniqueTargetOTEPercentage = component.get("v.UniqueTargetOTEPercentage");
        var BookingOTEPercentage = component.get("v.BookingOTEPercentage");
        var PLOTEPercentage = component.get("v.PLOTEPercentage"); 
        var OnlineFlowOTEPercentage = component.get("v.OnlineFlowOTEPercentage");
        
        var UnitTarget = component.get("v.UnitTarget");
        var UnitActual = component.get("v.UnitActual");
        var UniqueRefTarget = component.get("v.UniqueRefTarget");
        var UniqueRefActual = component.get("v.UniqueRefActual");
        var DIYTarget = component.get("v.DIYTarget");
        var DIYActual = component.get("v.DIYActual");
        var PLTarget = component.get("v.PLTarget");
        var PLActual = component.get("v.PLActual");
        var NetBookingTarget = component.get("v.NetBookingTarget");
        var NetBookingActual = component.get("v.NetBookingActual");
        var NetRevenueActual = component.get("v.NetRevenueActual");     
        var MaintenanceTarget = component.get("v.MaintenanceTarget");
        var MaintenanceActual = component.get("v.MaintenanceActual");
        var AcceleratorTarget = component.get("v.AcceleratorTarget");
        var AcceleratorActual = component.get("v.AcceleratorActual");
        var OnlineFlowTarget = component.get("v.OnlineFlowTarget");
        var OnlineFlowActual = component.get("v.OnlineFlowActual");
        
var Component1Target = component.get("v.Component1Target");
var Component1Actual = component.get("v.Component1Actual");
var Component2Target = component.get("v.Component2Target");
var Component2Actual = component.get("v.Component2Actual");
var Component3Target = component.get("v.Component3Target");
var Component3Actual = component.get("v.Component3Actual");
var Component4Target = component.get("v.Component4Target");
var Component4Actual = component.get("v.Component4Actual");

var Component1OTEPercentage = component.get("v.Component1OTEPercentage");
var Component2OTEPercentage = component.get("v.Component2OTEPercentage");
var Component3OTEPercentage = component.get("v.Component3OTEPercentage");
var Component4OTEPercentage = component.get("v.Component4OTEPercentage");
        
        var CommissionUnit = 0;
        var CommissionUnique = 0;
        var CommissionPL = 0;
        var CommissionRevenue = 0;
        var CommissionEarning = 0;
        var DIYBoostPercentage = 0;
        var DIYBoostPercentageUR = 0;
        var CommissionUnitBoost = 0;
        var CommissionURBoost = 0;
        var CommissionOnlineFlowBoost = 0;
        
        var CommissionBookingBoost = 0;
        var CommissionPLBoost = 0; 
        var CommissionBooking = 0;
        var CommissionOnlineFlow = 0;
        var BookingMaintenanceBoostPercentage = 0;
        var PLMaintenanceBoostPercentage = 0;   
        var OnlineFlowMaintenanceBoostPercentage = 0;
        
var Component1Multipler = 0;
var Component2Multipler = 0;
var Component3Multipler = 0;
var Component4Multipler = 0;

var Comp1Commission = 0;
var Comp2Commission = 0;
var Comp3Commission = 0;
var Comp4Commission = 0;
        
        if(workType === "TM"){
            if (Component1Actual != null && Component1Target!= null)
            {
            if((Component1Actual/Component1Target).toFixed(2) >= 0.8 && (Component1Actual/Component1Target).toFixed(2) < 0.85){
                Component1Multipler = 0.8;
            }
            else if((Component1Actual/Component1Target).toFixed(2) >= 0.85 && (Component1Actual/Component1Target).toFixed(2) < 0.9){
                Component1Multipler = 0.9;
            }
            else if((Component1Actual/Component1Target).toFixed(2) >= 0.9 && (Component1Actual/Component1Target).toFixed(2) < 1.05){
                Component1Multipler = 1;
            }
                else if((Component1Actual/Component1Target).toFixed(2) >= 1.05 && (Component1Actual/Component1Target).toFixed(2) < 1.1){
                    Component1Multipler = 1.05;
                }
                    else if((Component1Actual/Component1Target).toFixed(2) >= 1.1 && (Component1Actual/Component1Target).toFixed(2) < 1.15){
                        Component1Multipler = 1.1;
                    }
                        else if((Component1Actual/Component1Target).toFixed(2) >= 1.15 && (Component1Actual/Component1Target).toFixed(2) < 1.2){
                            Component1Multipler = 1.2;
                        }
                            else if((Component1Actual/Component1Target).toFixed(2) >= 1.2 && (Component1Actual/Component1Target).toFixed(2) < 1.35){
                                Component1Multipler = 1.35;
                            }
                                else if((Component1Actual/Component1Target).toFixed(2) >= 1.35 && (Component1Actual/Component1Target).toFixed(2) < 1.4){
                                    Component1Multipler = 1.4;
                                }
                                    else if((Component1Actual/Component1Target).toFixed(2) >= 1.4 && (Component1Actual/Component1Target).toFixed(2) <= 1.5){
                                        Component1Multipler = 1.5;
                                    }

            if((Component1Actual/Component1Target).toFixed(2) > 1.5 && (Component1Actual/Component1Target).toFixed(2) <= 3.58){
                 Comp1Commission = OTE * Component1OTEPercentage * ((Component1Actual/Component1Target) + 0.75).toFixed(2);
                Comp1Commission = Math.floor(Comp1Commission);
            }
            else
            {  
                Comp1Commission = (OTE * Component1OTEPercentage) * ((Component1Actual/Component1Target).toFixed(2) * Component1Multipler);
                Comp1Commission = Math.floor(Comp1Commission);
               //   Comp1Commission = Component1Multipler;// * ((Component1Actual/Component1Target).toFixed(2) * Component1Multipler);
            }
            }       
            
            if (Component2Actual != null && Component2Target!= null)
            {  
            if((Component2Actual/Component2Target).toFixed(2) >= 0.8 && (Component2Actual/Component2Target).toFixed(2) < 0.85){
                Component2Multipler = 0.8;
            }
            else if((Component2Actual/Component2Target).toFixed(2) >= 0.85 && (Component2Actual/Component2Target).toFixed(2) < 0.9){
                Component2Multipler = 0.9;
            }
            else if((Component2Actual/Component2Target).toFixed(2) >= 0.9 && (Component2Actual/Component2Target).toFixed(2) < 1.05){
                Component2Multipler = 1;
            }
                else if((Component2Actual/Component2Target).toFixed(2) >= 1.05 && (Component2Actual/Component2Target).toFixed(2) < 1.1){
                    Component2Multipler = 1.05;
                }
                    else if((Component2Actual/Component2Target).toFixed(2) >= 1.1 && (Component2Actual/Component2Target).toFixed(2) < 1.15){
                        Component2Multipler = 1.1;
                    }
                        else if((Component2Actual/Component2Target).toFixed(2) >= 1.15 && (Component2Actual/Component2Target).toFixed(2) < 1.2){
                            Component2Multipler = 1.2;
                        }
                            else if((Component2Actual/Component2Target).toFixed(2) >= 1.2 && (Component2Actual/Component2Target).toFixed(2) < 1.35){
                                Component2Multipler = 1.35;
                            }
                                else if((Component2Actual/Component2Target).toFixed(2) >= 1.35 && (Component2Actual/Component2Target).toFixed(2) < 1.4){
                                    Component2Multipler = 1.4;
                                }
                                    else if((Component2Actual/Component2Target).toFixed(2) >= 1.4 && (Component2Actual/Component2Target).toFixed(2) <= 1.5){
                                        Component2Multipler = 1.5;
                                    }
                                        
            if((Component2Actual/Component2Target).toFixed(2) > 1.5 && (Component2Actual/Component2Target).toFixed(2) <= 3.58){
             Comp2Commission = OTE * Component2OTEPercentage * ((Component2Actual/Component2Target) + 0.75).toFixed(2);
                Comp2Commission = Math.floor(Comp2Commission);
                                        }
            else{
            Comp2Commission = OTE * Component2OTEPercentage * ((Component2Actual/Component2Target).toFixed(2) * Component2Multipler);
                Comp2Commission = Math.floor(Comp2Commission);
        }
            }
            
            if (Component3Actual != null && Component3Target!= null)
            {       
            
            if((Component3Actual/Component3Target).toFixed(2) >= 0.8 && (Component3Actual/Component3Target).toFixed(2) < 0.85){
                Component3Multipler = 0.8;
            }
            else if((Component3Actual/Component3Target).toFixed(2) >= 0.85 && (Component3Actual/Component3Target).toFixed(2) < 0.9){
                Component3Multipler = 0.9;
            }
            else if((Component3Actual/Component3Target).toFixed(2) >= 0.9 && (Component3Actual/Component3Target).toFixed(2) < 1.05){
                Component3Multipler = 1;
            }
                else if((Component3Actual/Component3Target).toFixed(2) >= 1.05 && (Component3Actual/Component3Target).toFixed(2) < 1.1){
                    Component3Multipler = 1.05;
                }
                    else if((Component3Actual/Component3Target).toFixed(2) >= 1.1 && (Component3Actual/Component3Target).toFixed(2) < 1.15){
                        Component3Multipler = 1.1;
                    }
                        else if((Component3Actual/Component3Target).toFixed(2) >= 1.15 && (Component3Actual/Component3Target).toFixed(2) < 1.2){
                            Component3Multipler = 1.2;
                        }
                            else if((Component3Actual/Component3Target).toFixed(2) >= 1.2 && (Component3Actual/Component3Target).toFixed(2) < 1.35){
                                Component3Multipler = 1.35;
                            }
                                else if((Component3Actual/Component3Target).toFixed(2) >= 1.35 && (Component3Actual/Component3Target).toFixed(2) < 1.4){
                                    Component3Multipler = 1.4;
                                }
                                    else if((Component3Actual/Component3Target).toFixed(2) >= 1.4 && (Component3Actual/Component3Target).toFixed(2) <= 1.5){
                                        Component3Multipler = 1.5;
                                    }
          if((Component3Actual/Component3Target).toFixed(2) > 1.5 && (Component3Actual/Component3Target).toFixed(2) <= 3.58){
              Comp3Commission = OTE * Component3OTEPercentage * ((Component3Actual/Component3Target)+0.75).toFixed(2);
              Comp3Commission = Math.floor(Comp3Commission);
           } 
            else
            {
			Comp3Commission = OTE * Component3OTEPercentage * ((Component3Actual/Component3Target).toFixed(2) * Component3Multipler);
                Comp3Commission = Math.floor(Comp3Commission);
      		}
            }
            
        if (Component4Actual != null && Component4Target!= null)
            { 
            
            if((Component4Actual/Component4Target).toFixed(2) >= 0.8 && (Component4Actual/Component4Target).toFixed(2) < 0.85){
                Component4Multipler = 0.8;
            }
            else if((Component4Actual/Component4Target).toFixed(2) >= 0.85 && (Component4Actual/Component4Target).toFixed(2) < 0.9){
                Component4Multipler = 0.9;
            }
            else if((Component4Actual/Component4Target).toFixed(2) >= 0.9 && (Component4Actual/Component4Target).toFixed(2) < 1.05){
                Component4Multipler = 1;
            }
                else if((Component4Actual/Component4Target).toFixed(2) >= 1.05 && (Component4Actual/Component4Target).toFixed(2) < 1.1){
                    Component4Multipler = 1.05;
                }
                    else if((Component4Actual/Component4Target).toFixed(2) >= 1.1 && (Component4Actual/Component4Target).toFixed(2) < 1.15){
                        Component4Multipler = 1.1;
                    }
                        else if((Component4Actual/Component4Target).toFixed(2) >= 1.15 && (Component4Actual/Component4Target).toFixed(2) < 1.2){
                            Component4Multipler = 1.2;
                        }
                            else if((Component4Actual/Component4Target).toFixed(2) >= 1.2 && (Component4Actual/Component4Target).toFixed(2) < 1.35){
                                Component4Multipler = 1.35;
                            }
                                else if((Component4Actual/Component4Target).toFixed(2) >= 1.35 && (Component4Actual/Component4Target).toFixed(2) < 1.4){
                                    Component4Multipler = 1.4;
                                }
                                    else if((Component4Actual/Component4Target).toFixed(2) >= 1.4 && (Component4Actual/Component4Target).toFixed(2) <= 1.5){
                                        Component4Multipler = 1.5;
                                    }
           if((Component4Actual/Component4Target).toFixed(2) > 1.5 && (Component4Actual/Component4Target).toFixed(2) <= 3.58){
            Comp4Commission = OTE * Component4OTEPercentage * ((Component4Actual/Component4Target) + 0.75).toFixed(2);  
               Comp4Commission = Math.floor(Comp4Commission);
           }
            else {
                Comp4Commission = OTE * Component4OTEPercentage * ((Component4Actual/Component4Target).toFixed(2) * Component4Multipler);  
                Comp4Commission = Math.floor(Comp4Commission);
            }

            }
        	CommissionEarning = Comp1Commission + Comp2Commission + Comp3Commission + Comp4Commission;
            CommissionEarning = Math.floor(CommissionEarning);
        }
        
        if(workType === "PM" || workType === "PC"){
            if(UnitActual/UnitTarget >= 0.8){
                CommissionUnit = OTE * UnitOTEPercentage * UnitActual/UnitTarget;
                if(CommissionUnit == null){
                    CommissionUnit = 0;
                }
            }
            else{
                CommissionUnit = 0;
            }
            
            if(UniqueRefActual/UniqueRefTarget >= 0.8){
            	CommissionUnique = OTE * UniqueTargetOTEPercentage * (UniqueRefActual/UniqueRefTarget);
                if(CommissionUnique == null){
                    CommissionUnique = 0;
                }
            }
            else{
                CommissionUnique = 0;
            } 
            
            if(DIYActual/DIYTarget < 1){
                if(UnitActual/UnitTarget >= 0.8 && UnitActual/UnitTarget < 0.9){
                    DIYBoostPercentage = -0.1;
                }
                else if(UnitActual/UnitTarget >= 0.9 && UnitActual/UnitTarget < 1){
                    DIYBoostPercentage = -0.05;
                }

                if(UniqueRefActual/UniqueRefTarget >= 0.8 && UniqueRefActual/UniqueRefTarget < 0.9){
                    DIYBoostPercentageUR = -0.1;
                }
                else if(UniqueRefActual/UniqueRefTarget >= 0.9 && UniqueRefActual/UniqueRefTarget < 1){
                    DIYBoostPercentageUR = -0.05;
                }                  
            }
            else if (DIYActual/DIYTarget >= 1){
                if(UnitActual/UnitTarget >= 1 && UnitActual/UnitTarget < 1.1){
                    DIYBoostPercentage = 0.05;
                }
                else if(UnitActual/UnitTarget >= 1.1 && UnitActual/UnitTarget < 1.2){
                    DIYBoostPercentage = 0.1;
                }
                else if(UnitActual/UnitTarget >= 1.2 && UnitActual/UnitTarget < 1.3){
                    DIYBoostPercentage = 0.2;
                }
                else if(UnitActual/UnitTarget >= 1.3 && UnitActual/UnitTarget < 1.4){
                    DIYBoostPercentage = 0.3;
                } 
                else if(UnitActual/UnitTarget >= 1.4 && UnitActual/UnitTarget < 1.5){
                    DIYBoostPercentage = 0.4;
                }
                else if(UnitActual/UnitTarget >= 1.5){
                    DIYBoostPercentage = 0.5;
                }

                if(UniqueRefActual/UniqueRefTarget>= 1 && UniqueRefActual/UniqueRefTarget < 1.1){
                    DIYBoostPercentageUR = 0.1;
                }
                else if(UniqueRefActual/UniqueRefTarget >= 1.1 && UniqueRefActual/UniqueRefTarget < 1.2){
                    DIYBoostPercentageUR = 0.2;
                }
                else if(UniqueRefActual/UniqueRefTarget>= 1.2 && UniqueRefActual/UniqueRefTarget < 1.3){
                    DIYBoostPercentageUR = 0.4;
                }
                else if(UniqueRefActual/UniqueRefTarget >= 1.3 && UniqueRefActual/UniqueRefTarget < 1.4){
                    DIYBoostPercentageUR = 0.6;
                } 
                else if(UniqueRefActual/UniqueRefTarget >= 1.4 && UniqueRefActual/UniqueRefTarget < 1.5){
                    DIYBoostPercentageUR = 0.8;
                }
                else if(UniqueRefActual/UniqueRefTarget >= 1.5){
                    DIYBoostPercentageUR = 1;
                }                 
            }
            else{
                DIYBoostPercentageUR = 0;
                DIYBoostPercentage = 0;
            }
	
			CommissionUnitBoost = OTE * UnitOTEPercentage * DIYBoostPercentage;
            if(isNaN(CommissionUnitBoost)){
                CommissionUnitBoost = 0;
            }
        	CommissionURBoost = OTE * UniqueTargetOTEPercentage * DIYBoostPercentageUR;
            if(isNaN(CommissionURBoost)){
                CommissionURBoost = 0;
            }

            CommissionEarning = CommissionUnit + CommissionUnitBoost + CommissionUnique + CommissionURBoost;

        } 
        else if(workType === "CM"){
            var selectCmp = component.find("InputSelectSingleCMMaintenance");
        	var CMMaintenanceAchieved = selectCmp.get("v.value");            
            
            if(PLActual/PLTarget >= 0.8){
                CommissionPL = OTE * PLOTEPercentage  * (PLActual/PLTarget);
                if(CommissionPL == null){
                    CommissionPL = 0;
                }
            }
            else{
                CommissionPL = 0;
            }
 
            if(NetBookingActual/NetBookingTarget >= 0.8){
                CommissionBooking = OTE * BookingOTEPercentage * (NetBookingActual/NetBookingTarget);
                if(CommissionBooking == null){
                    CommissionBooking = 0;
                }
            }
            else{
                CommissionBooking = 0;
            }            

            //if(MaintenanceActual < MaintenanceTarget){
            if(CMMaintenanceAchieved === 'NO'){
                if(NetBookingActual/NetBookingTarget >= 0.8 && NetBookingActual/NetBookingTarget < 0.9){
                    BookingMaintenanceBoostPercentage = -0.1;
                }
                else if(NetBookingActual/NetBookingTarget >= 0.9 && NetBookingActual/NetBookingTarget  < 1){
                    BookingMaintenanceBoostPercentage = -0.05;
                }

                if(PLActual/PLTarget >= 0.8 && PLActual/PLTarget < 0.9){
                    PLMaintenanceBoostPercentage = -0.1;
                }
                else if(PLActual/PLTarget >= 0.9 && PLActual/PLTarget < 1){
                    PLMaintenanceBoostPercentage = -0.05;
                }                  
            }
            //else if (MaintenanceActual >= MaintenanceTarget){
            else if (CMMaintenanceAchieved === 'YES'){
                if(NetBookingActual/NetBookingTarget  >= 1 && NetBookingActual/NetBookingTarget < 1.1){
                    BookingMaintenanceBoostPercentage = 0.05;
                }
                else if(NetBookingActual/NetBookingTarget >= 1.1 && NetBookingActual/NetBookingTarget  < 1.2){
                    BookingMaintenanceBoostPercentage = 0.1;
                }
                else if(NetBookingActual/NetBookingTarget  >= 1.2 && NetBookingActual/NetBookingTarget  < 1.3){
                    BookingMaintenanceBoostPercentage = 0.2;
                }
                else if(NetBookingActual/NetBookingTarget  >= 1.3 && NetBookingActual/NetBookingTarget  < 1.4){
                    BookingMaintenanceBoostPercentage = 0.3;
                } 
                else if(NetBookingActual/NetBookingTarget  >= 1.4 && NetBookingActual/NetBookingTarget  < 1.5){
                    BookingMaintenanceBoostPercentage = 0.4;
                }
                else if(NetBookingActual/NetBookingTarget  >= 1.5){
                    BookingMaintenanceBoostPercentage = 0.5;
                }

                if(PLActual/PLTarget>= 1 && PLActual/PLTarget < 1.1){
                    PLMaintenanceBoostPercentage = 0.05;
                }
                else if(PLActual/PLTarget >= 1.1 && PLActual/PLTarget < 1.2){
                    PLMaintenanceBoostPercentage = 0.1;
                }
                else if(PLActual/PLTarget>= 1.2 && PLActual/PLTarget < 1.3){
                    PLMaintenanceBoostPercentage = 0.2;
                }
                else if(PLActual/PLTarget >= 1.3 && PLActual/PLTarget < 1.4){
                    PLMaintenanceBoostPercentage = 0.3;
                } 
                else if(PLActual/PLTarget >= 1.4 && PLActual/PLTarget < 1.5){
                    PLMaintenanceBoostPercentage = 0.4;
                }
                else if(PLActual/PLTarget >= 1.5){
                    PLMaintenanceBoostPercentage = 0.5;
                }                 
            }


            
			CommissionBookingBoost = OTE * BookingOTEPercentage * BookingMaintenanceBoostPercentage;
            if(isNaN(CommissionBookingBoost)){
                CommissionBookingBoost = 0;
            }
        	CommissionPLBoost = OTE * PLOTEPercentage * PLMaintenanceBoostPercentage;
            if(isNaN(CommissionPLBoost)){
                CommissionPLBoost = 0;
            }            
            CommissionEarning = CommissionPL + CommissionPLBoost + CommissionBooking + CommissionBookingBoost;
        }
        else if(workType === "CPM"){
            selectCmp = component.find("InputSelectSingleCMMaintenance");
        	CMMaintenanceAchieved = selectCmp.get("v.value");
            
            if(PLActual/PLTarget >= 0.8){
                CommissionPL = OTE * PLOTEPercentage  * (PLActual/PLTarget);
                if(CommissionPL == null){
                    CommissionPL = 0;
                }
            }
            else{
                CommissionPL = 0;
            }
 
            if(NetBookingActual/NetBookingTarget >= 0.8){
                CommissionBooking = OTE * BookingOTEPercentage * (NetBookingActual/NetBookingTarget);
                if(CommissionBooking == null){
                    CommissionBooking = 0;
                }
            }
            else{
                CommissionBooking = 0;
            }

            if(NetBookingActual/NetBookingTarget >= 0.8){
                CommissionOnlineFlow = OTE * OnlineFlowOTEPercentage * (OnlineFlowActual/OnlineFlowTarget);
                if(CommissionOnlineFlow == null){
                    CommissionOnlineFlow = 0;
                }
            }
            else{
                CommissionOnlineFlow = 0;
            }             

            //if(MaintenanceActual < MaintenanceTarget){
            if(CMMaintenanceAchieved === 'NO'){
                if(NetBookingActual/NetBookingTarget >= 0.8 && NetBookingActual/NetBookingTarget < 0.9){
                    BookingMaintenanceBoostPercentage = -0.1;
                }
                else if(NetBookingActual/NetBookingTarget >= 0.9 && NetBookingActual/NetBookingTarget  < 1){
                    BookingMaintenanceBoostPercentage = -0.05;
                }

                if(PLActual/PLTarget >= 0.8 && PLActual/PLTarget < 0.9){
                    PLMaintenanceBoostPercentage = -0.1;
                }
                else if(PLActual/PLTarget >= 0.9 && PLActual/PLTarget < 1){
                    PLMaintenanceBoostPercentage = -0.05;
                } 
             
                if(OnlineFlowActual/OnlineFlowTarget >= 0.8 && OnlineFlowActual/OnlineFlowTarget < 0.9){
                    OnlineFlowMaintenanceBoostPercentage = -0.1;
                }
                else if(OnlineFlowActual/OnlineFlowTarget >= 0.9 && OnlineFlowActual/OnlineFlowTarget < 1){
                    OnlineFlowMaintenanceBoostPercentage = -0.05;
                }                 
            }
            //else if (MaintenanceActual >= MaintenanceTarget){
            else if (CMMaintenanceAchieved === 'YES'){
                if(NetBookingActual/NetBookingTarget  >= 1 && NetBookingActual/NetBookingTarget < 1.1){
                    BookingMaintenanceBoostPercentage = 0.05;
                }
                else if(NetBookingActual/NetBookingTarget >= 1.1 && NetBookingActual/NetBookingTarget  < 1.2){
                    BookingMaintenanceBoostPercentage = 0.1;
                }
                else if(NetBookingActual/NetBookingTarget  >= 1.2 && NetBookingActual/NetBookingTarget  < 1.3){
                    BookingMaintenanceBoostPercentage = 0.2;
                }
                else if(NetBookingActual/NetBookingTarget  >= 1.3 && NetBookingActual/NetBookingTarget  < 1.4){
                    BookingMaintenanceBoostPercentage = 0.3;
                } 
                else if(NetBookingActual/NetBookingTarget  >= 1.4 && NetBookingActual/NetBookingTarget  < 1.5){
                    BookingMaintenanceBoostPercentage = 0.4;
                }
                else if(NetBookingActual/NetBookingTarget  >= 1.5){
                    BookingMaintenanceBoostPercentage = 0.5;
                }

                if(PLActual/PLTarget>= 1 && PLActual/PLTarget < 1.1){
                    PLMaintenanceBoostPercentage = 0.05;
                }
                else if(PLActual/PLTarget >= 1.1 && PLActual/PLTarget < 1.2){
                    PLMaintenanceBoostPercentage = 0.1;
                }
                else if(PLActual/PLTarget>= 1.2 && PLActual/PLTarget < 1.3){
                    PLMaintenanceBoostPercentage = 0.2;
                }
                else if(PLActual/PLTarget >= 1.3 && PLActual/PLTarget < 1.4){
                    PLMaintenanceBoostPercentage = 0.3;
                } 
                else if(PLActual/PLTarget >= 1.4 && PLActual/PLTarget < 1.5){
                    PLMaintenanceBoostPercentage = 0.4;
                }
                else if(PLActual/PLTarget >= 1.5){
                    PLMaintenanceBoostPercentage = 0.5;
                }
                
                if(OnlineFlowActual/OnlineFlowTarget >= 1 && OnlineFlowActual/OnlineFlowTarget < 1.1){
                    OnlineFlowMaintenanceBoostPercentage = 0.05;
                }
                else if(OnlineFlowActual/OnlineFlowTarget >= 1.1 && OnlineFlowActual/OnlineFlowTarget < 1.2){
                    OnlineFlowMaintenanceBoostPercentage = 0.1;
                }
                else if(OnlineFlowActual/OnlineFlowTarget >= 1.2 && OnlineFlowActual/OnlineFlowTarget < 1.3){
                    OnlineFlowMaintenanceBoostPercentage = 0.2;
                }
                else if(OnlineFlowActual/OnlineFlowTarget >= 1.3 && OnlineFlowActual/OnlineFlowTarget < 1.4){
                    OnlineFlowMaintenanceBoostPercentage = 0.3;
                } 
                else if(OnlineFlowActual/OnlineFlowTarget >= 1.4 && OnlineFlowActual/OnlineFlowTarget < 1.5){
                    OnlineFlowMaintenanceBoostPercentage = 0.4;
                }
                else if(OnlineFlowActual/OnlineFlowTarget >= 1.5){
                    OnlineFlowMaintenanceBoostPercentage = 0.5;
                }                 
            }


            
			CommissionBookingBoost = OTE * BookingOTEPercentage * BookingMaintenanceBoostPercentage;
            if(isNaN(CommissionBookingBoost)){
                CommissionBookingBoost = 0;
            } 
            //console.log('CommissionBookingBoost:' + CommissionBookingBoost );
        	CommissionPLBoost = OTE * PLOTEPercentage * PLMaintenanceBoostPercentage;
            if(isNaN(CommissionPLBoost)){
                CommissionPLBoost = 0;
            } 
			//console.log('CommissionPLBoost:' + CommissionPLBoost );
            CommissionOnlineFlowBoost = OTE * OnlineFlowOTEPercentage * OnlineFlowMaintenanceBoostPercentage;
            if(isNaN(CommissionOnlineFlowBoost)){
                CommissionOnlineFlowBoost = 0;
            }  
 
            if(isNaN(CommissionPL)){
                CommissionPL = 0;
            } 
            
            if(isNaN(CommissionBooking)){
                CommissionBooking = 0;
            } 
            
            if(isNaN(CommissionOnlineFlow)){
                CommissionOnlineFlow = 0;
            }             
            
            // console.log('CommissionOnlineFlowBoost:' + CommissionOnlineFlowBoost );
            //console.log('CommissionPL:' + CommissionPL );
            //console.log('CommissionBooking:' + CommissionBooking );
            CommissionEarning = CommissionPL + CommissionPLBoost + CommissionBooking + CommissionBookingBoost + CommissionOnlineFlow + CommissionOnlineFlowBoost;          
        	//console.log('CommissionEarning:' + CommissionEarning );
        }
        else if(workType === "CS"){
            
            selectCmp = component.find("InputSelectSingle");
        	var CSboostAchieved = selectCmp.get("v.value");
            
            CommissionUnit = 0;
            CommissionUnitBoost= 0;
            
            var multiplierBoost = 0;
            
            if(UnitActual/UnitTarget >= 1){
                CommissionUnit = OTE * UnitOTEPercentage * UnitActual/UnitTarget;
                if(CommissionUnit == null){
                    CommissionUnit = 0;
                }
            }   
            else{
                CommissionUnit = 0;
            }
            //console.log("CSboostAchieved:" +CSboostAchieved);
            if(CSboostAchieved === 'YES'){
                //console.log("Yes");
                //console.log(UnitActual/UnitTarget );
                if(UnitActual/UnitTarget >=1 && UnitActual/UnitTarget < 1.1 ){
                    multiplierBoost = 0.05;
                }                
                else if(UnitActual/UnitTarget >=1.1 && UnitActual/UnitTarget < 1.2 ){
                    multiplierBoost = 0.1;
                }
                else if(UnitActual/UnitTarget >=1.2 && UnitActual/UnitTarget < 1.3 ){
                    multiplierBoost = 0.2;
                }
                else if(UnitActual/UnitTarget >=1.3 && UnitActual/UnitTarget < 1.4 ){
                    multiplierBoost = 0.3;
                }
                else if(UnitActual/UnitTarget >=1.4 && UnitActual/UnitTarget < 1.5 ){
                    multiplierBoost = 0.4;
                }
                else if(UnitActual/UnitTarget >= 1.5){
                    multiplierBoost = 0.5;
                }              
                else{
                    multiplierBoost = 0;
                }                
            }
            else{
                multiplierBoost = 0;
            }

            
            CommissionUnitBoost = OTE * UnitOTEPercentage * multiplierBoost;
            //console.log("OTE:" +OTE);
            //console.log("CommissionUnitBoost:" +CommissionUnitBoost);
            //console.log("UnitOTEPercentage:" +UnitOTEPercentage);
            //console.log("multiplierBoost:" +multiplierBoost);
            if(isNaN(CommissionUnitBoost)){
                CommissionUnitBoost = 0;
            }                 
            CommissionEarning = CommissionUnit + CommissionUnitBoost;
        }
	    else if(workType === "DS"){
	            OTE = component.get("v.OTE");
	            UnitTarget = component.get("v.UnitTarget");
	            UnitActual = component.get("v.UnitActual");
	            var Multiplier = component.get("v.Multiplier"); 		
	            CommissionEarning = 0;

                if(UnitActual/UnitTarget >= 0.8){
                    if( Multiplier>= 2.5){		
                        Multiplier = 2.5;		
                    }		
                    else if( Multiplier <=0.8){		
                        Multiplier = 0.8		
                    }		
                    CommissionEarning = OTE * (UnitActual/UnitTarget) * Multiplier; 
                }
                else{
                    CommissionEarning = null;
                }
	    }        
        
        component.set("v.CommissionUnit", CommissionUnit);
        component.set("v.CommissionUnique", CommissionUnique);
        component.set("v.CommissionPL", CommissionPL);
        component.set("v.CommissionRevenue", CommissionRevenue);
        component.set("v.CommissionEarning", CommissionEarning);
        
        component.set("v.CommissionUnitBoost", CommissionUnitBoost);
        component.set("v.CommissionUniqueRefBoost", CommissionURBoost);
        component.set("v.CommissionUnitTotal", CommissionUnit + CommissionUnitBoost);
        component.set("v.CommissionUniqueRefTotal", CommissionUnique + CommissionURBoost);
        
        component.set("v.CommissionOnlineFlow", CommissionOnlineFlow);
        component.set("v.CommissionOnlineFlowBoost", CommissionOnlineFlowBoost);
        component.set("v.CommissionOnlineFlowTotal", CommissionOnlineFlow + CommissionOnlineFlowBoost);
        
        component.set("v.CommissionBookingBoost", CommissionBookingBoost);
        component.set("v.CommissionBooking", CommissionBooking);  
        component.set("v.CommissionPLBoost", CommissionPLBoost);
        component.set("v.CommissionBookingTotal", CommissionBooking + CommissionBookingBoost);
        component.set("v.CommissionPLTotal", CommissionPL + CommissionPLBoost);     
        component.set("v.Boost", CommissionUnitBoost);
        
        component.set("v.Comp1Commission", Comp1Commission);
        component.set("v.Comp2Commission", Comp2Commission);
        component.set("v.Comp3Commission", Comp3Commission);
        component.set("v.Comp4Commission", Comp4Commission);
        
    }
})