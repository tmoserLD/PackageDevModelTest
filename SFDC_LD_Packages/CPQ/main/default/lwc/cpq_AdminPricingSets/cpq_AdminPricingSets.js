import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminPricingSets extends LightningElement {

    // All pricing sets for pricebook
    @api pricingSets;

    // Object containing selections for all levels
    @api selected;

    // Create new question toggle
    @track createNew = false;

    // Spinner
    @track loading = false;

    // Search Term
    @track searchTerm;

    get collapsed() {
        return this.selected.pricebookTab !== 'pricingSets';
    }

    get filteredSets() {
        if (this.searchTerm !== '' &&
            this.searchTerm !== undefined &&
            this.searchTerm !== null
        ) {
            return this.pricingSets.filter(set => set.Name.toLowerCase().includes(this.searchTerm.toLowerCase()));
        } else {
            return this.pricingSets;
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
                    pricebookTab: this.selected.pricebookTab === 'pricingSets' ? 'pricebook' : 'pricingSets'
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