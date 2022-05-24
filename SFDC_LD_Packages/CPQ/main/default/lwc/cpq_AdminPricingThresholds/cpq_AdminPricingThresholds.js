import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminPricingThresholds extends LightningElement {

    // All pricing thresholds for pricebook
    @api pricingThresholds;

    // Object containing selections for all levels
    @api selected;

    // Create new question toggle
    @track createNew = false;

    // Spinner
    @track loading = false;

    // Search Term
    @track searchTerm;

    get collapsed() {
        return this.selected.pricingSetTab !== 'pricingThresholds';
    }

    get filteredThresholds() {
        if (this.searchTerm !== '' &&
            this.searchTerm !== undefined &&
            this.searchTerm !== null
        ) {
            return this.pricingThresholds.filter(threshold => threshold.Name.toLowerCase().includes(this.searchTerm.toLowerCase()));
        } else {
            return this.pricingThresholds;
        }
    }

    searchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    toggleCollapse() {
        this.updateSelections({
            detail: {
                selected: {
                    pricebook: this.selected.pricebook,
                    pricebookName: this.selected.pricebookName,
                    pricebookTab: this.selected.pricebookTab,
                    pricingSet: this.selected.pricingSet,
                    pricingSetName: this.selected.pricingSetName,
                    pricingSetTab: this.selected.pricingSetTab === 'pricingThresholds' ? 'pricingSet' : 'pricingThresholds',
                }
            }
        });
    }

    // Create New event received
    createNewRecord(event) {
        this.createNew = true;
    }

    // Cancel Create New event received
    cancelCreateNewRecord(event) {
        this.createNew = false;
    }

    // Child saved event
    childSaved(event) {

        // Send childsaved event to parent
        const childSavedEvent = new CustomEvent(
            'childsaved', {
                detail: event.detail
            });
        this.dispatchEvent(childSavedEvent);
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