/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Question__c object Trigger Handler class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Playbook_Question_TriggerHandler {

    // track current loop for Apex transaction
    public static Boolean firstRunAfterInsert = true;
    public static Boolean firstRunAfterUpdate = true;
    
    /**
    * @description Process to be run in the BEFORE INSERT trigger context
    * @param questions records in trigger execution
    */
    public static void beforeInsert(List<CPQ_Playbook_Question__c> questions) {
        if (firstRunAfterInsert) {
            firstRunAfterInsert = false;
            CPQ_Playbook_Question_UpdatesUtil.sameQuestionBeforeUpdates(
                questions,
                new Map<Id, CPQ_Playbook_Question__c>()
            );
        }        
    }

    /**
    * @description Process to be run in the BEFORE UPDATE trigger context
    * @param questions records in trigger execution
    * @param oldQuestionsMap (Map) Record Id => Old version of record before updates
    */
    public static void beforeUpdate(List<CPQ_Playbook_Question__c> questions, Map<Id, CPQ_Playbook_Question__c> oldQuestionsMap) {
        if (firstRunAfterUpdate) {
            firstRunAfterUpdate = false;
            CPQ_Playbook_Question_UpdatesUtil.sameQuestionBeforeUpdates(
                questions,
                oldQuestionsMap
            );
        }        
    }

}