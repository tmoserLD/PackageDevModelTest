import { LightningElement, api, track } from 'lwc';

// Submit for Approval Method
import submitForApproval from '@salesforce/apex/cpq_ContainerClass.submitForApproval';

// Recall Approval Method
import recallApproval from '@salesforce/apex/cpq_ContainerClass.recallApproval';
export default class CPQ_QuoteApprovalsModal extends LightningElement {

    // Opportunity Info
    @api oppInfo;

    // Quote
    @api quote;

    // User Info
    @api userInfo;

    // Loading / Show Spinner
    @track loading = false;

    // Approvals array
    get quoteApprovals() {
        if (this.quote.CPQ_Quote_Approvals__r) {
            return this.quote.CPQ_Quote_Approvals__r;
        } else {
            return []
        }
    }

    // Cannot submit for approval
    get cannotSubmit() {
        let noPendingApprovals = false;
        if (this.quote.CPQ_Quote_Approvals__r) {
            noPendingApprovals = this.quote.CPQ_Quote_Approvals__r.filter(
                approval => approval.Status__c !== 'Submitted' && approval.Status__c !== 'Approved'
            ).length === 0;
        } else {
            noPendingApprovals = true;
        }

        return (
            noPendingApprovals ||
            this.quote.Playbook_Status__c !== 'Complete' ||
            this.oppInfo.Lock_CPQ__c
        );
    }

    // Cannot submit for approval reason
    get cannotSubmitReason() {
        let reason = '';
        if (this.oppInfo.Lock_CPQ__c) {
            reason = 'Opportunity is locked.';
        }
        else if (this.quote.Playbook_Status__c !== 'Complete') {
            reason = 'Quote has not completed its Playbook configuration.';
        } else if (this.quote.CPQ_Quote_Approvals__r) {
            if (this.quote.CPQ_Quote_Approvals__r.filter(
                approval => approval.Status__c !== 'Submitted' && approval.Status__c !== 'Approved'
            ).length === 0) {
                reason = 'No approvals to submit.'
            }
        }
        return reason;
    }

    // Close clicked
    closeClick() {
        // Send close event to parent
        const closeEvent = new CustomEvent(
            'close', {
                detail: {}
            });
        this.dispatchEvent(closeEvent);
    }

    // Submit clicked
    async submitClick() {

        this.loading = true;

        // Send object to database
        try {
            await submitForApproval({
                quoteId: this.quote.Id
            });

            // Send submit event to parent
            const submitEvent = new CustomEvent(
                'submit', {
                    detail: {}
                });
            this.dispatchEvent(submitEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to submit the approval(s)',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Recall clicked
    async recallApproval(event) {

        this.loading = true;

        // Send object to database
        try {
            await recallApproval({
                approvalId: event.detail
            });

            // Send submit event to parent
            const submitEvent = new CustomEvent(
                'recall', {
                    detail: {}
                });
            this.dispatchEvent(submitEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to recall the approval',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }
}