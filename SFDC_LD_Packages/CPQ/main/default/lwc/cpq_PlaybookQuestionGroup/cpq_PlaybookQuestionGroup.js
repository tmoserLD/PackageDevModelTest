import { LightningElement, api, track } from 'lwc';

export default class CPQ_PlaybookQuestionGroup extends LightningElement {

    // Group Info
    @api group;

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // Value of group questions being shown
    @track collapsed = false;

    // If Group has at all questions completed
    get completed() {
        let completed = true;
        this.group.questions.forEach(function(question) {
            if (!question.questionInfo.IsHidden__c &&
                !question.questionInfo.IsReadOnly__c &&
                (
                    question.questionInfo.answer === undefined ||
                    question.questionInfo.answer === null ||
                    question.questionInfo.answer === '' ||
                    !question.questionInfo.touched
                )
            ) {
                completed = false;
            }
        });

        return completed;
    }

    // If Group has at least 1 Question that needs attention
    get needsAttention() {
        let needsAttention = false;
        this.group.questions.forEach(function(question) {
            if (!question.questionInfo.IsHidden__c &&
                question.questionInfo.IsRequired__c &&
                !question.questionInfo.IsReadOnly__c &&
                (
                    question.questionInfo.answer === undefined ||
                    question.questionInfo.answer === null ||
                    question.questionInfo.answer === '' ||
                    !question.questionInfo.touched
                )    
            ) {
                needsAttention = true;
            }
        });

        return needsAttention;
    }

    // Toggle Collapse Value
    toggleCollapse() {
        this.collapsed = !this.collapsed;
    }

    // Answer "Touched" Event
    answerTouch(event) {

        const touchEvent = new CustomEvent(
            'touch', {
                detail: {
                    groupId: this.group.groupInfo.Id,
                    questionId: event.detail.questionId,
                    answer: event.detail.answer
                }
            });
        this.dispatchEvent(touchEvent);
    }
}