import { LightningElement, api, track } from 'lwc';

export default class TerritoryMapping extends LightningElement {

    // Spinner
    @track loading = false;

    // Mapping
    @api mapping;

    // Object containing selections for all levels
    @api selected;

    // If mapping is currently selected
    get isSelected() {
        if (this.selected.mapping !== undefined) {
            return this.selected.mapping.includes(this.mapping.mapping.Id);
        } else {
            return false;
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