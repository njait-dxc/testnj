/**
 * @description Custom Persistence Logging Utility using Platform Events
 * Request counts as an API request
 *
 * @author System Partners
 **/
public class LogUtilityException extends Exception
{

	public static String jobId;

	//TODO finalize Generic Message
	static final String SYSMSG = 'Exception occured. Please contact System adminstrator.';
	//dont create logs for these DML Exception types
	static final Set<String> skippedTypes = new Set<String> ();
	/*static final Set<String> skippedTypes = new Set<String> {
	        StatusCode.FAILED_ACTIVATION.name(),
	        StatusCode.STRING_TOO_LONG.name(),
	        StatusCode.INVALID_EMAIL_ADDRESS.name(),
	        StatusCode.REQUIRED_FIELD_MISSING.name(),
	        StatusCode.FIELD_INTEGRITY_EXCEPTION.name(),
	        StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION.name(),
	        StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION.name()
	   };*/
	/**
	 * Helper to rethrow System Message
	 * @param sCustom Message to throw
	 * @example
	 *	} catch (Exception e) {
	 *		LogUtilityException.logException(e);
	 *		LogUtilityException.throwMSG();
	 *	}
	 */
	public static void throwMSG()
	{
		throwMSG(SYSMSG);
	}
	/**
	 * Helper to rethrow Custom
	 * @param sCustom String message
	 */
	public static void throwMSG(String sCustom)
	{
		String str = sCustom;
		throw new LogUtilityException(str);
	}
	public static void throwAura(Exception err, Boolean appendErrMsg)
	{
		String sMsg = SYSMSG;
		if (appendErrMsg)
		{
			sMsg = String.format('{0} - {1}', new List<String>
			{
					SYSMSG, err.getMessage()
			});
		}
		throw new AuraHandledException(sMsg);
	}
	public static void throwAura(String name, String message, Integer code, String sType)
	{
		throw new AuraHandledException(new AuraExceptionData(name, message, code, sType).toJSON());
	}
	/**
	 * Formatted Apex Debug Log message
	 * @param Anydatatype_msg Any Object
	 */
	public static void debug(Object Anydatatype_msg)
	{
		String sMsg = String.format('{0} {1}{2} {3}', new List<String>
		{
				'!!@@##: [',
				getDebugStack(),
				']:',
				String.valueOf(Anydatatype_msg)
		});
		System.debug(sMsg);
	}
	public static void getLimits()
	{
		String sMsg = '!!@@##: \n';
		sMsg += getDebugStack() + '\n';
		sMsg += 'CPU Time:' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime() + '\n';
		sMsg += 'Heap Size:' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() + '\n';
		sMsg += 'DML Rows:' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows() + '\n';
		sMsg += 'DML Statements:' + Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements() + '\n';
		sMsg += 'SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries() + '\n';
		sMsg += 'SOQL Rows:' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows();
		System.debug(sMsg);
	}

	/**
	 * Log a custom trace message
	 * @param stype Type of Log
	 * @param inp   Input Stream
	 * @param msg   Message / output stream
	 */
	public static void logDebug(Object stype, Object inp, Object msg)
	{
		LogEvent__e nLog = new LogEvent__e();
		nLog.CurrentUser__c = UserInfo.getUserId();
		nLog.Stack__c = getStack();
		nLog.Input__c = String.valueOf(inp);
		nLog.Message__c = String.valueOf(msg);
		nLog.Type__c = String.valueOf(stype);
		nLog.Priority__c = 'INFO';
		nLog.JobId__c = getJobId();
		/*dont log if type is in the list */
		if (!skippedTypes.contains(nLog.Type__c))
		{
			QueueLogs(nLog);
		}
	}
	/**
	 * Log a custom exception Message
	 * @param stype Type of Log
	 * @param inp   Input Stream
	 * @param msg   Message / output stream
	 */
	public static void logExceptionMSG(Object stype, Object inp, Object msg)
	{
		LogEvent__e nLog = new LogEvent__e();
		nLog.CurrentUser__c = UserInfo.getUserId();
		nLog.Stack__c = getStack();
		nLog.Input__c = String.valueOf(inp);
		nLog.Message__c = String.valueOf(msg);
		nLog.Type__c = String.valueOf(stype);
		nLog.Priority__c = 'ERROR';
		nLog.JobId__c = getJobId();
		/*dont log if type is in the list */
		if (!skippedTypes.contains(nLog.Type__c))
		{
			QueueLogs(nLog);
		}
	}

