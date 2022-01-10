public class OppContractTriggerHandler {

    // track current loop for Apex transaction
    public static Boolean firstRunAfterInsert = true;
    public static Boolean firstRunAfterUpdate = true;

    public static void afterInsert(List<Opportunity> opps) {
        if (firstRunAfterInsert) {
            firstRunAfterInsert = false;
            OppContractUtil.processAfterInsert(opps);
        }        
    }
    
    public static void afterUpdate(List<Opportunity> opps, Map<Id, Opportunity> oldOppsMap) {
        if (firstRunAfterUpdate) {
            firstRunAfterUpdate = false;
            OppContractUtil.processAfterUpdate(opps, oldOppsMap);
        }        
    }

}