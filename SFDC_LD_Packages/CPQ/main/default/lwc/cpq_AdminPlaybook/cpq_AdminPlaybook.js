import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminPlaybook extends LightningElement {

    // Spinner
    @track loading = false;

    // Playbook
    @api playbook;

    // Object containing selections for all levels
    @api selected;

    // If playbook is currently selected
    get isSelected() {
        if (this.selected !== undefined &&
            this.selected.playbook !== undefined
        ) {
            return this.selected.playbook.includes(this.playbook.playbookInfo.Id);
        } else {
            return false;
        }
    }

    get tabValue() {
        if (this.selected !== undefined &&
            this.selected.playbookTab !== undefined    
        ) {
            return this.selected.playbookTab;
        } else {
            return 'playbook';
        }
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

    handleTabChange(event) {
        if (this.selected.playbookName === undefined ||
            this.selected.playbookTab !== event.target.value
        ) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: (this.selected.playbookTab !== event.target.value && this.selected.playbookTab !== undefined),
                        playbook: this.playbook.playbookInfo.Id,
                        playbookName: this.playbook.playbookInfo.Name,
                        playbookTab: event.target.value
                    }
                }
            });
        }
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