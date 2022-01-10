import { LightningElement, api } from 'lwc';

export default class CPQ_QuoteApprovalModalItem extends LightningElement {

    // All Quote Approvals
    @api quoteApprovals;

    // Approval
    @api approval;

    // User Info
    @api userInfo;

    // CSS class names string for component
    get mainCSS() {
        let mainCSS = 'slds-grid slds-p-vertical_x-small';
        if (this.quoteApprovals.indexOf(this.approval) % 2 === 1) {
            mainCSS += ' slds-theme_shade';
        }
        return mainCSS;
    }

    // Approvers by Step for display
    get approversByStep() {
        let approversByStep = [];
        this.approval.CPQ_Quote_Approval_Steps__r.forEach(function(step) {
            let approverStep = {
                key: approversByStep.length,
                approved: (step.Status__c === 'Approved'),
                rejected: (step.Status__c === 'Rejected')
            };
            let approvers = [];
            step.CPQ_Quote_Approvers__r.forEach(function(approver) {
                // Manager
                if (approver.CPQ_Playbook_Approver__r.Manager_Approver__c === true) {
                    if (this.userInfo.Manager) {
                        approvers.push(this.userInfo.Manager.Name + ' (Manager)');
                    }
                }
                // Non-Manager
                else {
                    approvers.push(approver.CPQ_Playbook_Approver__r.Approver__r.Name);
                }
            }, this);
            approverStep.text = approvers.join(', ');
            approversByStep.push(approverStep);
        }, this);

        return approversByStep;
    }

    // Submitted
    get approvalSubmitted() {
        return this.approval.Status__c === 'Submitted';
    }

    // Recall
    recallApproval() {
        // Send recall event to parent
        const recallEvent = new CustomEvent(
            'recall', {
                detail: this.approval.Id
            });
        this.dispatchEvent(recallEvent);
    }
}