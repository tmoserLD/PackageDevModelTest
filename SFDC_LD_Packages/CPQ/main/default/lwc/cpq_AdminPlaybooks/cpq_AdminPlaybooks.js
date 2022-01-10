import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminPlaybooks extends LightningElement {

    // All playbooks in system
    @api playbooks;
    
    // Object containing selections for all levels
    @api selected;
    
    // Create new toggle
    @track createNew = false;

    // Spinner
    @track loading = false;

    get childViewSelected() {
        if (this.selected !== undefined &&
            (
                this.selected.playbookTab === 'questionGroups' ||
                this.selected.playbookTab === 'rules' ||
                this.selected.playbookTab === 'approvals' ||
                this.selected.playbookTab === 'proposalSections'
            )
        ) {
            return true;
        } else {
            return false;
        }
    }

    get selectedAttribute() {
        if (this.createNew === true) {
            return 'nothing';
        } else {
            return 'Id';
        }
    }

    get selectedPlaybook() {
        let playbookId;
        if (this.selected !== undefined) {
            playbookId = this.selected.playbook;
        }
        return playbookId;
    }

    // Record Selected event received
    recordSelected(event) {
        this.createNew = false;

        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: {
                        playbook: event.detail.item.playbookInfo.Id,
                        playbookName: event.detail.item.playbookInfo.Name,
                        playbookSearch: event.detail.searchTerm
                    }
                }
            });
        this.dispatchEvent(selectEvent);
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
        this.createNew = false;

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