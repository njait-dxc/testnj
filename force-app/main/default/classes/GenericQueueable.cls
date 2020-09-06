/**
 * @author alexvolkov
 * @date 7/1/20
 * @description 
 */
public with sharing class GenericQueueable implements Queueable, Database.AllowsCallouts
{
	private Set<Id> recordIds;
	private Constants.API_MODE mode;

	public GenericQueueable(Set<Id> recordIds, Constants.API_MODE mode)
	{
		this.recordIds = recordIds;
		this.mode = mode;
	}

	public void execute(QueueableContext context)
	{
		if(mode == Constants.API_MODE.PRODUCT_PURCHASING)
		{
			OpportunityService.processOrderItems(recordIds);
		}

	}
}