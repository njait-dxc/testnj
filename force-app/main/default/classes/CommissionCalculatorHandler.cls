/**
 * @author
 * @date
 * @description
 */

public with sharing class CommissionCalculatorHandler {
	@AuraEnabled
	public static Commission__c getCurrentCommission() {
		Integer mnth = System.today().month();
		Integer yr = System.today().year();
		Commission__c [] commissionThisMonth = [SELECT
				Id, Adjustment__c, Commission__c, Date__c, DIY_Percentage__c, Component1_Actual__c,
				Component1_OTEPercentage__c,
				Component1_Target__c, Component2_Actual__c,
				Component2_OTEPercentage__c, Component2_Target__c, Component3_Actual__c, Component3_OTEPercentage__c, Component3_Target__c, Component4_Actual__c,
				Component4_OTEPercentage__c, Component4_Target__c,
				DIY_Achieved__c, DIY_Target__c, Monthly_OTE__c, Net_Booking_Percentage__c,
				Net_Bookings_Actual__c, Net_Bookings_Target__c, Net_Revenue_Percentage__c,
				Net_Revenue_Commission__c, Net_Revenue_Multiplier_Activated__c, Net_Revenue__c,
				PL_Percentage_Achieved__c, PL_Actual__c, PL_Multiplier_Activated__c, PL_OTE__c, PL_OTE_Due__c,
				PL_Target__c, Super__c, Total_Commission_Inc_Super__c, Unique_Percentage__c, Unique_Achieved__c,
				Unique_Multiplier_Achieved__c, Unique_OTE__c, Unique_OTE_Due__c, Unique_Target__c, Units_Percentage__c, OnlineFlowActual__c, OnlineFlowOTE__c, OnlineFlowOTEpercentage__c, OnlineFlowTarget__c,
				Units_Achieved__c, Units_Multiplier_Activated__c, Units_OTE__c, Units_OTE_Due__c, Units_Target__c, Unique_Referral_OTE__c, Unit_OTE__c, PL_OTE_Percentage__c, Booking_OTE_Percentage__c, BoostMark__c, Multiplier__c
		FROM Commission__c WHERE OwnerId = :UserInfo.getUserId() AND CALENDAR_MONTH(Date__c) = :mnth AND CALENDAR_YEAR(Date__c) = :yr LIMIT 1];
		if(commissionThisMonth.size()>0){
			return commissionThisMonth[0];
		}
		else{
			Commission__c dummyCommission = new Commission__c(Adjustment__c = 0, Commission__c=0, DIY_Percentage__c=0,Component1_Actual__c=0,
					Component1_OTEPercentage__c=0,
					Component1_Target__c=0, Component2_Actual__c=0,
					Component2_OTEPercentage__c=0, Component2_Target__c=0, Component3_Actual__c=0, Component3_OTEPercentage__c=0, Component3_Target__c=0, Component4_Actual__c=0,
					Component4_OTEPercentage__c=0, Component4_Target__c=0,
					DIY_Achieved__c=0, DIY_Target__c=0, Monthly_OTE__c=0, Net_Booking_Percentage__c=0,
					Net_Bookings_Actual__c=0, Net_Bookings_Target__c=0, Net_Revenue_Percentage__c=0,
					Net_Revenue_Commission__c=0, Net_Revenue_Multiplier_Activated__c=0, Net_Revenue__c=0,
					PL_Percentage_Achieved__c=0, PL_Actual__c=0, PL_Multiplier_Activated__c=0, PL_OTE__c=0, PL_OTE_Due__c=0,
					PL_Target__c=0, Super__c=0, Total_Commission_Inc_Super__c=0, Unique_Percentage__c=0, Unique_Achieved__c=0,
					Unique_Multiplier_Achieved__c=0, Unique_OTE__c=0, Unique_OTE_Due__c=0, Unique_Target__c=0, Units_Percentage__c=0,
					Units_Achieved__c=0, Units_Multiplier_Activated__c=0, Units_OTE__c=0, Units_OTE_Due__c=0, Units_Target__c=0
			);

			return dummyCommission;
		}
	}

	@AuraEnabled
	public static User getCurrentUser() {
		User[] u = [SELECT
				Id, Work_Type__c, Sub_Channel__c, Profile_Name__c, FirstName, LastName
		FROM User WHERE Id = :UserInfo.getUserId()];
		if(u.size()>0){
			return u[0];
		}
		else{
			User dummyUser = new User(Work_Type__c='PM', Sub_Channel__c='');
			return dummyUser;
		}
	}
}