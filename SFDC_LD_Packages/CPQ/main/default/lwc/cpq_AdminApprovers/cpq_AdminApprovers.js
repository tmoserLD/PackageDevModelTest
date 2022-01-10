import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminApprovers extends LightningElement {

    // All approvers for group
    @api approvers;

    // Object containing selections for all levels
    @api selected;

    // Create new toggle
    @track createNew = false;

    // Spinner
    @track loading = false;

    // Search Term
    @track searchTerm;

    get collapsed() {
        return this.selected.approvalApproverGroupTab !== 'approvers';
    }

    get filteredApprovers() {
        if (this.searchTerm !== '' &&
            this.searchTerm !== undefined &&
            this.searchTerm !== null
        ) {
            return this.approvers.filter(approver => approver.approverInfo.Name.toLowerCase().includes(this.searchTerm.toLowerCase()));
        } else {
            return this.approvers;
        }
    }

    searchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    toggleCollapse() {
        this.updateSelections({
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: 'approvals',
                    approval: this.selected.approval,
                    approvalName: this.selected.approvalName,
                    approvalTab: this.selected.approvalTab,
                    approvalApproverGroup: this.selected.approvalApproverGroup,
                    approvalApproverGroupName: this.selected.approvalApproverGroupName,
                    approvalApproverGroupTab: this.selected.approvalApproverGroupTab === 'approvers' ? 'group' : 'approvers'
                }
            }
        });
    }

    // Create New event received
    createNewRecord(event) {
        this.createNew = true;
    }

    // Cancel Create New event received
    cancelCreateNewRecord(event) {
        this.createNew = false;
    }

    // Child saved event
    childSaved(event) {

        // Send childsaved event to parent
        const childSavedEvent = new CustomEvent(
            'childsaved', {
                detail: event.detail
            });
        this.dispatchEvent(childSavedEvent);
    }

    // Select Event
    updateSelections(event) {

        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: event.detail.selected
                }
            });
        this.dispatchEvent(selectEvent);
    }

}