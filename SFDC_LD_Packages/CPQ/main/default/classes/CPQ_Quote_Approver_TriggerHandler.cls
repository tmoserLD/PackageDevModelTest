public class CPQ_Quote_Approver_TriggerHandler {
    
    // track current loop for Apex transaction
    // public static Boolean firstRunAfterUpdate = true;
    
    public static void afterUpdate(List<CPQ_Quote_Approver__c> approvers, Map<Id, CPQ_Quote_Approver__c> oldApproversMap) {
        // if (firstRunAfterUpdate) {
            // firstRunAfterUpdate = false;
        	CPQ_Quote_Approver_UpdatesUtil.processAfterUpdate(approvers, oldApproversMap);
        // }        
    }

}
