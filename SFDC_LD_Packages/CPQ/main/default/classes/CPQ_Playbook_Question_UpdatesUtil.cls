/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Question__c object Updates class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Playbook_Question_UpdatesUtil {

    /****************
     * MAIN METHODS
    ****************/

    /**
    * @description All same CPQ_Playbook_Question__c updates that should run on Before Insert AND Before Update
    * @param questions CPQ_Playbook_Question__c records with updated/inserted values in trigger context
    * @param oldQuestionsMap Map - CPQ_Playbook_Question__c Id to Old version of CPQ_Playbook_Question__c
    */ 
    public static void sameQuestionBeforeUpdates(
        List<CPQ_Playbook_Question__c> questions,
        Map<Id, CPQ_Playbook_Question__c> oldQuestionsMap
    ) {

        // Evaluate each CPQ_Playbook_Question__c
        for (CPQ_Playbook_Question__c question : questions) {

            CPQ_Playbook_Question__c oldQuestion = new CPQ_Playbook_Question__c();
            // Not in Insert context
            if (question.Id != null) {
                oldQuestion = oldQuestionsMap.get(question.Id);
            }

            // Check for changes in fields that need validation

            // Query String or Record Display Fields change
            if (
                (
                    question.Record_Display_Fields__c != oldQuestion.Record_Display_Fields__c ||
                    question.Query_String__c != oldQuestion.Query_String__c
                 ) &&
                question.Query_String__c != null &&
                question.Record_Display_Fields__c != null
            ) {


                // Validate Query String field
                CPQ_Record_Validation.ResultClass queryResults = CPQ_Record_Validation.verifyQuery(
                    question.Query_String__c,
                    'Query String'
                );
                if (queryResults.result == false) {
                    question.addError(queryResults.errorMessage);
                }

                // Valid Query
                else {
                    // Extract Object name from query string
                    String objectName = question.Query_String__c.toLowerCase().split('from')[1].split(' ')[1];

                    // Validate Record Display Fields field
                    CPQ_Record_Validation.ResultClass displayResults = CPQ_Record_Validation.verifyFields(
                        question.Record_Display_Fields__c.split(';'),
                        new List<String>(),
                        objectName,
                        'Record Display Fields'
                    );
                    if (displayResults.result == false) {
                        question.addError(displayResults.errorMessage);
                    }
                }
            }

            // Quote Save Field change
            if (question.Quote_Save_Field__c != oldQuestion.Quote_Save_Field__c &&
                question.Quote_Save_Field__c != null
            ) {

                // Validate Quote Save Field field
                CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                    new List<String>{question.Quote_Save_Field__c},
                    new List<String>(),
                    'Quote',
                    'Quote Save Field'
                );
                if (results.result == false) {
                    question.addError(results.errorMessage);
                }
            }

            // Default Field Value change
            if (question.Default_Field_Value__c != oldQuestion.Default_Field_Value__c &&
                question.Default_Field_Value__c != null
            ) {
                
                // Validate Default Field Value field
                CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyObjectFieldPair(
                    question.Default_Field_Value__c,
                    new Map<String, String>{
                        'Account' => 'Account',
                        'Opportunity' => 'Opportunity',
                        'Quote' => 'Quote',
                        'Contract' => 'Contract',
                        'Profile' => 'Profile',
                        'UserRole' => 'UserRole',
                        'User' => 'User'
                    },
                    'Default Field Value'
                );
                if (results.result == false) {
                    question.addError(results.errorMessage);
                }
            }
        }
    }
}
