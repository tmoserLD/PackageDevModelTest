import { LightningElement, api } from 'lwc';

export default class CPQ_QuoteApprovalModalItem extends LightningElement {

    // Opportunity Info
    @api oppInfo;

    // All Quote Approvals
    @api quoteApprovals;

    // Approval
    @api approval;

    // User Info
    @api userInfo;

    get justificationUnavailable() {
        if (this.approval.Status__c === 'Approved' ||
            this.approval.Status__c === 'Submitted'    
        ) {
            return true;
        } else {
            return false;
        }
    }

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
            let stepObj = {
                Id: step.Id,
                approvers: []
            };
            step.CPQ_Quote_Approvers__r.forEach(function(approver) {
                let approverObj = {Id: approver.Id};
                // Manager
                if (approver.CPQ_Playbook_Approver__r.Manager_Approver__c === true) {
                    if (this.oppInfo.Owner) {
                        if (this.oppInfo.Owner.Manager) {
                            approverObj.text = this.oppInfo.Owner.Manager.Name + ' (Manager)';
                        }
                    }
                }
                // Non-Manager
                else {
                    approverObj.text = approver.CPQ_Playbook_Approver__r.Approver__r.Name;
                }
                approverObj.approved = approver.Status__c === 'Approved';
                approverObj.rejected = approver.Status__c === 'Rejected';
                approverObj.other = approver.Status__c !== 'Approved' && approver.Status__c !== 'Rejected';
                approverObj.hasReason = (approver.Decision_Reason__c !== undefined && approver.Decision_Reason__c !== null && approver.Decision_Reason__c !== '');
                approverObj.reason = approver.Decision_Reason__c;

                stepObj.approvers.push(approverObj);
            }, this);
            approversByStep.push(stepObj);
        }, this);

        return approversByStep;
    }

    // Notes update
    updateApproverNotes(event) {
        // Send approvernoteupdate event to parent
        const approvernoteupdateEvent = new CustomEvent(
            'approvernoteupdate', {
                detail: {
                    approvalId: this.approval.Id,
                    notes: event.target.value
                }
            });
        this.dispatchEvent(approvernoteupdateEvent);
    }
}