import { LightningElement, api, track } from 'lwc';

export default class TerritoryMappingCondition extends LightningElement {

    // Spinner
    @track loading = false;

    // Condition
    @api condition;

    // Object containing selections for all levels
    @api selected;

    // If set is currently selected
    get isSelected() {
        if (this.selected.condition !== undefined) {
            return this.selected.condition.includes(this.condition.Id);
        } else {
            return false;
        }
    }

    selectCondition(event) {
        this.updateSelections({
            detail: {
                selected: {
                    mapping: this.selected.mapping,
                    mappingTab: 'conditionSets',
                    conditionSet: this.selected.conditionSet,
                    conditionSetTab: 'conditions',
                    condition: this.selected.condition === this.condition.Id ? undefined : this.condition.Id,
                    conditionTab: 'condition'
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