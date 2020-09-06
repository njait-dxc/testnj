/**
 * @author
 * @date
 * @description
 */
public without sharing class BatchDeleteInactiveContactsSchedule implements Schedulable
{
	/**
	 * @description
	 * @param sc
	 */
	public void execute(SchedulableContext sc)
	{
		BatchDeleteInactiveContacts bd = new BatchDeleteInactiveContacts();
		Database.executeBatch(bd, 100);
	}
}