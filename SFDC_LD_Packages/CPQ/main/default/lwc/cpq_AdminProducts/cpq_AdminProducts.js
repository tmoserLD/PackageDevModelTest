import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminProducts extends LightningElement {

    // All products in system
    @api products;
    
    // Object containing selections for all levels
    @api selected;
    
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

    get selectedProduct() {
        let productId;
        if (this.selected !== undefined) {
            productId = this.selected.product;
        }
        return productId;
    }

    // Record Selected event received
    recordSelected(event) {
        this.createNew = false;

        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: {
                        product: event.detail.item.Id,
                        productName: event.detail.item.Name,
                        productSearch: event.detail.searchTerm
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

    // Playbook Select Event
    playbookSelect(event) {

        // Send playbookselect event to parent
        const selectEvent = new CustomEvent(
            'playbookselect', {
                detail: {
                    selected: event.detail.selected
                }
            });
        this.dispatchEvent(selectEvent);
    }

}