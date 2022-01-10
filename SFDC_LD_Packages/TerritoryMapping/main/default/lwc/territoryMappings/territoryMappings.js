import { LightningElement, api, track } from 'lwc';

export default class TerritoryMappings extends LightningElement {

    // All mappings in for object
    @api mappings;

    // Object containing selections for all levels
    @api selected;

    // Object currently selected
    @api object;
    
    // Create new toggle
    @track createNew = false;

    // Spinner
    @track loading = false;

    get selectedAttribute() {
        if (this.createNew === true) {
            return 'nothing';
        } else {
            return 'Id';
        }
    }

    // Record Selected event received
    recordSelected(event) {
        this.createNew = false;

        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: {
                        mapping: event.detail.item.mapping.Id
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