import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminPricebook extends LightningElement {

    // Spinner
    @track loading = false;

    // Pricebook
    @api pricebook;

    // Object containing selections for all levels
    @api selected;

    // If group is currently selected
    get isSelected() {
        if (this.selected !== undefined &&
            this.selected.pricebook !== undefined
        ) {
            return this.selected.pricebook.includes(this.pricebook.Id);
        } else {
            return false;
        }
    }

    // Child saved event
    childSaved(event) {

        // Send chilsaved event to parent
        const childsavedEvent = new CustomEvent(
            'childsaved', {
                detail: event.detail
            });
        this.dispatchEvent(childsavedEvent);
    }

    handleTabChange(event) {
        if (this.selected.pricebookName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        pricebook: this.selected.pricebook,
                        pricebookName: this.selected.pricebookName,
                        pricebookTab: this.selected.pricebookTab
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

    playbookSelected(event) {
        // Send playbookselect event to parent
        const selectEvent = new CustomEvent(
            'playbookselect', {
                detail: {
                    selected: {
                        playbook: event.detail.item.Id,
                        playbookName: event.detail.item.Name,
                        playbookTab: 'playbook'
                    }
                }
            });
        this.dispatchEvent(selectEvent);
    }
}