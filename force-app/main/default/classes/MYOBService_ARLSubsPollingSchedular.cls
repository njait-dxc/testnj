/**
 * Created by Ankit.Bhardwaj on 2/07/2020.
 */

public with sharing class MYOBService_ARLSubsPollingSchedular implements Schedulable{
        public void execute(SchedulableContext sc){
            System.enqueueJob(new MYOBService_ARLSubsPollingQue());
        }
    }