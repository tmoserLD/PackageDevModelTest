import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminPricebookReferences extends LightningElement {

    // Price Book
    @api pricebook;

    // Object containing selections for all levels
    @api selected;

    // If references are currently selected
    get isSelected() {
        return this.selected.pricebookTab !== 'references';
    }

    toggleSelection(event) {
        // Send select event to parent
        const selectEvent = new CustomEvent(
        'select', {
            detail: {
                selected: {
                    pricebook: this.selected.pricebook,
                    pricebookName: this.selected.pricebookName,
                    pricebookTab: this.selected.pricebookTab === 'references' ? 'pricebook' : 'references'
                }
            }
        });
        this.dispatchEvent(selectEvent); 
    }

    playbookSelected(event) {
        // Send playbookselect event to parent
        const selectEvent = new CustomEvent(
            'playbookselect', {
                detail: {
                    selected: {
                        playbook: event.detail.item.Id,
                        playbookName: event.detail.item.Name,
                        playbookTab: 'playbook'
                    }
                }
            });
        this.dispatchEvent(selectEvent);
    }
}