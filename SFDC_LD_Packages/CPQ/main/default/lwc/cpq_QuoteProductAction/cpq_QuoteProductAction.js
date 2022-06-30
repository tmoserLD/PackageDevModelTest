import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProductAction extends LightningElement {

    // Configuration Type
    @api configType;

    // Product
    @api product;

    // Products sorted by sort rules
    @api sortedQuoteProducts;

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
        return (
            this.product.Removable ||
            this.configType === 'Admin Edit' ||
            this.configType === 'Admin New'
        );
    }

    // Remove Product clicked
    removeProduct() {
        const removeEvent = new CustomEvent(
            'remove', {
                detail: this.product 
            });
        this.dispatchEvent(removeEvent);
    }

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