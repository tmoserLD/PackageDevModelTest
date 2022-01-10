import { LightningElement, api } from 'lwc';

export default class CPQ_QuoteApproval extends LightningElement {

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

    // Approvers by Group for display
    get approversByGroup() {
        let approversByGroup = [];
        this.approval.approverGroups.forEach(function(group) {
            let approverGroup = {key: approversByGroup.length};
            let approvers = [];
            group.approvers.forEach(function(approver) {
                // Manager
                if (approver.approverInfo.Manager_Approver__c === true) {
                    if (this.userInfo.Manager) {
                        approvers.push(this.userInfo.Manager.Name + ' (Manager)');
                    }
                }
                // Non-Manager
                else {
                    approvers.push(approver.approverInfo.Approver__r.Name);
                }
            }, this);
            approverGroup.text = approvers.join(', ');
            approversByGroup.push(approverGroup);
        }, this);

        return approversByGroup;
    }
}