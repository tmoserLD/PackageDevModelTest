import { LightningElement, api, track } from 'lwc';

export default class Cpq_AdminProposalCriteria extends LightningElement {

    // All criteria for group
    @api criteria;
    
    // Object containing selections for all levels
    @api selected;
    
    // Create new toggle
    @track createNew = false;

    // Spinner
    @track loading = false;

    // Search Term
    @track searchTerm;

    get collapsed() {
        return this.selected.proposalSectionCriteriaGroupTab !== 'criteria';
    }

    get filteredCriteria() {
        if (this.searchTerm !== undefined &&
            this.searchTerm !== null &&
            this.searchTerm !== ''    
        ) {
            return this.criteria.filter(
                criterion => criterion.criterionInfo.Name.toLowerCase().includes(this.searchTerm.toLowerCase())
            );
        } else {
            return this.criteria;
        }
    }

    searchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    toggleCollapse() {
        this.updateSelections({
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: 'proposalSections',
                    proposalSection: this.selected.proposalSection,
                    proposalSectionName: this.selected.proposalSectionName,
                    proposalSectionTab: 'criteriaGroups',
                    proposalSectionCriteriaGroup: this.selected.proposalSectionCriteriaGroup,
                    proposalSectionCriteriaGroupName: this.selected.proposalSectionCriteriaGroupName,
                    proposalSectionCriteriaGroupTab: this.selected.proposalSectionCriteriaGroupTab === 'criteria' ? 'group' : 'criteria'
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