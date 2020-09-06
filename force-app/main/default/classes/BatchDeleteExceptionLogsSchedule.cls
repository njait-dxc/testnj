/**
 * @Author : Nikhil Jaitly
 * @Created Date : 29/06/2020
 * @Description : This class will be used to schedule the BatchDeleteExceptionLogs class once every month
 */
public with sharing class BatchDeleteExceptionLogsSchedule implements Schedulable {

    /**
	 * @description
	 * @param sc
	 */
	public void execute(SchedulableContext sc)
	{
		BatchDeleteExceptionLogs bd = new BatchDeleteExceptionLogs();
		Database.executeBatch(bd, 100);
	}


}