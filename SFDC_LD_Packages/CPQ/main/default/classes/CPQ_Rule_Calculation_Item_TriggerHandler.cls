/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Rule_Calculation_Item__c object Trigger Handler class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Rule_Calculation_Item_TriggerHandler {

    // track current loop for Apex transaction
    public static Boolean firstRunAfterInsert = true;
    public static Boolean firstRunAfterUpdate = true;
    
    /**
    * @description Process to be run in the BEFORE INSERT trigger context
    * @param items records in trigger execution
    */
    public static void beforeInsert(List<CPQ_Playbook_Rule_Calculation_Item__c> items) {
        if (firstRunAfterInsert) {
            firstRunAfterInsert = false;
            CPQ_Rule_Calculation_Item_UpdatesUtil.sameItemBeforeUpdates(
                items,
                new Map<Id, CPQ_Playbook_Rule_Calculation_Item__c>()
            );
        }        
    }

    /**
    * @description Process to be run in the BEFORE UPDATE trigger context
    * @param items records in trigger execution
    * @param oldItemsMap (Map) Record Id => Old version of record before updates
    */
    public static void beforeUpdate(List<CPQ_Playbook_Rule_Calculation_Item__c> items, Map<Id, CPQ_Playbook_Rule_Calculation_Item__c> oldItemsMap) {
        if (firstRunAfterUpdate) {
            firstRunAfterUpdate = false;
            CPQ_Rule_Calculation_Item_UpdatesUtil.sameItemBeforeUpdates(
                items,
                oldItemsMap
            );
        }        
    }

}