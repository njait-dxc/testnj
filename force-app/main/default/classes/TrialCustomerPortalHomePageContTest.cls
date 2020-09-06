@IsTest(SeeAllData = true)
public class TrialCustomerPortalHomePageContTest {


	public static testMethod void TrialCustomerPortalHomePageContTest() {
		TrialCustomerPortalHomePageController tcp= new TrialCustomerPortalHomePageController();
		tcp.SortProducts();
		tcp.SortCases();
		tcp.SortSolutions();
		tcp.SortIdeas();
	}


}