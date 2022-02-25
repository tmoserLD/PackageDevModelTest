import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProduct extends LightningElement {

    // Product
    @api product;

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Products sorted by sort rules
    @api sortedQuoteProducts;

    // Columns to display
    @api columnsToDisplay;

    @api
    get unitPrice() {
        return this.product.Unit_Price;
    }
    set unitPrice(value) {
        if (this.product !== undefined) {
            this.template.querySelectorAll('c-cpq_-quote-product-column').forEach(function(col) {
                col.updateValue('Unit_Price', value);
            }, this);
        }
    }

    @api
    get quantity() {
        return this.product.Quantity;
    }
    set quantity(value) {
        if (this.product !== undefined) {
            this.template.querySelectorAll('c-cpq_-quote-product-column').forEach(function(col) {
                col.updateValue('Quantity', value);
            }, this);
        }
    }

    @api
    get listPrice() {
        return this.product.List_Price;
    }
    set listPrice(value) {
        if (this.product !== undefined) {
            this.template.querySelectorAll('c-cpq_-quote-product-column').forEach(function(col) {
                col.updateValue('List_Price', value);
            }, this);
        }
    }

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