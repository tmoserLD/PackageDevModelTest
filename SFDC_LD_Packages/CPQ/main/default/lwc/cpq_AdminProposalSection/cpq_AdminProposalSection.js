import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminProposalSection extends LightningElement {

    // Spinner
    @track loading = false;

    // Section
    @api section;

        // Object containing selections for all levels
        @api selected;

        // If section is currently selected
        get isSelected() {
            if (this.selected.proposalSection !== undefined
            ) {
                return this.selected.proposalSection.includes(this.section.sectionInfo.Id);
            } else {
                return false;
            }
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
            if (this.selected.proposalSectionName === undefined) {
                this.updateSelections({
                    detail: {
                        selected: {
                            tabChange: false,
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'proposalSections',
                            proposalSection: this.section.sectionInfo.Id,
                            proposalSectionName: this.section.sectionInfo.Name,
                            proposalSectionTab: this.selected.proposalSectionTab
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