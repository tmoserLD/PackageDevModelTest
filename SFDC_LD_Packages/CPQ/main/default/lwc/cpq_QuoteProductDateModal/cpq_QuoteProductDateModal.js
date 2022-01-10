import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProductDateModal extends LightningElement {

    // Product
    @api product;

    // End Date
    @track endDate;

    // Start Date
    @track startDate;

    // On Mount
    connectedCallback() {
        if (this.product !== undefined) {
            this.endDate = this.product.End_Date;
            this.startDate = this.product.Start_Date;
        }
    }

    // End Date Change
    endDateChange(event) {
        this.endDate = event.target.value;
    }

    // Start Date Change
    startDateChange(event) {
        this.startDate = event.target.value;
    }    

    // Cancel clicked
    cancelClick() {
        // Send cancel event to parent
        const cancelEvent = new CustomEvent(
            'cancel', {
                detail: {}
            });
        this.dispatchEvent(cancelEvent);
    }

    // Save clicked
    saveClick() {
        // Send save event to parent
        const saveEvent = new CustomEvent(
            'save', {
                detail: {
                    endDate: this.endDate,
                    startDate: this.startDate
                }
            });
        this.dispatchEvent(saveEvent);
    }

}