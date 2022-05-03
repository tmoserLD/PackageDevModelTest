/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Rule_Action__c object Trigger Handler class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Rule_Action_TriggerHandler {

    // track current loop for Apex transaction
    public static Boolean firstRunAfterInsert = true;
    public static Boolean firstRunAfterUpdate = true;
    
    /**
    * @description Process to be run in the BEFORE INSERT trigger context
    * @param actions records in trigger execution
    */
    public static void beforeInsert(List<CPQ_Playbook_Rule_Action__c> actions) {
        if (firstRunAfterInsert) {
            firstRunAfterInsert = false;
            CPQ_Rule_Action_UpdatesUtil.sameActionBeforeUpdates(
                actions,
                new Map<Id, CPQ_Playbook_Rule_Action__c>()
            );
        }        
    }

    /**
    * @description Process to be run in the BEFORE UPDATE trigger context
    * @param actions records in trigger execution
    * @param oldActionsMap (Map) Record Id => Old version of record before updates
    */
    public static void beforeUpdate(List<CPQ_Playbook_Rule_Action__c> actions, Map<Id, CPQ_Playbook_Rule_Action__c> oldActionsMap) {
        if (firstRunAfterUpdate) {
            firstRunAfterUpdate = false;
            CPQ_Rule_Action_UpdatesUtil.sameActionBeforeUpdates(
                actions,
                oldActionsMap
            );
        }        
    }

}