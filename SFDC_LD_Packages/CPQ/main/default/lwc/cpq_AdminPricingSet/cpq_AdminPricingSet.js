import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminPricingSet extends LightningElement {

    // Spinner
    @track loading = false;

    // Pricing Set
    @api pricingSet;

    // Object containing selections for all levels
    @api selected;

    // If set is currently selected
    get isSelected() {
        if (this.selected.pricingSet !== undefined
        ) {
            return this.selected.pricingSet.includes(this.pricingSet.Id);
        } else {
            return false;
        }
    }

    selectSet(event) {
        this.updateSelections({
            detail: {
                selected: {
                    pricebook: this.selected.pricebook,
                    pricebookName: this.selected.pricebookName,
                    pricebookTab: 'pricingSets',
                    pricingSet: this.selected.pricingSet === this.pricingSet.Id ? undefined : this.pricingSet.Id,
                    pricingSetName: this.selected.pricingSetName === this.pricingSet.Name ? undefined : this.pricingSet.Name,
                    pricingSetTab: 'pricingSet'
                }
            }
        });
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
        if (this.selected.pricingSetName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        pricebook: this.selected.pricebook,
                        pricebookName: this.selected.pricebookName,
                        pricebookTab: 'pricingSets',
                        pricingSet: this.pricingSet.Id,
                        pricingSetName: this.pricingSet.Name,
                        pricingSetTab: this.selected.pricingSetTab
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