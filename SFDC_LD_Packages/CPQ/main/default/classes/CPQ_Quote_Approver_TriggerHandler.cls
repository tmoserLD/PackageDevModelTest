/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description CPQ_Quote_Approver__c object Trigger Handler class
*
* Tested by CPQ_Approval_Automation_Test
*/
public class CPQ_Quote_Approver_TriggerHandler {
    
    // track current loop for Apex transaction
    // public static Boolean firstRunAfterUpdate = true;
    
    /**
    * @description Process to be run in the AFTER UPDATE trigger context
    * @param approvers records in trigger execution
    * @param oldApproversMap (Map) Record Id => Old version of record before updates
    */
    public static void afterUpdate(List<CPQ_Quote_Approver__c> approvers, Map<Id, CPQ_Quote_Approver__c> oldApproversMap) {
        // if (firstRunAfterUpdate) {
            // firstRunAfterUpdate = false;
        	CPQ_Quote_Approver_UpdatesUtil.processAfterUpdate(approvers, oldApproversMap);
        // }        
    }

}
