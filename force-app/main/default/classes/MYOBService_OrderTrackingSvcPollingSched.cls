/**
 * Created by Ankit.Bhardwaj on 2/07/2020.
 */

public with sharing class MYOBService_OrderTrackingSvcPollingSched implements Schedulable{

        public String API_NAME;

        public MYOBService_OrderTrackingSvcPollingSched(String apiName)
        {
            this.API_NAME = apiName;
        }
        public void execute(SchedulableContext sc){
            System.enqueueJob(new MYOBService_OrderTrackingSvcPollingQue(API_NAME));
        }
    }