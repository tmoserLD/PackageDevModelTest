import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminApprovalCriteriaGroups extends LightningElement {

    // All criteria groups for approval
    @api groups;

    // Object containing selections for all levels
    @api selected;
    
    // Create new toggle
    @track createNew = false;

    // Spinner
    @track loading = false;

    // Search Term
    @track searchTerm;

    get collapsed() {
        return this.selected.approvalTab !== 'criteriaGroups';
    }

    get filteredGroups() {
        if (this.searchTerm !== undefined &&
            this.searchTerm !== null &&
            this.searchTerm !== ''    
        ) {
            return this.groups.filter(
                group => group.groupInfo.Name.toLowerCase().includes(this.searchTerm.toLowerCase())
            );
        } else {
            return this.groups;
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
                    approvalTab: this.selected.approvalTab === 'criteriaGroups' ? 'approval' : 'criteriaGroups'
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