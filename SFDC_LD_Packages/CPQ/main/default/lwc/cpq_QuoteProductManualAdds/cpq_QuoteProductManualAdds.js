import { LightningElement, api, track } from 'lwc';

export default class CPQ_QuoteProductManualAdds extends LightningElement {

    // Configuration Type
    @api configType;

    // Products added to Quote
    @api quoteProducts = [];

    // Pricebook Info
    @api pricebook;

    // Products available for selection
    @track products = [];

    get cannotSave() {
        return this.products.filter(
            prod => prod.amountSelected > 0
        ).length === 0;
    }

    // On Mount
    connectedCallback() {
        let products = [];
        if (this.pricebook !== undefined &&
            this.pricebook.entries !== undefined    
        ) {
            this.pricebook.entries.forEach(function(pbe) {
                if (pbe.Manually_Addible === true ||
                    this.configType === 'Admin Edit' ||
                    this.configType === 'Admin New'    
                ) {
                    let prodToAdd = JSON.parse(JSON.stringify(pbe));
                    prodToAdd.amountSelected = 0;
                    products.push(prodToAdd);
                }
            }, this);
        }
        this.products = products;
    }

    // Change Product Selection Amount
    changeSelection(event) {
        this.products.forEach(function(prod) {
            if (prod.Id === event.target.name) {
                prod.amountSelected = Number(event.target.value);
                if (prod.amountSelected === undefined ||
                    prod.amountSelected === null ||
                    prod.amountSelected === ''    
                ) {
                    prod.amountSelected = 0;
                }
            }
        }, this);
    }

    // Increase Product Selection Amount
    increaseSelection(event) {
        this.products.forEach(function(prod) {
            if (prod.Id === event.target.name) {
                prod.amountSelected += 1;
            }
        }, this);
    }

    // Decrease Product Selection Amount
    decreaseSelection(event) {
        this.products.forEach(function(prod) {
            if (prod.Id === event.target.name) {
                prod.amountSelected -= 1;
                if (prod.amountSelected < 0) {
                    prod.amountSelected = 0;
                }
            }
        }, this);
    }

    // Save clicked
    saveClick() {

        let detail = [];

        this.products.filter(
            prod => prod.amountSelected > 0
        ).forEach(function(entry) {
            for (let i=0; i < entry.amountSelected; i++) {
                detail.push(entry);
            }
        }, this);

        // Send save event
        const saveEvent = new CustomEvent(
            'save', {
                detail: JSON.stringify(
                    detail
                )
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