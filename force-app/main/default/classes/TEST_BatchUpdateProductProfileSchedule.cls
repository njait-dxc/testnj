@IsTest
private class TEST_BatchUpdateProductProfileSchedule
{
	@IsTest
	static void testProductProfileSchedule()
	{
		Test.startTest();
		BatchUpdateProductProfileSchedule bupps1 = new BatchUpdateProductProfileSchedule();
		String sch = '0  00 1 3 * ?';
		String jobId = System.schedule('Test', sch, bupps1);
		Test.stopTest();
		CronTrigger ct = [
				SELECT Id, CronExpression, TimesTriggered, NextFireTime
				FROM CronTrigger
				WHERE Id = :jobId
		];
		System.assertEquals(sch, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
	}
}