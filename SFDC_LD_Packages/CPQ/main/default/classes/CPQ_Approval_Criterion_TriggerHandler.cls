/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Approval_Criterion__c object Trigger Handler class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Approval_Criterion_TriggerHandler {

    // track current loop for Apex transaction
    public static Boolean firstRunAfterInsert = true;
    public static Boolean firstRunAfterUpdate = true;
    
    /**
    * @description Process to be run in the BEFORE INSERT trigger context
    * @param criteria records in trigger execution
    */
    public static void beforeInsert(List<CPQ_Playbook_Approval_Criterion__c> criteria) {
        if (firstRunAfterInsert) {
            firstRunAfterInsert = false;
            CPQ_Approval_Criterion_UpdatesUtil.sameCriterionBeforeUpdates(
                criteria,
                new Map<Id, CPQ_Playbook_Approval_Criterion__c>()
            );
        }        
    }

    /**
    * @description Process to be run in the BEFORE UPDATE trigger context
    * @param criteria records in trigger execution
    * @param oldCriteriaMap (Map) Record Id => Old version of record before updates
    */
    public static void beforeUpdate(List<CPQ_Playbook_Approval_Criterion__c> criteria, Map<Id, CPQ_Playbook_Approval_Criterion__c> oldCriteriaMap) {
        if (firstRunAfterUpdate) {
            firstRunAfterUpdate = false;
            CPQ_Approval_Criterion_UpdatesUtil.sameCriterionBeforeUpdates(
                criteria,
                oldCriteriaMap
            );
        }        
    }

}