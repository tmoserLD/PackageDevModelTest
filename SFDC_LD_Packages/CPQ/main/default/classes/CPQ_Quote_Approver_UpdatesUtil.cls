/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description CPQ_Quote_Approver__c object Updates class
*
* Tested by CPQ_Approval_Automation_Test
*/
public with sharing class CPQ_Quote_Approver_UpdatesUtil {

    // Parent steps should only be updated once per execution
    public static Boolean runStepUpdates = true;

    /****************
     * ENTRY METHODS
    ****************/

    /**
    * @description Logic run before a CPQ_Quote_Approver__c Update
    * Handles updates on CPQ_Quote_Approver__c itself
    * @param updatedApprovers CPQ_Quote_Approver__c records with updated values in trigger context
    * @param oldApproversMap Map - CPQ_Quote_Approver__c Id to Old version of CPQ_Quote_Approver__c
    */ 
    public static void processBeforeUpdate(
        List<CPQ_Quote_Approver__c> updatedApprovers,
        Map<Id, CPQ_Quote_Approver__c> oldApproversMap
    ) {
        sameApproverBeforeUpdates(
            updatedApprovers,
            oldApproversMap
        );
    }

    /**
    * @description Logic run after a CPQ_Quote_Approver__c Update
    * Handles updates of related records
    * @param updatedApprovers CPQ_Quote_Approver__c records with updated values in trigger context
    * @param oldApproversMap Map - CPQ_Quote_Approver__c Id to Old version of CPQ_Quote_Approver__c
    */ 
    public static void processAfterUpdate(
        List<CPQ_Quote_Approver__c> updatedApprovers,
        Map<Id, CPQ_Quote_Approver__c> oldApproversMap
    ) {
        relatedObjectAfterUpdates(
            updatedApprovers,
            oldApproversMap
        );
    }

    /****************
     * MAIN METHODS
    ****************/

    /**
    * @description All same CPQ_Quote_Approver__c updates that should run on Before Insert AND Before Update
    * @param approvers CPQ_Quote_Approver__c records with updated/inserted values in trigger context
    * @param oldApproversMap Map - CPQ_Quote_Approver__c Id to Old version of CPQ_Quote_Approver__c
    */ 
    public static void sameApproverBeforeUpdates(
        List<CPQ_Quote_Approver__c> approvers,
        Map<Id, CPQ_Quote_Approver__c> oldApproversMap
    ) {

        // Evaluate each CPQ_Quote_Approver__c
        for (CPQ_Quote_Approver__c approver : approvers) {

            CPQ_Quote_Approver__c oldApprover = new CPQ_Quote_Approver__c();
            // Not in Insert context
            if (approver.Id != null) {
                oldApprover = oldApproversMap.get(approver.Id);
            }

            // Track Status Changes
            if (approver.Status__c != oldApprover.Status__c) {

                // Approved
                if (approver.Status__c == 'Approved') {
                    approver.Approved_Date__c = Date.today();
                }

                // Rejected
                else if (approver.Status__c == 'Rejected') {
                    approver.Rejected_Date__c = Date.today();
                }

                // Recalled
                else if (approver.Status__c == 'Recalled') {
                    approver.Recalled_Date__c = Date.today();
                }

                // Submitted
                else if (approver.Status__c == 'Submitted') {
                    approver.Submitted_Date__c = Date.today();
                }
            }
        }
    }

    /**
    * @description All same Related Object updates that should run on After Insert AND After Update
    * @param approvers CPQ_Quote_Approver__c records with updated/inserted values in trigger context
    * @param oldApproversMap Map - CPQ_Quote_Approver__c Id to Old version of CPQ_Quote_Approver__c
    */ 
    public static void relatedObjectAfterUpdates(
        List<CPQ_Quote_Approver__c> approvers,
        Map<Id, CPQ_Quote_Approver__c> oldApproversMap
    ) {

        // Gather Related IDs that may be needed
        Set<Id> approvalStepIDs = new Set<Id>();
        Set<Id> approverIDs = new Set<Id>();
        for (CPQ_Quote_Approver__c approver : approvers) {
            approvalStepIDs.add(approver.CPQ_Quote_Approval_Step__c);
            approverIDs.add(approver.Id);
        }

        // Related records to query
        RelatedQueryRecords queriedRecords = new RelatedQueryRecords();

        // sObject records to update
        Map<Id, sObject> relatedRecordsToUpdate = new Map<Id, sObject>();

        // Work Items to update
        List<Approval.ProcessWorkitemRequest> workItemsToUpdate = new List<Approval.ProcessWorkitemRequest>();

        // Approvers to unlock
        List<CPQ_Quote_Approver__c> approversToUnlock = new List<CPQ_Quote_Approver__c>();

        // Approvers to submit
        list<Approval.ProcessSubmitRequest> approverSubmissions = new list<Approval.ProcessSubmitRequest>();

        // Evaluate each CPQ_Quote_Approver__c
        for (CPQ_Quote_Approver__c approver : approvers) {

            // Get Old version of CPQ_Quote_Approver__c
            CPQ_Quote_Approver__c oldApprover = new CPQ_Quote_Approver__c();
            // Not in Insert context
            if (oldApproversMap.containsKey(approver.Id)) {
                oldApprover = oldApproversMap.get(approver.Id);
            }

            // Status change
            if (approver.Status__c != oldApprover.Status__c) {

                // Submitted
                if (approver.Status__c == 'Submitted') {
                    CPQ_Quote_Approval_Step__c approvalStep = getApprovalStep(
                        approver.CPQ_Quote_Approval_Step__c,
                        approvalStepIDs,
                        queriedRecords
                    );
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments(approvalStep.CPQ_Quote_Approval__r?.Notes_for_Approvers__c);
                    req.setObjectId(approver.Id);
                    approverSubmissions.add(req);
                }

                // Approved
                else if (approver.Status__c == 'Approved') {
                    CPQ_Quote_Approval_Step__c approvalStep = getApprovalStep(
                        approver.CPQ_Quote_Approval_Step__c,
                        approvalStepIDs,
                        queriedRecords
                    );
                    Integer numberApproved = 0;
                    for (CPQ_Quote_Approver__c stepApprover : approvalStep.CPQ_Quote_Approvers__r) {
                        if (stepApprover.Status__c == 'Approved') {
                            numberApproved += 1;
                        }
                    }
                    // Approved Approvers at or above threshold for step
                    if (numberApproved >= approvalStep.CPQ_Playbook_Approver_Group__r.Approvers_Required__c) {
                        CPQ_Quote_Approval_Step__c stepToUpdate = (CPQ_Quote_Approval_Step__c) relatedRecordMapUpdate(approvalStep, relatedRecordsToUpdate);
                        stepToUpdate.Status__c = 'Approved';
                    }

                    // Get approval work item for this approver
                    ProcessInstanceWorkItem approverWorkItem = getWorkItem(
                        approver.Id,
                        approverIDs,
                        queriedRecords
                    );
                    if (approverWorkItem != null) {
                        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                        req.setAction('Approve');
                        req.setWorkitemId(approverWorkItem.Id);
                        if (approver.Decision_Reason__c != null) {
                            req.setComments(approver.Decision_Reason__c);
                        }
                        workItemsToUpdate.add(req);

                        approversToUnlock.add(new CPQ_Quote_Approver__c(Id=approver.Id));
                    }
                }

                // Rejected
                else if (approver.Status__c == 'Rejected') {
                    CPQ_Quote_Approval_Step__c approvalStep = getApprovalStep(
                        approver.CPQ_Quote_Approval_Step__c,
                        approvalStepIDs,
                        queriedRecords
                    );
                    Integer numberRejected = 0;
                    for (CPQ_Quote_Approver__c stepApprover : approvalStep.CPQ_Quote_Approvers__r) {
                        if (stepApprover.Status__c == 'Rejected') {
                            numberRejected += 1;
                        }
                    }

                    // Rejected Approvers outnumber approved threshold for step
                    if (numberRejected > (approvalStep.Total_Approvers__c - approvalStep.CPQ_Playbook_Approver_Group__r.Approvers_Required__c)) {
                        CPQ_Quote_Approval_Step__c stepToUpdate = (CPQ_Quote_Approval_Step__c) relatedRecordMapUpdate(approvalStep, relatedRecordsToUpdate);
                        stepToUpdate.Status__c = 'Rejected';
                    }

                    // Get approval work item for this approver
                    ProcessInstanceWorkItem approverWorkItem = getWorkItem(
                        approver.Id,
                        approverIDs,
                        queriedRecords
                    );
                    if (approverWorkItem != null) {
                        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                        req.setAction('Reject');
                        req.setWorkitemId(approverWorkItem.Id);
                        if (approver.Decision_Reason__c != null) {
                            req.setComments(approver.Decision_Reason__c);
                        }
                        workItemsToUpdate.add(req);

                        approversToUnlock.add(new CPQ_Quote_Approver__c(Id=approver.Id));
                    }
                }

                // Recalled
                else if (approver.Status__c == 'Recalled') {
                    CPQ_Quote_Approval_Step__c approvalStep = getApprovalStep(
                        approver.CPQ_Quote_Approval_Step__c,
                        approvalStepIDs,
                        queriedRecords
                    );

                    if (runStepUpdates) {
                        // Recall initiated by submitter -- recall step
                        CPQ_Quote_Approval_Step__c stepToUpdate = (CPQ_Quote_Approval_Step__c) relatedRecordMapUpdate(approvalStep, relatedRecordsToUpdate);
                        stepToUpdate.Status__c = 'Recalled';
                    }

                    // Get approval work item for this approver
                    ProcessInstanceWorkItem approverWorkItem = getWorkItem(
                        approver.Id,
                        approverIDs,
                        queriedRecords
                    );
                    if (approverWorkItem != null) {
                        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                        req.setAction('Removed');
                        req.setWorkitemId(approverWorkItem.Id);
                        workItemsToUpdate.add(req);

                        approversToUnlock.add(new CPQ_Quote_Approver__c(Id=approver.Id));
                    }
                }
            }
        }

        // Only allow step updates on first run
        runStepUpdates = false;

        // Update related records if present
        if (relatedRecordsToUpdate.size() > 0) {
            // Get records from map
            List<sObject> relatedRecords = relatedRecordsToUpdate.values();
            // Sort records by sObject to avoid execution batch limit
            relatedRecords.sort();
            // Update records
            update relatedRecords;
        }

        // Update work items if present
        if (workItemsToUpdate.size() > 0) {
            Approval.ProcessResult[] processResults = null;
            processResults = Approval.process(workItemsToUpdate, true);
        }

        // Unlock approvers if present
        if (approversToUnlock.size() > 0) {
            Approval.UnlockResult[] urList = Approval.unlock(approversToUnlock, false);
        }

        // Submit approvers if present
        if (approverSubmissions.size() > 0) {
            Approval.process(approverSubmissions);
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
    * @description Get CPQ_Quote_Approval_Step__c record for a given CPQ_Quote_Approver__c
    * @param stepId CPQ_Quote_Approval_Step__c value of CPQ_Quote_Approver__c CPQ_Quote_Approval_Step__c record is needed for
    * @param allStepIDs All CPQ_Quote_Approver__c CPQ_Quote_Approval_Step__c values for all CPQ_Quote_Approver__c records in trigger context
    * @param queriedRecords Current state of helper object to determine which related records have been queried
    * @return CPQ_Quote_Approval_Step__c
    */
    private static CPQ_Quote_Approval_Step__c getApprovalStep(
        Id stepId,
        Set<Id> allStepIDs,
        RelatedQueryRecords queriedRecords
    ) {

        // Query CPQ_Quote_Approval_Step__c records ONLY if not already queried in this transaction
        if (queriedRecords.approvalSteps == null) {
            // Define Step map
            queriedRecords.approvalSteps = new Map<Id, CPQ_Quote_Approval_Step__c>();
            // Query and organize Steps by Opportunity
            for (CPQ_Quote_Approval_Step__c step : [
                SELECT Id,
                    Approvers_Approved__c,
                    Approvers_Rejected__c,
                    CPQ_Playbook_Approver_Group__r.Approvers_Required__c,
                    CPQ_Quote_Approval__r.Notes_for_Approvers__c,
                    Status__c,
                    Total_Approvers__c,
                    (
                        SELECT Id,
                            Status__c
                        FROM CPQ_Quote_Approvers__r
                    )
                FROM CPQ_Quote_Approval_Step__c
                WHERE Id IN:allStepIDs
            ]) {
                queriedRecords.approvalSteps.put(step.Id, step);
            }
        }

        return queriedRecords.approvalSteps.get(stepId);
    }

    /**
    * @description Get ProcessInstanceWorkItem record for a given CPQ_Quote_Approver__c
    * @param approverId CPQ_Quote_Approver__c Id of CPQ_Quote_Approver__c record work item is needed for
    * @param allApproverIDs All CPQ_Quote_Approver__c IDs for all CPQ_Quote_Approver__c records in trigger context
    * @param queriedRecords Current state of helper object to determine which related records have been queried
    * @return ProcessInstanceWorkItem
    */
    private static ProcessInstanceWorkItem getWorkItem(
        Id approverId,
        Set<Id> allApproverIDs,
        RelatedQueryRecords queriedRecords
    ) {

        // Query ProcessInstanceWorkItem records ONLY if not already queried in this transaction
        if (queriedRecords.workItems == null) {
            // Define Step map
            queriedRecords.workItems = new Map<Id, ProcessInstanceWorkItem>();
            // Query and organize Steps by Opportunity
            for (ProcessInstanceWorkItem workItem : [
                SELECT Id,
                    ProcessInstance.TargetObjectId
                FROM ProcessInstanceWorkItem
                WHERE ProcessInstance.TargetObjectId IN:allApproverIDs
            ]) {
                queriedRecords.workItems.put(workItem.ProcessInstance.TargetObjectId, workItem);
            }
        }

        return queriedRecords.workItems.get(approverId);
    }

    /**
	* @description Helper object to help store related records to query
	*/ 
    public class RelatedQueryRecords {
        public Map<Id, CPQ_Quote_Approval_Step__c> approvalSteps;
        public Map<Id, ProcessInstanceWorkItem> workItems;
    }
}