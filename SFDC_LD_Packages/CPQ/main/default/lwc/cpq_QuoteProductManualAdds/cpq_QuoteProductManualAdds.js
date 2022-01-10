import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProductManualAdds extends LightningElement {

    // Products added to Quote
    @api quoteProducts = [];

    // Pricebook Info
    @api pricebook;

    // Products available for selection
    @track products = [];

    get cannotSave() {
        return this.products.filter(
            prod => prod.selected === true
        ).length === 0;
    }

    // On Mount
    connectedCallback() {
        let products = [];
        if (this.pricebook !== undefined &&
            this.pricebook.PricebookEntries !== undefined    
        ) {
            this.pricebook.PricebookEntries.forEach(function(pbe) {
                if (pbe.Manually_Addible === true) {
                    if (this.quoteProducts.filter(
                        product => product.addedByAction === undefined && product.Product2Id === pbe.Product2Id
                        ).length === 0
                    ) {
                        let prodToAdd = JSON.parse(JSON.stringify(pbe));
                        prodToAdd.selected = false;
                        products.push(prodToAdd);
                    }
                }
            }, this);
        }
        this.products = products;
    }

    // Toggle Product selection
    toggleSelection(event) {
        this.products.forEach(function(prod) {
            if (prod.Id === event.target.name) {
                prod.selected = !prod.selected;
            }
        }, this);
    }

    // Save clicked
    saveClick() {

        // Send save event
        const saveEvent = new CustomEvent(
            'save', {
                detail: JSON.stringify(this.products.filter(
                    prod => prod.selected === true
                ))
            }
        );
        this.dispatchEvent(saveEvent);
    }

    // Cancel clicked
    cancelClick() {

        // Send cancel event
        const cancelEvent = new CustomEvent(
            'cancel'
        );
        this.dispatchEvent(cancelEvent);
    }
}