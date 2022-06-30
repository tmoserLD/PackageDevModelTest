import { LightningElement, api, track } from 'lwc';

export default class CPQ_PlaybookQuestion extends LightningElement {

    // All Questions in group
    @api allQuestions = [];

    // Configuration Type
    @api configType;

    // Question Info
    @api question;

    // Opportunity Currency Iso Code
    @api oppCurrency;

    // If Question has been completed
    get completed() {
        if ((
                this.question.questionInfo.touched ||
                this.question.questionInfo.IsReadOnly__c
            ) &&
            this.question.questionInfo.answer !== undefined &&
            this.question.questionInfo.answer !== null &&
            this.question.questionInfo.answer !== ''
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Question has help text
    get hasHelpText() {
        return this.question.questionInfo.Help_Text__c !== undefined
    }

    // Record Lookup input type
    get isRecordLookup() {
        return this.question.questionInfo.Answer_Type__c === 'Record Lookup';
    }

    // Main CSS for component
    get mainCSS() {
        let mainCSS = 'slds-grid_vertical ';
        if (this.allQuestions.filter(
                question => (this.configType.includes('Admin') || question.questionInfo.IsHidden__c !== true)
            ).indexOf(this.question) % 2 === 1
        ) {
            mainCSS += 'slds-theme_shade';
        }

        return mainCSS;
    }

    // If Question needs attention
    get needsAttention() {
        if (this.question.questionInfo.IsRequired__c &&
            !this.question.questionInfo.IsReadOnly__c &&
            (
                this.question.questionInfo.answer === undefined ||
                this.question.questionInfo.answer === null ||
                this.question.questionInfo.answer === '' ||
                !this.question.questionInfo.touched
            )
        ) {
            return true;
        } else {
            return false;
        }
    }

    get visible() {
        return (this.question.questionInfo.IsHidden__c !== true || this.configType.includes('Admin'))
    }

    // Answer "Touched" Event
    answerTouch(event) {

        const touchEvent = new CustomEvent(
            'touch', {
                detail: {
                    questionId: this.question.questionInfo.Id,
                    answer: event.detail.answer,
                    selectedRecords: event.detail.selectedRecords
                }
            });
        this.dispatchEvent(touchEvent);
    }
}