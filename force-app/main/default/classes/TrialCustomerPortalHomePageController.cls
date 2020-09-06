public class TrialCustomerPortalHomePageController {

	User loggedInUser = [SELECT Id,ContactId,Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];

	public List<Asset> MyRegisteredProducts {get; set;}
	public List<Case> MyRecentCases {get; set;}
	public List<Solution> TopSolutions {get; set;}
	public List<Idea> PopularIdeas {get; set;}

	public String sortField1 {get; set;}
	public String previousSortField1 {get; set;}
	public String sortField2 {get; set;}
	public String previousSortField2 {get; set;}
	public String sortField3 {get; set;}
	public String previousSortField3 {get; set;}
	public String sortField4 {get; set;}
	public String previousSortField4 {get; set;}

	public TrialCustomerPortalHomePageController() {
		MyRegisteredProducts = [SELECT Id,Name,SerialNumber,InstallDate,UsageEndDate,Status
		FROM Asset
		WHERE ContactId = :loggedInUser.ContactId
		ORDER BY SerialNumber DESC LIMIT 3];

		MyRecentCases = [SELECT Id,CaseNumber,Subject,Status,LastModifiedDate
		FROM Case
		WHERE ContactId = :loggedInUser.ContactId
		ORDER BY LastModifiedDate DESC LIMIT 3];

		TopSolutions = [SELECT Id,SolutionName,TimesUsed,LastModifiedDate
		FROM Solution
		ORDER BY TimesUsed DESC LIMIT 3];

		PopularIdeas = [SELECT Id,Title,Categories,VoteTotal
		FROM Idea
		ORDER BY VoteTotal DESC LIMIT 3];
	}

	public void SortProducts(){
		String order = 'asc';
		if(previousSortField1 == sortField1){
			order = 'desc';
			previousSortField1 = null;
		}else{
			previousSortField1 = sortField1;
		}
		superSort.sortList(MyRegisteredProducts,sortField1,order);
	}
	public void SortCases(){
		String order = 'asc';
		if(previousSortField2 == sortField2){
			order = 'desc';
			previousSortField2 = null;
		}else{
			previousSortField2 = sortField2;
		}
		superSort.sortList(MyRecentCases,sortField2,order);
	}
	public void SortSolutions(){
		String order = 'asc';
		if(previousSortField3 == sortField3){
			order = 'desc';
			previousSortField3 = null;
		}else{
			previousSortField3 = sortField3;
		}
		superSort.sortList(TopSolutions,sortField3,order);
	}
	public void SortIdeas(){
		String order = 'asc';
		if(previousSortField4 == sortField4){
			order = 'desc';
			previousSortField4 = null;
		}else{
			previousSortField4 = sortField4;
		}
		superSort.sortList(PopularIdeas,sortField4,order);
	}

}