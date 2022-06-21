import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminProduct extends LightningElement {

    // Spinner
    @track loading = false;

    // Product
    @api product;

    // Object containing selections for all levels
    @api selected;

    // If group is currently selected
    get isSelected() {
        if (this.selected !== undefined &&
            this.selected.product !== undefined
        ) {
            return this.selected.product.includes(this.product.Id);
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
        if (this.selected.productName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        product: this.selected.product,
                        productName: this.selected.productName,
                        productTab: this.selected.productTab
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