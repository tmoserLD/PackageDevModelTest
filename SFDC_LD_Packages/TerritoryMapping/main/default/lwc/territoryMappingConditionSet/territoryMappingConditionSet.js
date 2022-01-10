import { LightningElement, api, track } from 'lwc';

export default class TerritoryMappingConditionSet extends LightningElement {

    // Spinner
    @track loading = false;

    // Set
    @api set;

    // Object containing selections for all levels
    @api selected;

    // If set is currently selected
    get isSelected() {
        if (this.selected.conditionSet !== undefined) {
            return this.selected.conditionSet.includes(this.set.Id);
        } else {
            return false;
        }
    }

    selectSet(event) {
        this.updateSelections({
            detail: {
                selected: {
                    mapping: this.selected.mapping,
                    mappingTab: 'conditionSets',
                    conditionSet: this.selected.conditionSet === this.set.Id ? undefined : this.set.Id,
                    conditionSetTab: 'set'
                }
            }
        });
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