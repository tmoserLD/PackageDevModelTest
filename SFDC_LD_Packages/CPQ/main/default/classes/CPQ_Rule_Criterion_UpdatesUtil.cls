/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Rule_Criterion__c object Updates class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Rule_Criterion_UpdatesUtil {

    /****************
     * MAIN METHODS
    ****************/

    /**
    * @description All same CPQ_Playbook_Rule_Criterion__c updates that should run on Before Insert AND Before Update
    * @param criteria CPQ_Playbook_Rule_Criterion__c records with updated/inserted values in trigger context
    * @param oldCriteriaMap Map - CPQ_Playbook_Rule_Criterion__c Id to Old version of CPQ_Playbook_Rule_Criterion__c
    */ 
    public static void sameCriterionBeforeUpdates(
        List<CPQ_Playbook_Rule_Criterion__c> criteria,
        Map<Id, CPQ_Playbook_Rule_Criterion__c> oldCriteriaMap
    ) {

        // Related records to query
        RelatedQueryRecords queriedRecords = new RelatedQueryRecords();

        // Gather Question IDs
        Set<Id> questionIDs = new Set<Id>();
        for (CPQ_Playbook_Rule_Criterion__c criterion : criteria) {
            questionIDs.add(criterion.CPQ_Playbook_Question__c);
        }

        // Evaluate each CPQ_Playbook_Rule_Criterion__c
        for (CPQ_Playbook_Rule_Criterion__c criterion : criteria) {

            CPQ_Playbook_Rule_Criterion__c oldCriterion = new CPQ_Playbook_Rule_Criterion__c();
            // Not in Insert context
            if (criterion.Id != null) {
                oldCriterion = oldCriteriaMap.get(criterion.Id);
            }

            // Check for changes in fields that need validation

            // Product Field field or Product Is Entitlement field change
            if (
                (
                    criterion.Product_Field__c != oldCriterion.Product_Field__c ||
                    criterion.Product_Is_Entitlement__c != oldCriterion.Product_Is_Entitlement__c
                ) &&
                criterion.Product_Field__c != null
            ) {

                // QLI/Entitlement distinctions
                List<String> allowedCPQValues = new List<String>();
                String objectName = 'Contract_Entitlement__c';
                if (criterion.Product_Is_Entitlement__c == false) {
                    allowedCPQValues = new List<String>{
                        'Product_Name',
                        'Start_Date',
                        'End_Date',
                        'Quantity',
                        'Discount',
                        'Unit_Price',
                        'List_Price',
                        'Sub_Total_Price',
                        'Total_Price'
                    };
                    objectName = 'QuoteLineItem';
                }

                // Validate Product Field field
                CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                    new List<String>{criterion.Product_Field__c},
                    allowedCPQValues,
                    objectName,
                    'Product Field'
                );
                if (results.result == false) {
                    criterion.addError(results.errorMessage);
                }
            }

            // Record Lookup Field field change
            if (criterion.Record_Lookup_Field__c != oldCriterion.Record_Lookup_Field__c &&
                criterion.Record_Lookup_Field__c != null
            ) {

                // Find related question
                CPQ_Playbook_Question__c question = getLookupQuestion(
                    criterion.CPQ_Playbook_Question__c,
                    questionIDs,
                    queriedRecords
                );

                if (question?.Query_String__c != null) {

                    String objectName = question.Query_String__c.toLowerCase().split('from')[1].split(' ')[1];
                    
                    // Validate Default Field Value field
                    CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                        new List<String>{criterion.Record_Lookup_Field__c},
                        new List<String>(),
                        objectName,
                        'Record Lookup Field'
                    );
                    if (results.result == false) {
                        criterion.addError(results.errorMessage);
                    }
                }
            }
        }
    }


    /****************
     * QUERY HELPER METHODS
     ****************/

    /**
    * @description Get Question housing record lookup value
    * @param questionId Id of question record
    * @param allQuestionIDs All question IDs for all criterion records in trigger context
    * @param queriedRecords Current state of helper object to determine which related records have been queried
    * @return CPQ_Playbook_Question__c
    */
    private static CPQ_Playbook_Question__c getLookupQuestion(
        Id questionId,
        Set<Id> allQuestionIDs,
        RelatedQueryRecords queriedRecords
    ) {

        // Query question records ONLY if not already queried in this transaction
        if (queriedRecords.lookupQuestions == null) {
            // Define questions map
            queriedRecords.lookupQuestions = new Map<Id, CPQ_Playbook_Question__c>();

            // Query questions
            for (CPQ_Playbook_Question__c q : [
                SELECT Id,
                    Query_String__c
                FROM CPQ_Playbook_Question__c
                WHERE Id IN:allQuestionIDs AND
                    Answer_Type__c = 'Record Lookup'
            ]) {
                queriedRecords.lookupQuestions.put(q.Id, q);
            }
        }

        return queriedRecords.lookupQuestions.get(questionId);
    }

    /**
	* @description Helper object to help store related records to query
	*/ 
    public class RelatedQueryRecords {
        public Map<Id, CPQ_Playbook_Question__c> lookupQuestions;
    }
}
