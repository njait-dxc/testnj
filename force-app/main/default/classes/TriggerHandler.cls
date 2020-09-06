/**
 * @author nikhiljaitly
 * @date 17/10/2019
 * @description This is the generic Trigger Handler which will be extended by object specific Trigger Handlers.
 */

public virtual class TriggerHandler
{
	private static final String SKIP_TRIGGERS_PERMISSION = 'Disable_Triggers';
	private static Set <String> bypassedHandlers = new Set <String>();
	@TestVisible private TriggerContext context;
	@TestVisible private Boolean isTriggerExecuting;

	/***************************************
	* Constructor
	***************************************/

	public TriggerHandler()
	{
		this.setTriggerContext();
	}

	/***************************************
	* Main run method
	***************************************/

	public void run()
	{
		if (validateRun() == false)
		{
			return;
		}

		// Dispatch to the correct handler method
		if (this.context == TriggerContext.BEFORE_INSERT)
		{
			this.beforeInsert();
		}
		else if (this.context == TriggerContext.BEFORE_UPDATE)
		{
			this.beforeUpdate();
		}
		else if (this.context == TriggerContext.BEFORE_DELETE)
		{
			this.beforeDelete();
		}
		else if (this.context == TriggerContext.AFTER_INSERT)
		{
			this.afterInsert();
		}
		else if (this.context == TriggerContext.AFTER_UPDATE)
		{
			this.afterUpdate();
		}
		else if (this.context == TriggerContext.AFTER_DELETE)
		{
			this.afterDelete();
		}
		else if (this.context == TriggerContext.AFTER_UNDELETE)
		{
			this.afterUndelete();
		}
	}


	/***************************************
	* Bypass Handler Methods
	***************************************/

	public static void bypass(String handlerName)
	{
		TriggerHandler.bypassedHandlers.add(handlerName);
	}

	public static void clearBypass(String handlerName)
	{
		TriggerHandler.bypassedHandlers.remove(handlerName);
	}

	public static Boolean isBypassed(String handlerName)
	{
		return TriggerHandler.bypassedHandlers.contains(handlerName);
	}

	public static void clearAllBypasses()
	{
		TriggerHandler.bypassedHandlers.clear();
	}

	/***************************************
	* Trigger Context methods
	***************************************/

	@TestVisible
	private void setTriggerContext()
	{
		this.setTriggerContext(null, false);
	}

	@TestVisible
	private void setTriggerContext(String context, Boolean testMode)
	{
		if (Trigger.isExecuting == false && testMode == false)
		{
			this.isTriggerExecuting = false;
			return;
		}
		else
		{
			this.isTriggerExecuting = true;
		}

		if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) || (context != null && context == 'before insert'))
		{
			this.context = TriggerContext.BEFORE_INSERT;
		}
		else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) || (context != null && context == 'before update'))
		{
			this.context = TriggerContext.BEFORE_UPDATE;
		}
		else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) || (context != null && context == 'before delete'))
		{
			this.context = TriggerContext.BEFORE_DELETE;
		}
		else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) || (context != null && context == 'after insert'))
		{
			this.context = TriggerContext.AFTER_INSERT;
		}
		else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) || (context != null && context == 'after update'))
		{
			this.context = TriggerContext.AFTER_UPDATE;
		}
		else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) || (context != null && context == 'after delete'))
		{
			this.context = TriggerContext.AFTER_DELETE;
		}
		else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) || (context != null && context == 'after undelete'))
		{
			this.context = TriggerContext.AFTER_UNDELETE;
		}
	}

	/***************************************
	* Method to validate run
	***************************************/

	@TestVisible
	private Boolean validateRun()
	{
		if (this.isTriggerExecuting == false || this.context == null)
		{
			throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
		}
		if (TriggerHandler.bypassedHandlers.contains(getHandlerName()))
		{
			return false;
		}
		if (System.FeatureManagement.checkPermission(SKIP_TRIGGERS_PERMISSION))
		{
			return false;
		}

		List <Trigger_Switch__mdt> triggerSwitches = [SELECT Id, DeveloperName, Stop_Trigger__c FROM Trigger_Switch__mdt WHERE DeveloperName = :getTriggerName() AND Stop_Trigger__c = TRUE];
		if (triggerSwitches.isEmpty() == false)
		{
			return false;
		}

		return true;
	}

	@TestVisible
	private String getHandlerName()
	{
		return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
	}

	private String getTriggerName()
	{
		if (Test.isRunningTest() && !Trigger.isExecuting)
		{
			return 'TEST';
		}
		else
		{
			SObjectType sObjectType;
			if (Trigger.isDelete)
			{
				sObjectType = Trigger.old.getSObjectType();
			}
			else
			{
				sObjectType = Trigger.new.getSObjectType();
			}
			return 'TRIG_' + sObjectType.getDescribe().getName();
		}
	}

	/***************************************
	* Context-specific methods for override
	***************************************/

	@TestVisible protected virtual void beforeInsert()
	{
	}
	@TestVisible protected virtual void beforeUpdate()
	{
	}
	@TestVisible protected virtual void beforeDelete()
	{
	}
	@TestVisible protected virtual void afterInsert()
	{
	}
	@TestVisible protected virtual void afterUpdate()
	{
	}
	@TestVisible protected virtual void afterDelete()
	{
	}
	@TestVisible protected virtual void afterUndelete()
	{
	}

	/***************************************
	* Enumerated types
	***************************************/
	@TestVisible private enum TriggerContext
	{
		BEFORE_INSERT,
		BEFORE_UPDATE,
		BEFORE_DELETE,
		AFTER_INSERT,
		AFTER_UPDATE,
		AFTER_DELETE,
		AFTER_UNDELETE
	}

	/***************************************
	* Exception class
	***************************************/
	public class TriggerHandlerException extends Exception
	{
	}
}