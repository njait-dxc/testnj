/**
 * @author alexvolkov
 * @date 22/11/19
 * @description 
 */
@IsTest
private with sharing class TEST_ChatterAnswers
{
	static testMethod void testCreateAccount()
	{
		ChatterAnswers vCAInstance = new ChatterAnswers();
		System.assertNotEquals(null, vCAInstance.createAccount('Test', 'Test', UserInfo.getUserId()));
	}
}