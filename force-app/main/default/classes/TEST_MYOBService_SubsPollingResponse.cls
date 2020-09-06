/**
 * Created by Ankit.Bhardwaj on 10/06/2020.
 */
@IsTest
public with sharing class TEST_MYOBService_SubsPollingResponse {
    @IsTest
    public static void instantiateClass(){
        MYOBService_SubscriptionPollingResponse.Product subsProduct = new MYOBService_SubscriptionPollingResponse.Product();
        MYOBService_SubscriptionPollingResponse.Features subsFeature = new MYOBService_SubscriptionPollingResponse.Features();
        MYOBService_SubscriptionPollingResponse.Items subsItems = new MYOBService_SubscriptionPollingResponse.Items();
        MYOBService_SubscriptionPollingResponse.Data subsData = new MYOBService_SubscriptionPollingResponse.Data();
        MYOBService_SubscriptionPollingResponse.Contact subsContact = new MYOBService_SubscriptionPollingResponse.Contact();

        //set product
        subsProduct.id ='1234';
        subsProduct.code = 'ARB';
        subsProduct.display_name = 'AccountRight';
        subsProduct.name = 'AccountRight Plus';
        subsProduct.product_line = 'ARP';

        //set feature
        subsFeature.name = 'Test Feature';

        //set Items
        subsItems.start_datetime = '2050-5-20 00:00:00';
        subsItems.end_datetime = '2050-5-25 00:00:00';
        subsItems.updated_at = '2050-5-25 00:00:00';
        subsItems.name = 'Test ARL';

        //set subsData
        subsData.messageId = '12345';

        //set subsContact
        subsContact.identity_id = '12345';

        System.assertEquals(subsProduct.id,'1234');
        System.assertEquals(subsFeature.name,'Test Feature');
        System.assertEquals(subsItems.name,'Test ARL');
        System.assertEquals(subsData.messageId,'12345');
        System.assertEquals(subsContact.identity_id,'12345');
    }
}