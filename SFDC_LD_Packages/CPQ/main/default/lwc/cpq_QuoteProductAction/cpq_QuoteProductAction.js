import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProductAction extends LightningElement {

    // Product
    @api product;

    // Products sorted by sort rules
    @api sortedQuoteProducts;

    // Dates Modal toggle
    // @track showChangeDates = false;

    // CSS class names string for component
    get mainCSS() {
        let mainCSS = '';
        if (this.sortedQuoteProducts.indexOf(
            this.sortedQuoteProducts.find(
                product => product.key === this.product.key
                )
            ) % 2 === 1
        ) {
            mainCSS += ' slds-theme_shade';
        }
        return mainCSS;
    }

    // Determine if product can be removed
    get removable() {
        return this.product.Removable;
    }

    // // Adjust Dates clicked
    // adjustDates() {
    //     this.showChangeDates = true;
    // }

    // // Change Dates cancel event
    // cancelChangeDates() {
    //     this.showChangeDates = false;
    // }

    // Remove Product clicked
    removeProduct() {
        const removeEvent = new CustomEvent(
            'remove', {
                detail: this.product 
            });
        this.dispatchEvent(removeEvent);
    }

    // // Change Dates save event
    // saveChangedDates(event) {
    //     this.updateProduct('End_Date', event.detail.endDate);
    //     this.updateProduct('Start_Date', event.detail.startDate);

    //     this.showChangeDates = false;
    // }

    // Update product in quote
    updateProduct(attribute, value) {

        const updateEvent = new CustomEvent(
            'update', {
                detail: {
                    key: this.product.key,
                    attribute: attribute,
                    newValue: value
                }
            });
        this.dispatchEvent(updateEvent);
    }

}