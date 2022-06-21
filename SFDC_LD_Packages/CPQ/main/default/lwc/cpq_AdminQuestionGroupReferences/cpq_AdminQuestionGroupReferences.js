import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminQuestionGroupReferences extends LightningElement {

    // Question group
    @api group;

    // Object containing selections for all levels
    @api selected;

    // If references are currently selected
    get isSelected() {
        return this.selected.questionGroupTab !== 'references';
    }

    toggleSelection(event) {
        // Send select event to parent
        const selectEvent = new CustomEvent(
        'select', {
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: this.selected.playbookTab,
                    questionGroup: this.selected.questionGroup,
                    questionGroupName: this.selected.questionGroupName,
                    questionGroupTab: this.selected.questionGroupTab === 'references' ? 'group' : 'references'
                }
            }
        });
        this.dispatchEvent(selectEvent); 
    }

    actionSelected(event) {
        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: {
                        playbook: event.detail.item.CPQ_Playbook_Rule__r.CPQ_Playbook__c,
                        playbookName: event.detail.item.CPQ_Playbook_Rule__r.CPQ_Playbook__r.Name,
                        playbookTab: 'rules',
                        rule: event.detail.item.CPQ_Playbook_Rule__c,
                        ruleName: event.detail.item.CPQ_Playbook_Rule__r.Name,
                        ruleTab: 'actions',
                        ruleAction: event.detail.item.Id,
                        ruleActionName: event.detail.item.Name,
                        ruleActionTab: 'action'
                    }
                }
            });
        this.dispatchEvent(selectEvent);
    }

}