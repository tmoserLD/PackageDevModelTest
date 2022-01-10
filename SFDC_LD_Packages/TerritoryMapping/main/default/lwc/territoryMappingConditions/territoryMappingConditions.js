import { LightningElement, api, track } from 'lwc';

export default class TerritoryMappingConditions extends LightningElement {

    // All conditions for mapping
    @api conditions;

    // Object containing selections for all levels
    @api selected;

    // Create new toggle
    @track createNew = false;

    // Spinner
    @track loading = false;

    // Search Term
    @track searchTerm;

    get collapsed() {
        return this.selected.conditionSetTab !== 'conditions';
    }

    get filteredSets() {
        if (this.searchTerm !== '' &&
            this.searchTerm !== undefined &&
            this.searchTerm !== null
        ) {
            return this.conditions.filter(condition => condition.Name.toLowerCase().includes(this.searchTerm.toLowerCase()));
        } else {
            return this.conditions;
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
                    mappingTab: 'conditionSets',
                    conditionSet: this.selected.conditionSet,
                    conditionSetTab: this.selected.conditionSetTab === 'conditions' ? 'set' : 'conditions'
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