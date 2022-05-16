import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProduct extends LightningElement {

    // Configuration Type
    @api configType;

    // Product
    // @api product;

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Products sorted by sort rules
    @api sortedQuoteProducts;

    // Columns to display
    @api columnsToDisplay;

    @api
    get product() {
        return this.productCopy;
    }
    set product(value) {
        this.productCopy = value;
        if (value !== undefined) {
            for (let index=0; index < this.template.querySelectorAll('c-cpq_-quote-product-column').length; index++) {
                this.template.querySelectorAll('c-cpq_-quote-product-column')[index].updateValue(this.columnsToDisplay[index].field, value[this.columnsToDisplay[index].field]);
            }
        }
    }

    @track productCopy;

    // CSS class names string for component
    get colCSS() {
        let colCSS = 'slds-col slds-p-left_xx-small';
        if (this.sortedQuoteProducts.indexOf(
            this.sortedQuoteProducts.find(
                product => product.key === this.product.key
                )
            ) % 2 === 1
        ) {
            colCSS += ' slds-theme_shade';
        }
        if (this.columnsToDisplay.length > 5) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-6';
        }
        else if (this.columnsToDisplay.length === 5) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-5';
        }
        else if (this.columnsToDisplay.length === 4) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-4 slds-large-size_1-of-4';
        }
        else if (this.columnsToDisplay.length === 3) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-3 slds-large-size_1-of-3';
        }
        return colCSS;
    }

    // Update product in quote
    updateColumn(event) {

        const updateEvent = new CustomEvent(
            'update', {
                detail: event.detail
            });
        this.dispatchEvent(updateEvent);
    }
}