	/**
	 * Log a message from exception object
	 * @param err exception object
	 */
	public static void throwException(String className, String methodName, Exception err, List<Object> lSobjects)
	{
		logException(className, methodName, err, lSobjects, true);
	}
	/**
	 * Log a message from exception object
	 * @param err Exception object
	 * @param obj parameter object Id, Key etc
	 */
	public static void logException(String className, String methodName, Exception err, List<Object> lSobjects, Boolean spawnError)
	{
		List<LogEvent__e> listLogs = new List<LogEvent__e>();
		//Added check for FIELD_CUSTOM_VALIDATION_EXCEPTION to return user friendly error.
		String errType = '';
		String errorMsg = err.getMessage();
		if (err.getTypeName() == DmlException.class.getName())
		{
			DmlException dmlEx = (DmlException) err;
			errType = dmlEx.getDmlType(0).name();
			//If type is for UI replace
			if (skippedTypes.contains(errType))
			{
				errorMsg = cleanseMessage(errorMsg, errType);
			}
			else
			{
				//Default to Friendly message
				errorMsg = SYSMSG;
			}
		}
		else
		{
			errorMsg = SYSMSG;
		}
		if (lSobjects != null)
		{
			for (Object sobj : lSobjects)
			{
				String sParam1 = '';
				if (err.getCause() != null)
				{
					sParam1 += String.valueOf(err.getCause());
				}
				if (String.isNotBlank(err.getStackTraceString()))
				{
					sParam1 += String.valueOf(err.getStackTraceString());
				}
				String strObj = '';
				if (sobj != null)
				{
					strObj = JSON.serialize(sobj);
				}
				String sInputStream = String.format('{0} {1}\n{2}', new List<String>
				{
						sParam1,
						String.valueOf(err.getLineNumber()),
						strObj
				});
				LogEvent__e nLog = new LogEvent__e();
				nLog.CurrentUser__c = UserInfo.getUserId();
				nLog.Stack__c = getStack();
				nLog.Input__c = sInputStream;
				nLog.Message__c = String.valueOf(err.getMessage());
				nLog.Type__c = String.valueOf(err.getTypeName());
				nLog.Priority__c = 'ERROR';
				nLog.Class_Name__c = className;
				nLog.Method_Name__c = methodName;
				nLog.JobId__c = getJobId();
				//dont log if type is in the list
				if (!skippedTypes.contains(errType) || System.isBatch() || System.isScheduled() || System.isFuture() || System.isQueueable())
				{
					listLogs.add(nLog);
				}
			}
			if (!listLogs.isEmpty())
			{
				QueueLogs(listLogs);
			}
		}
		if (spawnError)
		{
			if (err.getTypeName() == DmlException.class.getName())
			{
				throw new DmlException(err);
			}
			else
			{
				throw new LogUtilityException(err);
			}

		}
	}

	/**
	 * commit changes to Exception_Log__c object
	 */
	@TestVisible
	static void QueueLogs(List<LogEvent__e> nLogs)
	{

		if (nLogs != null)
		{
			if (!nLogs.isEmpty())
			{
				//Moved to publish platform events and perform after insert DML
				System.debug('\n\nPublish : ' + nLogs);
				EventBus.publish(nLogs);
			}
		}
	}
	static void QueueLogs(LogEvent__e niLog)
	{
		if (niLog != null)
		{
			QueueLogs(new List<LogEvent__e>
			{
					niLog
			});
		}
	}
	/**
	 * QueueLogs description
	 * @param  className      className description
	 * @param  methodName     methodName description
	 * @param  records        records description
	 * @param  saveResultList saveResultList description
	 */
	public static void logSaveResults(String className, String methodName, List<SObject> records, List<Database.SaveResult> saveResultList)
	{
		List<LogEvent__e> listLogs = new List<LogEvent__e>();
		if (saveResultList != null && !saveResultList.isEmpty())
		{
			for (Integer i = 0; i < saveResultList.size(); i++)
			{
				Database.SaveResult sr = saveResultList[i];
				if (!sr.isSuccess())
				{
					listLogs.addAll(addErrorLogs(className, methodName, records[i], sr.getErrors()));
				}
			}
		}
		if (!listLogs.isEmpty())
		{
			QueueLogs(listLogs);
		}
	}
	/**
	 * QueueLogs description
	 * @param  className      className description
	 * @param  methodName     methodName description
	 * @param  records        records description
	 * @param  saveResultList saveResultList description
	 */
	public static void logSaveResults(String className, String methodName, List<SObject> records, List<Database.UpsertResult> saveResultList)
	{
		List<LogEvent__e> listLogs = new List<LogEvent__e>();
		if (saveResultList != null && !saveResultList.isEmpty())
		{
			for (Integer i = 0; i < saveResultList.size(); i++)
			{
				Database.UpsertResult sr = saveResultList[i];
				if (!sr.isSuccess())
				{
					listLogs.addAll(addErrorLogs(className, methodName, records[i], sr.getErrors()));
				}
			}
		}
		if (!listLogs.isEmpty())
		{
			QueueLogs(listLogs);
		}
	}
	/**
	 * QueueLogs description
	 * @param  className      className description
	 * @param  methodName     methodName description
	 * @param  records        records description
	 * @param  saveResultList saveResultList description
	 */
	public static void logSaveResults(String className, String methodName, List<SObject> records, List<Database.DeleteResult> saveResultList)
	{
		List<LogEvent__e> listLogs = new List<LogEvent__e>();
		if (saveResultList != null && !saveResultList.isEmpty())
		{
			for (Integer i = 0; i < saveResultList.size(); i++)
			{
				Database.DeleteResult sr = saveResultList[i];
				if (!sr.isSuccess())
				{
					listLogs.addAll(addErrorLogs(className, methodName, records[i], sr.getErrors()));
				}
			}
		}
		if (!listLogs.isEmpty())
		{
			QueueLogs(listLogs);
		}
	}

