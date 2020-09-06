/**
 * Created by Ankit.Bhardwaj on 26/06/2020.
 */

@IsTest
public with sharing class TEST_MYOBService_VictorOpsUtility {

    @IsTest static void sendVicorOpsAlert()
    {
        //start the test
        Test.startTest();
        List<MYOBService_VictorOpsEmailUtility.messageInputs> inputs = new List<MYOBService_VictorOpsEmailUtility.messageInputs>();
        MYOBService_VictorOpsEmailUtility.messageInputs i = new MYOBService_VictorOpsEmailUtility.messageInputs();

        i.subject = 'Test Subject';
        i.body = 'Test Body';
        inputs.add(i);

        MYOBService_VictorOpsEmailUtility.sendVictorOpsAlert(inputs);
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(1,invocations);
        Test.stopTest();
    }
}