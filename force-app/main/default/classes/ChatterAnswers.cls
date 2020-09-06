public class ChatterAnswers
{
	public String createAccount(String firstname, String lastname, Id siteAdminId)
	{
		Account a = new Account(Name = firstname + ' ' + lastname, OwnerId = siteAdminId);
		insert a;
		return a.Id;
	}
}