	static List<LogEvent__e> addErrorLogs(String className, String methodName, SObject so, List<Database.Error> errList)
	{
		List<LogEvent__e> listLogs = new List<LogEvent__e>();
		if (errList != null && errList.size() > 0)
		{
			for (Database.Error err : errList)
			{
				LogEvent__e nLog = addErrorLogs(className, methodName, so, err);
				listLogs.add(nLog);
			}
		}
		return listLogs;
	}
	static LogEvent__e addErrorLogs(String className, String methodName, SObject so, Database.Error err)
	{
		LogEvent__e nLog = new LogEvent__e();
		nLog.CurrentUser__c = UserInfo.getUserId();
		nLog.Stack__c = getStack();
		nLog.Input__c = JSON.serialize(so);
		nLog.Message__c = 'Fields that affected this error: ' + err.getFields() + '\n\n' + getStack() + '\n\n' + String.valueOf(err.getMessage());
		nLog.Type__c = err.getStatusCode().name();
		nLog.Priority__c = 'ERROR';
		nLog.Class_Name__c = className;
		nLog.Method_Name__c = methodName;
		nLog.JobId__c = getJobId();
		return nLog;
	}

	/**
	 * Retrieves calling stack
	 * @return Stack instance
	 */
	@TestVisible
	static String getStack()
	{
		String[] stackException = new DmlException().getStackTraceString().split('\n');
		//callingStack = stackException[2].substringBefore(':').substringBeforeLast(':');
		String callingStack = '';
		for (String str : stackException)
		{
			callingStack = str.substringBefore(':').substringBeforeLast(':');
			if (!str.containsIgnoreCase('Class.LogUtilityException'))
			{
				break;
			}
		}

		return callingStack;
	}
	@TestVisible
	static String getJobId()
	{
		String sId = '';
		if (System.isBatch() && String.isNotBlank(LogUtilityException.jobId))
		{
			sId = 'Batch-' + LogUtilityException.jobId;
		}
		if (System.isScheduled() && String.isNotBlank(LogUtilityException.jobId))
		{
			sId = 'Schedule-' + LogUtilityException.jobId;
		}
		return sId;
	}
	@TestVisible
	static String getDebugStack()
	{
		String[] stackException = new DmlException().getStackTraceString().split('\n');
		String callingStack = '';
		for (String str : stackException)
		{
			callingStack = str.substringBefore(', column');
			if (!str.containsIgnoreCase('Class.LogUtilityException'))
			{
				break;
			}
		}
		return callingStack;
	}
	public static String cleanseMessage(String errorMsg, String errType)
	{
		String subStr = String.format('{0}, ', new List<String>
		{
				errType
		});
		if (String.isNotBlank(errorMsg) && String.isNotBlank(errType))
		{
			if (errorMsg.contains(']: ['))
			{
				errorMsg = errorMsg.substringBetween(subStr, ']: [');
				if (errorMsg.contains('['))
				{
					errorMsg = errorMsg.replace('[', '');
				}
			}
		}
		return errorMsg;
	}
	public static String cleanseValMessage(String errorMsg)
	{
		String errType = StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION.name();
		String subStr = String.format('{0}, ', new List<String>
		{
				errType
		});
		if (String.isNotBlank(errorMsg) && String.isNotBlank(errType))
		{
			if (errorMsg.contains(errType))
			{
				errorMsg = errorMsg.substringBetween(subStr, ': [');
			}
		}
		return errorMsg;
	}
	public static String cleanseActMessage(String errorMsg)
	{
		String errType = StatusCode.FAILED_ACTIVATION.name();
		String subStr = String.format('{0}, ', new List<String>
		{
				errType
		});
		if (String.isNotBlank(errorMsg) && String.isNotBlank(errType))
		{
			if (errorMsg.contains(errType))
			{
				errorMsg = errorMsg.substringBetween(subStr, ': [');
			}
		}
		return errorMsg;
	}
	public static String cleanseExceptionMessage(Exception e)
	{
		String sMsg = cleanseActMessage(
				cleanseValMessage(
						e.getMessage()
				));

		return sMsg;
	}
	// Wrapper class for my custom exception data to lightning component
	public class AuraExceptionData
	{
		public String name;
		public String message;
		public Integer code;
		public String variant;
		public String severity;

		public AuraExceptionData(String name, String message, Integer code, String typeMsg)
		{
			this.name = name;
			this.message = message;
			this.code = code;
			if (String.isBlank(this.name))
			{
				this.name = 'System Exception';
			}
			// 'error', 'warning', 'success', or 'info'
			this.variant = typeMsg;
			if (code == 0)
			{
				this.name = 'Internal Server Error';
				this.message = SYSMSG;
				this.variant = 'error';
			}
			if (String.isNotBlank(this.variant))
			{
				this.severity = this.variant;
				if (typeMsg == 'success')
				{
					this.severity = 'confirm';
				}
			}
		}
		public String toJSON()
		{
			return JSON.serialize(this);
		}
	}
}