/**
 * @Author : Nikhil Jaitly
 * @Created Date : 23/05/2020
 * @Description : This class schedules MYOBService_SubscriptionPollingQue class
 */
public with sharing class MYOBService_SubscriptionPollingSche implements Schedulable {
  /**
	* @Description :This method is used to schedule queueable MYOBService_SubscriptionPolling
  * @Author : Nikhil Jaitly
  * @Created Date : 23/05/2020
	*/
	public void execute(SchedulableContext sc){
    System.enqueueJob(new MYOBService_SubscriptionPollingQue());
  }
}