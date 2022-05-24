import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminPricingThreshold extends LightningElement {

    // Spinner
    @track loading = false;

    // Pricing Threshold
    @api pricingThreshold;

    // Object containing selections for all levels
    @api selected;

    // If threshold is currently selected
    get isSelected() {
        if (this.selected.pricingThreshold !== undefined
        ) {
            return this.selected.pricingThreshold.includes(this.pricingThreshold.Id);
        } else {
            return false;
        }
    }

    selectThreshold(event) {
        this.updateSelections({
            detail: {
                selected: {
                    pricebook: this.selected.pricebook,
                    pricebookName: this.selected.pricebookName,
                    pricebookTab: 'pricingSets',
                    pricingSet: this.selected.pricingSet,
                    pricingSetName: this.selected.pricingSetName,
                    pricingSetTab: 'pricingThresholds',
                    pricingThreshold: this.selected.pricingThreshold === this.pricingThreshold.Id ? undefined : this.pricingThreshold.Id,
                    pricingThresholdName: this.selected.pricingThresholdName === this.pricingThreshold.Name ? undefined : this.pricingThreshold.Name,
                    pricingThresholdTab: 'pricingThreshold'
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
        if (this.selected.pricingThresholdName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        pricebook: this.selected.pricebook,
                        pricebookName: this.selected.pricebookName,
                        pricebookTab: 'pricingSets',
                        pricingSet: this.selected.pricingSet,
                        pricingSetName: this.selected.pricingSetName,
                        pricingSetTab: 'pricingThresholds',
                        pricingThreshold: this.pricingThreshold.Id,
                        pricingThresholdName: this.pricingThreshold.Name,
                        pricingThresholdTab: this.selected.pricingThresholdTab
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