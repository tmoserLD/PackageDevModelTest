/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description CPQ_Quote_Approval_Step__c object Updates class
*
* Tested by CPQ_Approval_Automation_Test
*/
public with sharing class CPQ_Quote_Approval_Step_UpdatesUtil {

    /****************
     * ENTRY METHODS
    ****************/

    /**
    * @description Logic run after a CPQ_Quote_Approval_Step__c Update
    * Handles updates of related records
    * @param updatedSteps CPQ_Quote_Approval_Step__c records with updated values in trigger context
    * @param oldStepsMap Map - CPQ_Quote_Approval_Step__c Id to Old version of CPQ_Quote_Approval_Step__c
    */ 
    public static void processAfterUpdate(
        List<CPQ_Quote_Approval_Step__c> updatedSteps,
        Map<Id, CPQ_Quote_Approval_Step__c> oldStepsMap
    ) {
        relatedObjectAfterUpdates(
            updatedSteps,
            oldStepsMap
        );
    }

    /****************
     * MAIN METHODS
    ****************/

    /**
    * @description All same Related Object updates that should run on After Insert AND After Update
    * @param steps CPQ_Quote_Approval_Step__c records with updated/inserted values in trigger context
    * @param oldStepsMap Map - CPQ_Quote_Approval_Step__c Id to Old version of CPQ_Quote_Approval_Step__c
    */ 
    public static void relatedObjectAfterUpdates(
        List<CPQ_Quote_Approval_Step__c> steps,
        Map<Id, CPQ_Quote_Approval_Step__c> oldStepsMap
    ) {

        // Gather Related IDs that may be needed
        Set<Id> approvalIDs = new Set<Id>();
        for (CPQ_Quote_Approval_Step__c step : steps) {
            approvalIDs.add(step.CPQ_Quote_Approval__c);
        }

        // Related records to query
        RelatedQueryRecords queriedRecords = new RelatedQueryRecords();

        // sObject records to update
        Map<Id, sObject> relatedRecordsToUpdate = new Map<Id, sObject>();

        // Evaluate each CPQ_Quote_Approval_Step__c
        for (CPQ_Quote_Approval_Step__c step : steps) {

            // Get Old version of CPQ_Quote_Approval_Step__c
            CPQ_Quote_Approval_Step__c oldStep = new CPQ_Quote_Approval_Step__c();
            // Not in Insert context
            if (oldStepsMap.containsKey(step.Id)) {
                oldStep = oldStepsMap.get(step.Id);
            }

            // Status change
            if (step.Status__c != oldStep.Status__c) {

                // Approved
                if (step.Status__c == 'Approved') {
                    List<CPQ_Quote_Approval_Step__c> approvalSteps = getApprovalSteps(
                        step.CPQ_Quote_Approval__c,
                        approvalIDs,
                        queriedRecords
                    );
                    // Last Step
                    if (step.Approval_Order__c >= approvalSteps[approvalSteps.size() -1].Approval_Order__c) {
                        CPQ_Quote_Approval__c approvalToUpdate = (CPQ_Quote_Approval__c) relatedRecordMapUpdate(new CPQ_Quote_Approval__c(Id=step.CPQ_Quote_Approval__c), relatedRecordsToUpdate);
                        approvalToUpdate.Status__c = 'Approved';
                    }
                    // Not Last Step
                    else {
                        // Find and Submit next step
                        for (CPQ_Quote_Approval_Step__c approvalStep : approvalSteps) {
                            if (approvalStep.Approval_Order__c > step.Approval_Order__c) {
                                // Step
                                CPQ_Quote_Approval_Step__c stepToUpdate = (CPQ_Quote_Approval_Step__c) relatedRecordMapUpdate(approvalStep, relatedRecordsToUpdate);
                                stepToUpdate.Status__c = 'Submitted';
                                // Approvers
                                for (CPQ_Quote_Approver__c approver : approvalStep.CPQ_Quote_Approvers__r) {
                                    CPQ_Quote_Approver__c approverToUpdate = (CPQ_Quote_Approver__c) relatedRecordMapUpdate(approver, relatedRecordsToUpdate);
                                    approverToUpdate.Status__c = 'Submitted';
                                }
                                break;
                            }
                        }
                    }

                    // Recall remaining child approvers
                    for (CPQ_Quote_Approval_Step__c approvalStep : approvalSteps) {
                        if (approvalStep.Id == step.Id) {
                            // Approvers
                            for (CPQ_Quote_Approver__c approver : approvalStep.CPQ_Quote_Approvers__r) {
                                if (approver.Status__c == 'Submitted' ||
                                    approver.Status__c == 'Pending'
                                ) {
                                    CPQ_Quote_Approver__c approverToUpdate = (CPQ_Quote_Approver__c) relatedRecordMapUpdate(approver, relatedRecordsToUpdate);
                                    approverToUpdate.Status__c = 'Recalled';
                                }
                            }
                            break;
                        }
                    }
                }

                // Rejected
                else if (step.Status__c == 'Rejected') {
                    List<CPQ_Quote_Approval_Step__c> approvalSteps = getApprovalSteps(
                        step.CPQ_Quote_Approval__c,
                        approvalIDs,
                        queriedRecords
                    );

                    // Recall child approvers and future steps/approvers
                    for (CPQ_Quote_Approval_Step__c approvalStep : approvalSteps) {

                        if (approvalStep.Approval_Order__c >= step.Approval_Order__c) {
                            if (approvalStep.Id != step.Id) {
                                // Step
                                CPQ_Quote_Approval_Step__c stepToUpdate = (CPQ_Quote_Approval_Step__c) relatedRecordMapUpdate(approvalStep, relatedRecordsToUpdate);
                                stepToUpdate.Status__c = 'Recalled';
                            }
                            // Approvers
                            for (CPQ_Quote_Approver__c approver : approvalStep.CPQ_Quote_Approvers__r) {
                                if (approver.Status__c == 'Submitted' ||
                                    approver.Status__c == 'Pending'
                                ) {
                                    CPQ_Quote_Approver__c approverToUpdate = (CPQ_Quote_Approver__c) relatedRecordMapUpdate(approver, relatedRecordsToUpdate);
                                    approverToUpdate.Status__c = 'Recalled';
                                }
                            }
                        }
                    }

                    // Reject approval
                    CPQ_Quote_Approval__c approvalToUpdate = (CPQ_Quote_Approval__c) relatedRecordMapUpdate(new CPQ_Quote_Approval__c(Id=step.CPQ_Quote_Approval__c), relatedRecordsToUpdate);
                    approvalToUpdate.Status__c = 'Rejected';
                }

                // Recalled
                else if (step.Status__c == 'Recalled') {
                    List<CPQ_Quote_Approval_Step__c> approvalSteps = getApprovalSteps(
                        step.CPQ_Quote_Approval__c,
                        approvalIDs,
                        queriedRecords
                    );

                    // Recall child approvers and future steps/approvers
                    for (CPQ_Quote_Approval_Step__c approvalStep : approvalSteps) {

                        if (approvalStep.Approval_Order__c >= step.Approval_Order__c) {
                            if (approvalStep.Id != step.Id) {
                                // Step
                                CPQ_Quote_Approval_Step__c stepToUpdate = (CPQ_Quote_Approval_Step__c) relatedRecordMapUpdate(approvalStep, relatedRecordsToUpdate);
                                stepToUpdate.Status__c = 'Recalled';
                            }
                            // Approvers
                            for (CPQ_Quote_Approver__c approver : approvalStep.CPQ_Quote_Approvers__r) {
                                if (approver.Status__c == 'Submitted' ||
                                    approver.Status__c == 'Pending'
                                ) {
                                    CPQ_Quote_Approver__c approverToUpdate = (CPQ_Quote_Approver__c) relatedRecordMapUpdate(approver, relatedRecordsToUpdate);
                                    approverToUpdate.Status__c = 'Recalled';
                                }
                            }
                        }
                    }

                    // Recall approval
                    CPQ_Quote_Approval__c approvalToUpdate = (CPQ_Quote_Approval__c) relatedRecordMapUpdate(new CPQ_Quote_Approval__c(Id=step.CPQ_Quote_Approval__c), relatedRecordsToUpdate);
                    approvalToUpdate.Status__c = 'Recalled';
                }
            }

        }

        // Update related records if present
        if (relatedRecordsToUpdate.size() > 0) {
            // Get records from map
            List<sObject> relatedRecords = relatedRecordsToUpdate.values();
            // Sort records by sObject to avoid execution batch limit
            relatedRecords.sort();
            // Update records
            update relatedRecords;
        }
    }

    /****************
     * HELPER METHODS
     ****************/

    /**
    * @description Helper method to ensure record is populated in map.
    * If already populated, retrieves most updated version in current trigger context
    * @param record sObject that needs to placed/retrieved from map
    * @param relatedRecordsToUpdate Current state of related records that need to be updated map
    * @return sObject with all updates currently set in trigger context
    */ 
    private static sObject relatedRecordMapUpdate(
        sObject record,
        Map<Id, sObject> relatedRecordsToUpdate
    ) {
        if (!relatedRecordsToUpdate.containsKey(record.Id)) {
            relatedRecordsToUpdate.put(record.Id, record);
        }
        return relatedRecordsToUpdate.get(record.Id);
    }

    /****************
     * QUERY HELPER METHODS
     ****************/

    /**
    * @description Get all CPQ_Quote_Approval_Step__c records for a given CPQ_Quote_Approval_Step__c's approval
    * @param approvalId CPQ_Quote_Approval__c value of CPQ_Quote_Approval_Step__c CPQ_Quote_Approval__c record is needed for
    * @param allApprovalIDs All CPQ_Quote_Approval_Step__c CPQ_Quote_Approval__c values for all CPQ_Quote_Approval_Step__c records in trigger context
    * @param queriedRecords Current state of helper object to determine which related records have been queried
    * @return List<CPQ_Quote_Approval_Step__c>
    */
    private static List<CPQ_Quote_Approval_Step__c> getApprovalSteps(
        Id approvalId,
        Set<Id> allApprovalIDs,
        RelatedQueryRecords queriedRecords
    ) {

        // Query CPQ_Quote_Approval_Step__c records ONLY if not already queried in this transaction
        if (queriedRecords.approvalSteps == null) {
            // Define Approvals map
            queriedRecords.approvalSteps = new Map<Id, List<CPQ_Quote_Approval_Step__c>>();
            // Query and organize Approvals by Opportunity
            for (CPQ_Quote_Approval_Step__c step : [
                SELECT Id,
                    Approval_Order__c,
                    CPQ_Quote_Approval__c,
                    Status__c,
                    (
                        SELECT Id,
                            Status__c
                        FROM CPQ_Quote_Approvers__r
                    )
                FROM CPQ_Quote_Approval_Step__c
                WHERE CPQ_Quote_Approval__c IN:allApprovalIDs
                ORDER BY Approval_Order__c ASC
            ]) {
                if (!queriedRecords.approvalSteps.containsKey(step.CPQ_Quote_Approval__c)) {
                    queriedRecords.approvalSteps.put(step.CPQ_Quote_Approval__c, new List<CPQ_Quote_Approval_Step__c>());
                }
                queriedRecords.approvalSteps.get(step.CPQ_Quote_Approval__c).add(step);
            }
        }

        return queriedRecords.approvalSteps.get(approvalId);
    }

    /**
    * @description Helper object to help store related records to query
    */ 
    public class RelatedQueryRecords {
        public Map<Id, List<CPQ_Quote_Approval_Step__c>> approvalSteps;
    }
}