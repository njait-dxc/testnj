/**
 * @author alexvolkov
 * @date 22/11/19
 * @description 
 */
@IsTest
private class TEST_LogUtilityExceptionTest
{
	static testMethod void debugmethodTest()
	{
		Test.startTest();
		LogUtilityException.logDebug('Test', 'Test', 'Test');
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM Exception_Log__c], 'Test Log count');
	}
	static testMethod void errormethodTest()
	{
		Test.startTest();
		LogUtilityException.logExceptionMSG('Test', 'Test', 'Test');
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM Exception_Log__c], 'Test Log count');
	}

	static testMethod void exceptionmethodListTest()
	{
		Test.startTest();
		List<Account> lacc = new List<Account>();
		try
		{
			lacc.add(new Account());
			insert lacc;
		} catch (Exception e)
		{
			LogUtilityException.logException('Test', 'Test', e, lacc, false);
		}
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM Exception_Log__c], 'Test Log count');
	}
	static testMethod void insertRecordmethodTest()
	{
		Test.startTest();
		List<Account> nAcc = new List<Account>{new Account()};
		List<Database.SaveResult> vSR = Database.insert(nAcc, false);
		LogUtilityException.logSaveResults('Test', 'Test', nAcc, vSR);
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM Exception_Log__c], 'Test Log count');
	}

	static testMethod void deleteRecordmethodTest()
	{
		List<Account> nAcc = (List<Account>)TestDataFactory.createSObjectList(new Account(), 1, true);
		Test.startTest();
		List<Database.DeleteResult> vDR = Database.delete(nAcc, false);
		LogUtilityException.logSaveResults('Test', 'Test', nAcc, vDR);
		Test.stopTest();
		System.assertEquals(0, [SELECT COUNT() FROM Exception_Log__c], 'Test Log count');
	}

	static testMethod void upsertRecordmethodTest()
	{
		Test.startTest();
		List<Account> nAcc = new List<Account>{new Account()};
		List<Database.UpsertResult> vUR = Database.upsert(nAcc, false);
		LogUtilityException.logSaveResults('Test', 'Test', nAcc, vUR);
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM Exception_Log__c], 'Test Log count');
	}


/*	static testMethod void exceptionValidationMethod1Test()
	{
		Test.startTest();
		try
		{
			testAccountValidationException1();
		} catch (Exception ex)
		{
			System.assertNotEquals(null, ex.getMessage());
		}
		Test.stopTest();
		System.assertNotEquals(null, [SELECT Id FROM Exception_Log__c], 'Test Log count');
	}*/
/*	static testMethod void exceptionValidationMethod2Test()
	{
		Test.startTest();
		try
		{
			testAccountValidationException2();
		} catch (Exception ex)
		{
			System.assertNotEquals(null, ex.getMessage());
		}
		Test.stopTest();
		System.assertNotEquals(null, [SELECT Id FROM Exception_Log__c], 'Test Log count');
	}*/
	static testMethod void exceptionValidationThrowTest()
	{
		Test.startTest();
		try
		{
			LogUtilityException.throwMSG();
		} catch (Exception ex)
		{
			System.assertEquals('Exception occured. Please contact System adminstrator.', ex.getMessage());
		}
		Test.stopTest();
	}
	static testMethod void exceptionValidationAuraThrowTest()
	{
		Test.startTest();
		try
		{
			LogUtilityException.throwAura(new DmlException(), true);
		} catch (Exception ex)
		{
			System.assertNotEquals(null, ex.getMessage());
		}
		Test.stopTest();
	}
	static testMethod void throwAuraTest()
	{
		Test.startTest();
		try
		{
			LogUtilityException.getLimits();
			LogUtilityException.throwAura(null, 'Test', 0, 'info');
		} catch (Exception ex)
		{
			System.assertNotEquals(null, ex.getMessage());
		}
		Test.stopTest();
	}
/*	static testMethod void testSendEmail()
	{
		Messaging.SendEmailResult[] emailResults;
		Test.startTest();
		Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
		msg.setTargetObjectId(UserInfo.getUserId());
		msg.setSaveAsActivity(false);
		msg.setSubject('dear diary');
		msg.setPlainTextBody('he who controls the spice');
		//Test as Fail
		emailResults = Messaging.sendEmail(new List<Messaging.Email>
		{
				msg
		});
		Test.stopTest();
		LogUtilityException.logEmailErrors(emailResults);
	}*/

	static testMethod void testValidationMessage()
	{
		String errMsg = 'Update failed. First exception on row 0 with id 8010k000000NpNkAAK; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, An order must have at least one product.: []';
		String sMsg = LogUtilityException.cleanseValMessage(errMsg);
		System.assertEquals(false, sMsg.contains(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION.name()), 'Cleanse Error');
	}
	static testMethod void testActivationMessage()
	{
		String errMsg = 'Update failed. First exception on row 0 with id 8010k000000NpNkAAK; first error: FAILED_ACTIVATION, An order must have at least one product.: []';
		String sMsg = LogUtilityException.cleanseActMessage(errMsg);
		System.assertEquals(false, sMsg.contains(StatusCode.FAILED_ACTIVATION.name()), 'Cleanse Error');
	}
	static testMethod void testCleanseMessage()
	{
		try
		{
			LogUtilityException.throwMSG('ERROR' + StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION.name());
		} catch (Exception ex)
		{
			LogUtilityException.cleanseExceptionMessage(ex);
		}
	}
	static void testAccountValidationException()
	{
		try
		{
			Account acc = new Account();
			insert acc;
		} catch (Exception e)
		{
			throw e;
		}
	}
	static void testAccountValidationException1()
	{
		try
		{
			testAccountValidationException();
		} catch (Exception ex)
		{
			LogUtilityException.logException('Test', 'Test', ex, null, false);
		}
	}
	/*static void testAccountValidationException2()
	{
		try
		{
			testAccountValidationException();
		} catch (Exception ex)
		{
			LogUtilityException.logException(ex, 'Object');
		}
	}*/
}