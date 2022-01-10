import { LightningElement, api, track } from 'lwc';

export default class TerritoryMappingConditionSets extends LightningElement {

    // All sets for mapping
    @api sets;

    // Object containing selections for all levels
    @api selected;

    // Create new toggle
    @track createNew = false;

    // Spinner
    @track loading = false;

    // Search Term
    @track searchTerm;

    get collapsed() {
        return this.selected.mappingTab !== 'conditionSets';
    }

    get filteredSets() {
        if (this.searchTerm !== '' &&
            this.searchTerm !== undefined &&
            this.searchTerm !== null
        ) {
            return this.sets.filter(set => set.Name.toLowerCase().includes(this.searchTerm.toLowerCase()));
        } else {
            return this.sets;
        }
    }

    searchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    toggleCollapse() {
        this.updateSelections({
            detail: {
                selected: {
                    mapping: this.selected.mapping,
                    mappingTab: this.selected.mappingTab === 'conditionSets' ? 'mapping' : 'conditionSets'
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