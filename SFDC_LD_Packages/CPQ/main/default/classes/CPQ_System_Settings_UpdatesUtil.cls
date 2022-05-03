/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_System_Settings__c object Updates class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_System_Settings_UpdatesUtil {

    /****************
     * MAIN METHODS
    ****************/

    /**
    * @description All same CPQ_System_Settings__c updates that should run on Before Insert AND Before Update
    * @param settingsList CPQ_System_Settings__c records with updated/inserted values in trigger context
    * @param oldSettingsMap Map - CPQ_System_Settings__c Id to Old version of CPQ_System_Settings__c
    */ 
    public static void sameSettingsBeforeUpdates(
        List<CPQ_System_Settings__c> settingsList,
        Map<Id, CPQ_System_Settings__c> oldSettingsMap
    ) {

        // Evaluate each CPQ_System_Settings__c
        for (CPQ_System_Settings__c settings : settingsList) {

            CPQ_System_Settings__c oldSettings = new CPQ_System_Settings__c();
            // Not in Insert context
            if (settings.Id != null) {
                oldSettings = oldSettingsMap.get(settings.Id);
            }

            // Check for changes in fields that need validation

            // Quote Table Columns change
            if (settings.Quote_Table_Columns__c != oldSettings.Quote_Table_Columns__c &&
                settings.Quote_Table_Columns__c != null
            ) {

                // Validate Quote Table Columns
                CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                    settings.Quote_Table_Columns__c.split(';'),
                    new List<String>(),
                    'Quote',
                    'Quote Table Columns'
                );
                if (results.result == false) {
                    settings.addError(results.errorMessage);
                }
            }

            // Contract Table Columns change
            if (settings.Contract_Table_Columns__c != oldSettings.Contract_Table_Columns__c &&
                settings.Contract_Table_Columns__c != null
            ) {

                // Validate Contract Table Columns
                CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                    settings.Contract_Table_Columns__c.split(';'),
                    new List<String>(),
                    'Contract',
                    'Contract Table Columns'
                );
                if (results.result == false) {
                    settings.addError(results.errorMessage);
                }
            }
        }
    }
}
