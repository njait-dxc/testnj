/**
 * @author
 * @date
 * @description
 */

public without sharing class BatchUpdateProductProfileSchedule implements Schedulable
{
	/**
	 * @description
	 * @param sc
	 */
	public void execute(SchedulableContext sc)
	{
		BatchUpdateProductProfile bupp = new BatchUpdateProductProfile();
		Database.executeBatch(bupp);
	}
}