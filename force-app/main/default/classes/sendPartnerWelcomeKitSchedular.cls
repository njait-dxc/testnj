global class sendPartnerWelcomeKitSchedular implements Schedulable {
    
    // The first job in the sequence is kicked off from this scheduler
    global void execute(SchedulableContext SC) {
        // Following jobs get kicked off from corresponding finish methods 
        SendPartnerWelcomeKitUtility welcomeKit = new SendPartnerWelcomeKitUtility();
        welcomeKit.SendPartnerWelcomeKit();     
    }
}