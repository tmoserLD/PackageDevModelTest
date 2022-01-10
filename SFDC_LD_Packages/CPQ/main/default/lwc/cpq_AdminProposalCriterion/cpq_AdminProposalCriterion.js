import { LightningElement, api, track } from 'lwc';

export default class Cpq_AdminProposalCriterion extends LightningElement {

    // Spinner
    @track loading = false;

    // Criterion
    @api criterion;

    // Object containing selections for all levels
    @api selected;

    // If criterion is currently selected
    get isSelected() {
        if (this.selected.proposalSectionCriteriaGroupCriterion !== undefined) {
            return this.selected.proposalSectionCriteriaGroupCriterion.includes(this.criterion.criterionInfo.Id);
        } else {
            return false;
        }
    }

    selectCriterion(event) {
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
                    proposalSectionCriteriaGroupTab: 'criteria',
                    proposalSectionCriteriaGroupCriterion: this.selected.proposalSectionCriteriaGroupCriterion === this.criterion.criterionInfo.Id ? undefined : this.criterion.criterionInfo.Id,
                    proposalSectionCriteriaGroupCriterionName: this.selected.proposalSectionCriteriaGroupCriterionName === this.criterion.criterionInfo.Name ? undefined : this.criterion.criterionInfo.Name
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
        if (this.selected.proposalSectionCriteriaGroupCriterionName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'proposalSections',
                        proposalSection: this.selected.proposalSection,
                        proposalSectionName: this.selected.proposalSectionName,
                        proposalSectionTab: 'criteriaGroups',
                        proposalSectionCriteriaGroup: this.selected.proposalSectionCriteriaGroup,
                        proposalSectionCriteriaGroupName: this.selected.proposalSectionCriteriaGroupName,
                        proposalSectionCriteriaGroupTab: 'criteria',
                        proposalSectionCriteriaGroupCriterion: this.criterion.criterionInfo.Id,
                        proposalSectionCriteriaGroupCriterionName: this.criterion.criterionInfo.Name
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