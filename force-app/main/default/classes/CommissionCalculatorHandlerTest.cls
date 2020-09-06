@IsTest
public class CommissionCalculatorHandlerTest {
	@IsTest
	static void Test(){
		Commission__c commission = CommissionCalculatorHandler.getCurrentCommission();
		System.assertEquals(0, commission.Adjustment__c);
		User user = CommissionCalculatorHandler.getCurrentUser();
		System.assertEquals(UserInfo.getFirstName(), user.FirstName);
	}
}