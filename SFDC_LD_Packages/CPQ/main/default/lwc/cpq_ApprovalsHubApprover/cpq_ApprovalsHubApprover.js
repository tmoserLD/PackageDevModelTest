import { LightningElement, api, track } from 'lwc';

// Update Method
import updateRecords from '@salesforce/apex/cpq_ApprovalsHubClass.updateRecords';

export default class CPQ_ApprovalsHubApprover extends LightningElement {

    // Approver record
    @api approver;

    // Info for current user
    @api currentUser;

    // Loading spinner
    @track loading = false;

    @track showDecisionModal = false;

    @track decisionType;

    get approved() {
        return this.approver.approverInfo.Status__c === 'Approved';
    }

    get rejected() {
        return this.approver.approverInfo.Status__c === 'Rejected';
    }

    get showButtons() {
        let showButtons = false;
        if (this.approver.approverInfo.Status__c === 'Submitted' &&
            (
                this.approver.approverInfo.Approver__c === this.currentUser.userId ||
                this.approver.approverInfo.Approver__r.DelegatedApproverId === this.currentUser.userId ||
                this.currentUser.approvalAdmin === true
            )
        ) {
            showButtons = true;
        }

        return showButtons;
    }

    get hasReason() {
        return (
            this.approver.approverInfo.Decision_Reason__c !== undefined &&
            this.approver.approverInfo.Decision_Reason__c !== null &&
            this.approver.approverInfo.Decision_Reason__c !== ''
        )
    }

    approve() {
        this.decisionType = 'Approve';
        this.showDecisionModal = true;
    }

    reject() {
        this.decisionType = 'Reject';
        this.showDecisionModal = true;
    }

    cancelDecisionReason() {
        this.decisionType = undefined;
        this.showDecisionModal = false;
    }

    confirmDecisionReason(event) {
        let record = {};

        if (this.decisionType === 'Approve') {
            record = {
                sobjectType: 'CPQ_Quote_Approver__c',
                Id: this.approver.approverInfo.Id,
                Decision_Reason__c: event.detail.reason,
                Status__c: 'Approved'
            };
        } else if (this.decisionType === 'Reject') {
            record = {
                sobjectType: 'CPQ_Quote_Approver__c',
                Id: this.approver.approverInfo.Id,
                Decision_Reason__c: event.detail.reason,
                Status__c: 'Rejected'
            };
        }

        this.showDecisionModal = false;
        this.updateStatus(record);
    }

    async updateStatus(record) {

        this.loading = true;

        try {
            await updateRecords(
                {
                    records: [record]
                }
            );

            // Send reload event to parent
            const reloadEvent = new CustomEvent(
                'reload', {
                    detail: {}
                });
            this.dispatchEvent(reloadEvent);
        } catch (e) {
            console.error(e);
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to update the approver record',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

}