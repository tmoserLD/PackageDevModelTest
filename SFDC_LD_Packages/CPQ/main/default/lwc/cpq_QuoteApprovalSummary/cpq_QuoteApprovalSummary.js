import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteApprovalSummary extends LightningElement {
    
    // Approvals needed for Quote
    @api quoteApprovals = [];

    // User Info
    @api userInfo;

    // Value of approvals being shown
    @track collapsed = false;

    // Toggle Collapse Value
    toggleCollapse() {
        this.collapsed = !this.collapsed;
    }

}