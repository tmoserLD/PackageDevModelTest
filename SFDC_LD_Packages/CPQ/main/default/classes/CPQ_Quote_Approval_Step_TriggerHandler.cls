public class CPQ_Quote_Approval_Step_TriggerHandler {

    // track current loop for Apex transaction
    public static Boolean firstRunAfterUpdate = true;
    
    public static void afterUpdate(List<CPQ_Quote_Approval_Step__c> steps, Map<Id, CPQ_Quote_Approval_Step__c> oldStepsMap) {
        if (firstRunAfterUpdate) {
            firstRunAfterUpdate = false;
            CPQ_Quote_Approval_Step_UpdatesUtil.processAfterUpdate(steps, oldStepsMap);
        }        
    }

}
    