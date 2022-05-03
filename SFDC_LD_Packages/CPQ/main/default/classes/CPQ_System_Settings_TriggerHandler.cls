/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_System_Settings__c object Trigger Handler class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_System_Settings_TriggerHandler {

    // track current loop for Apex transaction
    public static Boolean firstRunAfterInsert = true;
    public static Boolean firstRunAfterUpdate = true;
    
    /**
    * @description Process to be run in the BEFORE INSERT trigger context
    * @param settingsList records in trigger execution
    */
    public static void beforeInsert(List<CPQ_System_Settings__c> settingsList) {
        if (firstRunAfterInsert) {
            firstRunAfterInsert = false;
            CPQ_System_Settings_UpdatesUtil.sameSettingsBeforeUpdates(
                settingsList,
                new Map<Id, CPQ_System_Settings__c>()
            );
        }        
    }

    /**
    * @description Process to be run in the BEFORE UPDATE trigger context
    * @param settingsList records in trigger execution
    * @param oldSettingsMap (Map) Record Id => Old version of record before updates
    */
    public static void beforeUpdate(List<CPQ_System_Settings__c> settingsList, Map<Id, CPQ_System_Settings__c> oldSettingsMap) {
        if (firstRunAfterUpdate) {
            firstRunAfterUpdate = false;
            CPQ_System_Settings_UpdatesUtil.sameSettingsBeforeUpdates(
                settingsList,
                oldSettingsMap
            );
        }        
    }

}