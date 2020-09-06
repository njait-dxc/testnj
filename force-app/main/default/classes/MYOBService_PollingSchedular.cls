/**
 * Created by Ankit.Bhardwaj on 22/01/2020.
 */

global class MYOBService_PollingSchedular implements Schedulable, Database.AllowsCallouts {

    //schedular class for pub sub utility
    global void execute(SchedulableContext sc) {
        MYOBService_PubSubPollingUtility.pollPubSubQueue();
    }
}