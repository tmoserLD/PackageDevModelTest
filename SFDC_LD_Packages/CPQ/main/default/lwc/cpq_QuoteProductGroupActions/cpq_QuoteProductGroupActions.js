import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProductGroupActions extends LightningElement {

    // Group
    @api group;

    // Field being grouped
    @api fieldLabel;


    // Determine if groupings exist
    get hasField() {
        return this.fieldLabel !== undefined;
    }

    // Remove Product event
    removeProduct(event) {

        const removeEvent = new CustomEvent(
            'remove', {
                detail: event.detail 
            });
        this.dispatchEvent(removeEvent);

    }

    // Update Product event
    updateProduct(event) {

        const updateEvent = new CustomEvent(
            'update', {
                detail: event.detail
            });
        this.dispatchEvent(updateEvent);
    }
}