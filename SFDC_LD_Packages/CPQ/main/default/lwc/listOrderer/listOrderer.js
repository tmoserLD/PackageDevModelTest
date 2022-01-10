import { LightningElement, api, track } from 'lwc';

export default class ListOrderer extends LightningElement {

    @api title;
    @api initialOptions;

    @track orderedOptions = [];

    connectedCallback() {
        if (this.initialOptions !== undefined) {
            this.orderedOptions = this.initialOptions;
        }
    }

    closeModal() {
        const closeEvent = new CustomEvent(
            'close', {
                detail: undefined
            });
        this.dispatchEvent(closeEvent);
    }

    updateOrder(event) {
        this.orderedOptions = event.detail;
        const updateEvent = new CustomEvent(
            'update', {
                detail: event.detail
            });
        this.dispatchEvent(updateEvent);
    }
}