import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteListItemActions extends LightningElement {

    // All Quotes on opp
    @api allQuotes = [];

    // Opportunity Info
    @api oppInfo;

    // Quote record
    @api quote;

    // User Info
    @api userInfo;

    // Quote Approvals Modal toggle
    @track showApprovalsModal = false;

    // Delete Quote Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Edit Quote Confirmation Modal toggle
    @track showConfirmEdit = false;

    // Clone Quote Confirmation Modal toggle
    @track showConfirmClone = false;

    // Quote PDF Proposal Modal toggle
    @track showProposalModal = false;

    // Prompt to show in Delete Quote Confirmation Modal
    @track confirmDeletePrompt = '';

    // Prompt to show in Edit Quote Confirmation Modal
    @track confirmEditPrompt = '';

    // Prompt to show in Clone Quote Confirmation Modal
    @track confirmClonePrompt = '';

    // CSS class names string for component
    get colCSS() {
        let colCSS = 'slds-list_horizontal slds-wrap';
        if (this.allQuotes.indexOf(
            this.allQuotes.find(
                quote => quote.Id === this.quote.Id
                )
            ) % 2 === 1
        ) {
            colCSS += ' slds-theme_shade';
        }
        return colCSS;
    }

    // Determine if System Settings include Clone
    get allowClone() {

        if (this.oppInfo.SystemSettings !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c.split(';').includes('Clone')    
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Determine if System Settings include Delete
    get allowDelete() {
        if (this.oppInfo.SystemSettings !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c.split(';').includes('Delete')    
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Determine if System Settings include Edit
    get allowEdit() {
        if (this.oppInfo.SystemSettings !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c.split(';').includes('Edit')    
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Determine if System Settings include Proposal
    get allowProposal() {
        if (this.oppInfo.SystemSettings !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c.split(';').includes('Proposal')    
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Determine if System Settings include Sync
    get allowSync() {
        if (this.oppInfo.SystemSettings !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c.split(';').includes('Sync')    
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Determine if System Settings include View
    get allowView() {
        if (this.oppInfo.SystemSettings !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c.split(';').includes('View')    
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Determine if Quote can be cloned
    get canClone() {
        if (this.oppInfo.Lock_CPQ__c) {
            return false;
        } else {
            return true;
        }
    }

    // Clone button title
    get cloneTitle() {
        let title = 'Clone Quote';
        if (this.oppInfo.Lock_CPQ__c) {
            title = 'Cannot Clone. Opportunity is locked';
        }
        return title;
    }

    // Determine if Quote can be deleted
    get canDelete() {
        if (this.quote.IsSyncing ||
            this.oppInfo.Lock_CPQ__c    
        ) {
            return false;
        } else {
            return true;
        }
    }

    // Delete button title
    get deleteTitle() {
        let title = 'Delete Quote';
        if (this.oppInfo.Lock_CPQ__c) {
            title = 'Cannot Delete. Opportunity is locked';
        }
        else if (this.quote.IsSyncing) {
            title = 'Cannot Delete. Quote is synced';
        }
        return title;
    }

    // Determine if Quote can be edited
    get canEdit() {
        if (this.quote.IsSyncing ||
            this.oppInfo.Lock_CPQ__c ||
            (
                this.quote.CPQ_Quote_Approvals__r !== undefined &&
                this.quote.CPQ_Quote_Approvals__r.filter(
                    approval => (approval.Status__c === 'Submitted')
                ).length > 0
            ) 
        ) {
            return false;
        } else {
            return true;
        }
    }

    // Edit button title
    get editTitle() {
        let title = 'Edit Quote';
        if (this.oppInfo.Lock_CPQ__c) {
            title = 'Cannot Edit. Opportunity is locked';
        }
        else if (this.quote.IsSyncing) {
            title = 'Cannot Edit. Quote is synced';
        }
        else if (
            this.quote.CPQ_Quote_Approvals__r !== undefined &&
            this.quote.CPQ_Quote_Approvals__r.filter(
                approval => (approval.Status__c === 'Submitted')
            ).length > 0
        ) {
            title = 'Cannot Edit. Submitted Approvals on Quote. Recall Approvals befored editing.';
        }
        return title;
    }

    // Determine if Quote can have proposal generated
    get canGenProposal() {
        if (
            !this.oppInfo.Lock_CPQ__c &&
            this.quote.Playbook_Status__c === 'Complete'
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Proposal button title
    get proposalTitle() {
        let title = 'Generate Proposal';
        if (this.oppInfo.Lock_CPQ__c) {
            title = 'Cannot Generate Proposal. Opportunity is locked';
        }
        else if (this.quote.Playbook_Status__c !== 'Complete') {
            title = 'Cannot Generate Proposal. Playbook is incomplete';
        }
        return title;
    }

    // Determine if Quote can be synced
    get canSync() {
        if (this.quote.Playbook_Status__c !== 'Complete' ||
            this.oppInfo.Lock_CPQ__c
        ) {
            return false;
        } else {

            if (this.quote.CPQ_Quote_Approvals__r !== undefined &&
                this.quote.CPQ_Quote_Approvals__r.filter(approval => approval.Status__c === 'Approved').length !==  this.quote.CPQ_Quote_Approvals__r.length
            ) {
                return false;
            }
            else {
                return true;
            }
        }
    }

    // Sync button title
    get syncTitle() {
        let title = 'Sync Quote';
        if (this.oppInfo.Lock_CPQ__c) {
            title = 'Cannot Sync. Opportunity is locked';
        }
        else if (this.quote.Playbook_Status__c !== 'Complete') {
            title = 'Cannot Sync. Playbook is incomplete';
        }
        else if (this.quote.CPQ_Quote_Approvals__r !== undefined &&
            this.quote.CPQ_Quote_Approvals__r.filter(approval => approval.Status__c === 'Approved').length !==  this.quote.CPQ_Quote_Approvals__r.length
        ) {
            title = 'Cannot Sync. Outstanding approvals';
        }
        return title;
    }

    // Determine if Quote can be unsynced
    get canUnsync() {
        if (this.oppInfo.Lock_CPQ__c) {
            return false;
        } else {
            return true;
        }
    }

    // Unsync button title
    get unsyncTitle() {
        let title = 'Unsync Quote';
        if (this.oppInfo.Lock_CPQ__c) {
            title = 'Cannot Unsync. Opportunity is locked';
        }
        return title;
    }

    // Determine if Quote has completed all approvals
    get hasCompletedApprovals() {
        if (this.quote.CPQ_Quote_Approvals__r) {
            return this.quote.CPQ_Quote_Approvals__r.filter(
                approval => approval.Status__c === 'Approved'
            ).length === this.quote.CPQ_Quote_Approvals__r.length;
        } else {
            return false;
        }
    }

    // Determine if Quote has incomplete approvals
    get hasIncompleteApprovals() {
        if (this.quote.CPQ_Quote_Approvals__r) {
            return this.quote.CPQ_Quote_Approvals__r.filter(
                approval => approval.Status__c !== 'Approved'
            ).length > 0;
        } else {
            return false;
        }
    }

    // Cancel clone quote
    cancelCloneQuote() {
        this.showConfirmClone = false;
        this.confirmClonePrompt = '';
    }

    // Confirm clone quote
    confirmCloneQuote() {

        this.showConfirmClone = false;
        this.confirmClonePrompt = '';

        // Send clone call to parent
        const cloneQuoteEvent = new CustomEvent(
            'clonequote', {
                detail: this.quote.Id
            });
        this.dispatchEvent(cloneQuoteEvent); 
    }

    // Clone quote clicked
    async cloneQuote() {

        // Submitted approvals
        if (this.quote.CPQ_Quote_Approvals__r !== undefined &&
            this.quote.CPQ_Quote_Approvals__r.filter(
                approval => approval.Status__c === 'Submitted'
            ).length > 0
        ) {
            this.confirmClonePrompt = 'Are you sure you want to clone \'' + this.quote.Name + '\'? There are actively sumbitted approvals on this quote. Cloning will duplicate those approvals, causing the current approvers to be notified an additional and separate time.';
            this.showConfirmClone = true;
        } else {
            // Send clone call to parent
            const cloneQuoteEvent = new CustomEvent(
                'clonequote', {
                    detail: this.quote.Id
                });
            this.dispatchEvent(cloneQuoteEvent);
        }
    }

    // Cancel delete quote
    cancelDeleteQuote() {
        this.showConfirmDelete = false;
        this.confirmDeletePrompt = '';
    }

    // Cancel edit quote
    cancelEditQuote() {
        this.showConfirmEdit = false;
        this.confirmEditPrompt = '';
    }

    // Close quote approvals
    closeApprovals() {
        this.showApprovalsModal = false;
    }

    // Close quote proposal
    closeProposal() {
        this.showProposalModal = false;
    }

    // Confirmation received to delete quote
    confirmDeleteQuote() {

        this.showConfirmDelete = false;
        this.confirmDeletePrompt = '';

        // Send delete call to parent
        const deleteQuoteEvent = new CustomEvent(
            'deletequote', {
                detail: this.quote.Id
            });
        this.dispatchEvent(deleteQuoteEvent);
    }

    // Confirmation received to edit quote
    confirmEditQuote() {

        this.showConfirmEdit = false;
        this.confirmEditPrompt = '';

        // Send edit call to parent
        const editQuoteEvent = new CustomEvent(
            'editquote', {
                detail: this.quote.Id
            });
        this.dispatchEvent(editQuoteEvent);
    }

    // Delete Quote clicked
    deleteQuote() {
        this.showConfirmDelete = true;
        this.confirmDeletePrompt = 'Are you sure you want to delete \'' + this.quote.Name + '\'?';
    }

    // Edit Quote clicked
    editQuote() {

        // Non-Persistent, Approved Approvals on quote
        if (this.quote.CPQ_Quote_Approvals__r !== undefined &&
            this.quote.CPQ_Quote_Approvals__r.filter(
                approval => (approval.Status__c === 'Approved' && approval.CPQ_Playbook_Approval__r.Persistent_Approval__c !== true)
            ).length > 0
        ) {
            this.showConfirmEdit = true;
            this.confirmEditPrompt = 'Are you sure you want to edit \'' + this.quote.Name + '\'? There are one or more approved approvals on this quote that will be lost upon saving a new version of this quote.';
        }
        else {

            // Send edit call to parent
            const editQuoteEvent = new CustomEvent(
                'editquote', {
                    detail: this.quote.Id
                });
            this.dispatchEvent(editQuoteEvent);

        }
    }

    recallApproval() {
        this.showApprovalsModal = false;

        // Reload
        const recallEvent = new CustomEvent(
            'recallapproval', {
                detail: this.quote.Id
            }
        );
        this.dispatchEvent(recallEvent);
    }

    // Saved Proposal PDF
    savedProposal() {
        this.showProposalModal = false;

        // Reload
        const savedEvent = new CustomEvent(
            'savedproposal', {
                detail: this.quote.Id
            });
        this.dispatchEvent(savedEvent);
    }

    // Approvals clicked
    showApprovals() {
        this.showApprovalsModal = true;
    }

    // Proposal clicked
    showProposal() {
        this.showProposalModal = true;
    }

    // Submitted quote approvals
    submittedApprovals() {
        this.showApprovalsModal = false;

        // Reload
        const submittedEvent = new CustomEvent(
            'submittedapprovals', {
                detail: this.quote.Id
            }
        );
        this.dispatchEvent(submittedEvent);
    }

    // Sync Quote clicked
    syncQuote() {

        // Send sync call to parent
        const syncQuoteEvent = new CustomEvent(
            'syncquote', {
                detail: this.quote.Id
            });
        this.dispatchEvent(syncQuoteEvent);
    }

    // Unsync Quote clicked
    unsyncQuote() {

        // Send sync call to parent
        const unsyncQuoteEvent = new CustomEvent(
            'unsyncquote', {
                detail: this.quote.Id
            });
        this.dispatchEvent(unsyncQuoteEvent);
    }

    // View clicked
    viewQuote() {
        // Send view call to parent
        const viewQuoteEvent = new CustomEvent(
            'viewquote', {
                detail: this.quote.Id
            });
        this.dispatchEvent(viewQuoteEvent);
    }

    // Notes update
    updateApproverNotes(event) {
        // Send approvernoteupdate event to parent
        const approvernoteupdateEvent = new CustomEvent(
            'approvernoteupdate', {
                detail: event.detail
            });
        this.dispatchEvent(approvernoteupdateEvent);
    }
    
}