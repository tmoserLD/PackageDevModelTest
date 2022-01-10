import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminPricebookEntry extends LightningElement {

    // Spinner
    @track loading = false;

    // Entry
    @api entry;

    // Object containing selections for all levels
    @api selected;

    // If entry is currently selected
    get isSelected() {
        if (this.selected.pricebookEntry !== undefined
        ) {
            return this.selected.pricebookEntry.includes(this.entry.Id);
        } else {
            return false;
        }
    }

    selectEntry(event) {
        this.updateSelections({
            detail: {
                selected: {
                    pricebook: this.selected.pricebook,
                    pricebookName: this.selected.pricebookName,
                    pricebookTab: 'entries',
                    pricebookEntry: this.selected.pricebookEntry === this.entry.Id ? undefined : this.entry.Id,
                    pricebookEntryName: this.selected.pricebookEntryName === this.entry.Product2.Name ? undefined : this.entry.Product2.Name,
                    pricebookEntryTab: 'entry'
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
        if (this.selected.pricebookEntryName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        pricebook: this.selected.pricebook,
                        pricebookName: this.selected.pricebookName,
                        pricebookTab: 'entries',
                        pricebookEntry: this.entry.Id,
                        pricebookEntryName: this.entry.Product2.Name,
                        pricebookEntryTab: this.selected.pricebookEntryTab
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