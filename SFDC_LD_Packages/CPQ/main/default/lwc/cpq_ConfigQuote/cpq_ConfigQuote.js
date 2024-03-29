import { LightningElement, api, track } from 'lwc';
// Initial Query Method
import getConfigInfo from '@salesforce/apex/cpq_ConfigQuoteClass.getConfigInfo';
// Contract Query Method
import getContractInfo from '@salesforce/apex/cpq_ConfigQuoteClass.getContractInfo';
export default class CPQ_ConfigQuote extends LightningElement {
    // Type of Quote configuration
    @api configType;
    // Default Currency
    @api defaultCurrency;
    // Hide Header
    @api hideHeader;
    // Opportunity Info
    @api oppInfo;
    // Quote Info for existing quote being edited (Empty obj if new Quote)
    @api existingQuoteData;
    // User Info
    @api userInfo;

    // Playbook Approvals
    @track approvals = [];
    // Loading / Show Spinner
    @track loading = true;
    // Playbooks info
    @track playbooks = [];
    // Pricebooks info
    @track pricebooks = [];
    // Approvals needed for Quote
    @track quoteApprovals = [];
    // End Date of quote being configured
    @track quoteEndDate;
    // Name of quote being configured
    @track quoteName = 'New Quote';
    // Start Date of quote being configured
    @track quoteStartDate;
    // Products added to Quote
    @track quoteProducts = [];
    // Key increment helper upon deletion such that child product components do not inherit different product with same previous key
    @track quoteProductKeyHelper = 1;
    // Playbook Rules
    @track rules = [];
    // Id of Playbook currently selected
    @track selectedPlaybookId;
    // Pricebook related to currently selected Playbook
    @track selectedPricebook;
    // Contract Info for contract being replaced/renewed
    @track contractInfo = {Contract_Playbook_Answers__r: [], Contract_Entitlements__r: []};
    // Columns to show for Product Summary
    @track productColumns = [];
    // Columns to show for Entitlement Summary
    @track entitlementColumns = [];
    // Currency Conversion Map
    @track currencyMap = {};
    // Contract Currency
    @track contractCurrency;
    // Opportunity Currency
    @track oppCurrency;
    // CPQ Admin
    @track isCPQAdmin;

    // On Mount
    async connectedCallback() {
        // Get configInfo
        let configInfo;
        try {
            configInfo = await getConfigInfo({
                adjustingContract: this.existingQuoteData.Adjustment_of_Contract__c,
                contractView: (this.configType.includes('View') && this.existingQuoteData.contractId !== undefined)
            });
            let playbooks = configInfo.playbooks;
            this.rules = configInfo.rules;
            this.approvals = configInfo.approvals;
            this.pricebooks = configInfo.pricebooks;
            this.pricebooks.forEach(function(pricebook) {
                pricebook.entries = pricebook.entries.filter(
                    entry => entry.CurrencyIsoCode === undefined || entry.CurrencyIsoCode === this.defaultCurrency
                )
            }, this);
            this.currencyMap = configInfo.currencyMap;
            this.oppCurrency = this.oppInfo.CurrencyIsoCode;
            if (this.configType.includes('View') && this.existingQuoteData.contractId !== undefined && this.existingQuoteData.CurrencyIsoCode !== undefined) {
                this.oppCurrency = this.existingQuoteData.CurrencyIsoCode;
            }
            this.isCPQAdmin = configInfo.isCPQAdmin;

            // Set existing quote Name
            if (this.existingQuoteData.Name !== undefined) {
                this.quoteName = this.existingQuoteData.Name;
            }
            // Get Contract info
            if (this.existingQuoteData.Adjustment_of_Contract__c !== undefined) {
                this.contractInfo = await getContractInfo({
                    contractId: this.existingQuoteData.Adjustment_of_Contract__c,
                    contractFields: configInfo.contractFields,
                    entitlementFields: configInfo.entitlementFields
                });
                // Currency for non-MultiCurrency orgs
                if (this.contractInfo.CurrencyIsoCode === undefined) {
                    this.contractInfo.CurrencyIsoCode = this.defaultCurrency;
                }
                this.contractCurrency = this.contractInfo.CurrencyIsoCode;
                // Do not allow empty child lists
                if (this.contractInfo.Contract_Playbook_Answers__r === undefined) {
                    this.contractInfo.Contract_Playbook_Answers__r = [];
                }
                if (this.contractInfo.Contract_Entitlements__r === undefined) {
                    this.contractInfo.Contract_Entitlements__r = [];
                }
            }
            // Set default selected playbook
            if (playbooks.length > 0) {
                // Match playbook from existing quote
                if (this.existingQuoteData.CPQ_Playbook__c !== undefined) {
                    this.selectedPlaybookId = this.existingQuoteData.CPQ_Playbook__c;
                }
                // Default playbook
                else if (this.oppInfo?.SystemSettings?.Default_Playbook__c !== undefined) {
                    this.selectedPlaybookId = this.oppInfo.SystemSettings.Default_Playbook__c;
                }
                // Otherwise default to first playbook
                else {
                    this.selectedPlaybookId = playbooks[0].playbookInfo.Id;
                }
                let selectedPlaybook = playbooks.find(p => p.playbookInfo.Id === this.selectedPlaybookId);
                this.selectedPricebook = JSON.parse(JSON.stringify(
                    this.pricebooks.find(pricebook => pricebook.pricebookInfo.Id === selectedPlaybook.playbookInfo.Pricebook__c)
                ));
                this.productColumns = selectedPlaybook.productColumns;
                this.entitlementColumns = selectedPlaybook.entitlementColumns;
                if (this.selectedPricebook !== undefined &&
                    this.selectedPricebook.entries !== undefined    
                ) {
                    this.selectedPricebook.entries.forEach(function(pbe) {
                        if (this.configType.includes('View')) {
                            pbe.Manually_Addible = false;
                        } else {
                            pbe.Manually_Addible = pbe.Manually_Addible__c;
                        }
                    }, this);
                }
            }

            // Set default values on questions
            playbooks.forEach(function(playbook) {
                playbook.questionGroups.forEach(function(group) {
                    // Previous values obj
                    group.groupInfo.prevValues = {};
                    group.questions.forEach(function(question) {
                        // Previous values obj
                        question.questionInfo.prevValues = {};
                        // Find value from existing quote answer
                        let existingValue;
                        let existingSelectedRecords;
                        let existingTouch;
                        if (this.existingQuoteData.CPQ_Playbook_Answers__r !== undefined) {
                            this.existingQuoteData.CPQ_Playbook_Answers__r.filter(
                                answer => answer.CPQ_Playbook_Question__c === question.questionInfo.Id
                            ).forEach(function(answer) {
                                if (question.questionInfo.Answer_Type__c === 'Boolean') {
                                    existingValue = answer.Value_Boolean__c;
                                }
                                else if (question.questionInfo.Answer_Type__c === 'Currency') {
                                    if (this.existingQuoteData.contractId !== undefined && 
                                        answer.Value_Currency__c !== undefined    
                                    ) {
                                        existingValue = this.convertCurrency(answer.Value_Currency__c, this.existingQuoteData.CurrencyIsoCode, this.oppCurrency);
                                    } else {
                                        existingValue = answer.Value_Currency__c;
                                    }
                                } 
                                else if (question.questionInfo.Answer_Type__c === 'Date') {
                                    existingValue = answer.Value_Date__c;
                                }
                                else if (question.questionInfo.Answer_Type__c === 'Decimal') {
                                    existingValue = answer.Value_Decimal__c;
                                }
                                else if (question.questionInfo.Answer_Type__c === 'Integer') {
                                    existingValue = answer.Value_Integer__c;
                                }
                                else if (question.questionInfo.Answer_Type__c === 'Picklist' ||
                                    question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                                    question.questionInfo.Answer_Type__c === 'Text' ||
                                    question.questionInfo.Answer_Type__c === 'Text Area' ||
                                    question.questionInfo.Answer_Type__c === 'Record Lookup'
                                ) {
                                    existingValue = answer.Value_Text__c;
                                    if (answer.Selected_Records_String__c !== undefined) {
                                        existingSelectedRecords = JSON.parse(answer.Selected_Records_String__c);
                                    }
                                }
                                existingTouch = answer.HasBeenTouched__c;
                            }, this);
                        }
                        // View Mode
                        if (this.configType.includes('View')) {
                            // Set answers from source
                            question.questionInfo.answer = existingValue;
                            question.questionInfo.selectedRecords = existingSelectedRecords;
                            question.questionInfo.touched = existingTouch;
                        }
                        // Normal Mode
                        else {
                            // Default Field Value
                            if (question.questionInfo.Default_Field_Value__c !== undefined) {
                                // Determine object housing field
                                let obj = question.questionInfo.Default_Field_Value__c.split('.')[0];
                                let field = question.questionInfo.Default_Field_Value__c.split('.')[1];
                                let value;
                                // Quote
                                if (obj === 'Quote' &&
                                    this.existingQuoteData.Id !== undefined
                                ) {
                                    value = this.existingQuoteData[field];
                                }
                                // Opportunity
                                else if (obj === 'Opportunity') {
                                    value = this.oppInfo[field];
                                }
                                // Account
                                else if (obj === 'Account') {
                                    value = this.oppInfo.Account[field];
                                }
                                // User
                                else if (obj === 'User') {
                                    value = this.userInfo[field];
                                }
                                // Profile
                                else if (obj === 'Profile') {
                                    value = this.userInfo.Profile[field];
                                }
                                // UserRole
                                else if (obj === 'UserRole') {
                                    value = this.userInfo.UserRole[field];
                                }
                                // Contract
                                else if (obj === 'Contract' &&
                                    this.contractInfo.Id !== undefined
                                ) {
                                    value = this.contractInfo[field];
                                }
                                question.questionInfo.answer = value;
                            }
                            // Value found from existing answer
                            else if (existingValue !== undefined) {
                                question.questionInfo.answer = existingValue;
                                question.questionInfo.selectedRecords = existingSelectedRecords;
                                question.questionInfo.touched = existingTouch;
                            }
                            // Default Values
                            // Boolean
                            else if (question.questionInfo.Default_Value_Boolean__c !== undefined &&
                                question.questionInfo.Answer_Type__c === 'Boolean'  
                            ) {
                                question.questionInfo.answer = question.questionInfo.Default_Value_Boolean__c;
                            }
                            // Currency
                            else if (question.questionInfo.Default_Value_Currency__c !== undefined &&
                                question.questionInfo.Answer_Type__c === 'Currency'  
                            ) {
                                question.questionInfo.answer = this.convertCurrency(question.questionInfo.Default_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                            }
                            // Date
                            else if (question.questionInfo.Default_Value_Date__c !== undefined &&
                                question.questionInfo.Answer_Type__c === 'Date'  
                            ) {
                                question.questionInfo.answer = question.questionInfo.Default_Value_Date__c;
                            }
                            // Decimal
                            else if (question.questionInfo.Default_Value_Decimal__c !== undefined &&
                                question.questionInfo.Answer_Type__c === 'Decimal'  
                            ) {
                                question.questionInfo.answer = question.questionInfo.Default_Value_Decimal__c;
                            }
                            // Integer
                            else if (question.questionInfo.Default_Value_Integer__c !== undefined &&
                                question.questionInfo.Answer_Type__c === 'Integer'  
                            ) {
                                question.questionInfo.answer = question.questionInfo.Default_Value_Integer__c;
                            }
                            // Text
                            else if (question.questionInfo.Default_Value_Text__c !== undefined &&
                                (
                                    question.questionInfo.Answer_Type__c === 'Picklist' ||
                                    question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                                    question.questionInfo.Answer_Type__c === 'Text' ||
                                    question.questionInfo.Answer_Type__c === 'Text Area'
                                )
                            ) {
                                question.questionInfo.answer = question.questionInfo.Default_Value_Text__c;
                            }
                            // No Default
                            else {
                                if (question.questionInfo.Answer_Type__c === 'Boolean') {
                                    question.questionInfo.answer = false;
                                }
                            }
                        }
                    }, this);
                }, this);
            }, this);
            // Add existing products
            if (this.existingQuoteData.QuoteLineItems !== undefined) {
                this.existingQuoteData.QuoteLineItems.forEach(function(qli) {
                    // Selected Pricebook
                    if (this.selectedPricebook !== undefined &&
                        this.selectedPricebook.entries !== undefined    
                    ) {
                        this.selectedPricebook.entries.forEach(function(entry) {
                            // Matching product
                            if (entry.Product2Id === qli.Product2Id ||
                                entry.Product2Id === qli.Product__c    
                            ) {
                                let prd = JSON.parse(JSON.stringify(entry));
                                // Get all qli attributes
                                for (const [key, value] of Object.entries(qli)) {
                                    if (key !== 'Id') {
                                        prd[key] = value;
                                    }
                                }
                                // Product Name
                                prd.Product_Name = entry.Product2.Name;             
                                // Quantity
                                prd.Quantity = qli.Quantity__c;
                                // Currency conversion
                                let conversionCurrency = this.oppCurrency;
                                if (this.existingQuoteData.contractId !== undefined) {
                                    conversionCurrency = this.existingQuoteData.CurrencyIsoCode;
                                }
                                // List Price
                                prd.List_Price = this.convertCurrency(qli.List_Price__c, conversionCurrency, this.oppCurrency);
                                // Unit Price
                                prd.Unit_Price = this.convertCurrency(qli.Unit_Price__c, conversionCurrency, this.oppCurrency);
                                // Discount
                                if (prd.List_Price !== 0) {
                                    prd.Discount = 1 - (prd.Unit_Price / prd.List_Price);
                                } else {
                                    prd.Discount = 0;
                                }
                                // Prices
                                prd.Total_Price = prd.Unit_Price * prd.Quantity;
                                prd.Sub_Total_Price = prd.List_Price * prd.Quantity;
                                // Dates
                                prd.Start_Date = qli.Start_Date__c;
                                prd.End_Date = qli.End_Date__c;
                                // Permissions
                                prd.Adjustable_Product_Columns__c = entry.Adjustable_Product_Columns__c !== undefined ? entry.Adjustable_Product_Columns__c.split(';') : [];
                                prd.Removable = entry.Removable__c;
                                prd.Pricing_Set_Identifier = entry.Pricing_Set_Identifier__c;
                                // Previous values obj
                                prd.prevValues = {};
                                // QLI Stamp Fields
                                prd.qliFields = [];
                                // Added by action
                                prd.addedByAction = qli.CPQ_Playbook_Rule_Action__c; 
                                // Key
                                prd.key = this.quoteProducts.length.toString() + '.' + this.quoteProductKeyHelper.toString();
                                // Playbook
                                prd.playbookId = this.selectedPlaybookId;
                                // Evaluate Pricing
                                if (!this.configType.includes('View')) {
                                    this.evalProductPricing(prd);
                                }
                                let updatedProducts = JSON.parse(JSON.stringify(this.quoteProducts));
                                updatedProducts.push(prd);
                                this.quoteProducts = updatedProducts;
                            }
                        }, this);
                    }
                }, this);
            }

            // Set Quote Dates
            this.updateQuoteDates(playbooks);

            // Run rules
            playbooks = this.runRules(playbooks);
            this.playbooks = playbooks;

            // Evaluate approvals
            this.evaluateApprovals();

            this.loading = false;

        } catch (e) {
            console.error(e);
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to retrieve the CPQ Configuration Data',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }
    }

    // Title for Quote Configuration
    get configTitle() {
        if (this.configType.includes('New')) {
            return 'Configure New Quote';
        } else if (this.configType.includes('Edit')) {
            return 'Configure Quote';
        } else if (this.configType.includes('View')) {
            return 'View Only';
        }
    }

    // Playbook picklist options
    get playbookOptions() {
        let playbookOptions = [];
        this.playbooks.forEach(function(playbook) {
            playbookOptions.push(
                {
                    label: playbook.playbookInfo.Label__c,
                    value: playbook.playbookInfo.Id
                }
            );
        });
        return playbookOptions;
    }

    // Selected Playbook Products
    get playbookProducts() {
        return this.quoteProducts.filter(product => product.playbookId === this.selectedPlaybookId);
    }

    // Playbook has been selected
    get playbookSelected() {
        if (this.selectedPlaybookId) {
            return true;
        } else {
            return false;
        }
    }

    get viewMode() {
        return (this.configType.includes('View'));
    }

    // Playbook that is currently selected
    get selectedPlaybookObj() {
        if (this.selectedPlaybookId) {
            return this.playbooks.find(
                playbook => playbook.playbookInfo.Id === this.selectedPlaybookId
            );
        } else {
            return {};
        }
    }

    // Answer "Touched" Event
    answerTouch(event) {

        let updatedPlaybooks = this.playbooks;

        updatedPlaybooks.forEach(function(playbook) {
            if (playbook.playbookInfo.Id === event.detail.playbookId) {
                playbook.questionGroups.forEach(function(group) {
                    if (group.groupInfo.Id === event.detail.groupId) {
                        group.questions.forEach(function(question) {
                            if (question.questionInfo.Id === event.detail.questionId) {
                                question.questionInfo.touched = true;
                                question.questionInfo.answer = event.detail.answer;
                                question.questionInfo.selectedRecords = event.detail.selectedRecords;
                            }
                        });
                    }
                });
            }
        });

        // Run rules
        updatedPlaybooks = this.runRules(updatedPlaybooks);
        this.playbooks = updatedPlaybooks;

        // Evaluate approvals
        this.evaluateApprovals();
    }

    // Cancel clicked - return to main
    cancel() {
        const cancelEvent = new CustomEvent(
            'cancel', {
                detail: '' 
            });
        this.dispatchEvent(cancelEvent);
    }

    // Check and act on Approvals
    evaluateApprovals() {
        // Do not run in View mode
        if (!this.configType.includes('View')) {
            this.approvals.forEach(function(approval) {
                // Approval of selected playbook
                if (approval.approvalInfo.CPQ_Playbook__c === this.selectedPlaybookId) {
                    let approvalEvaluation = this.template.querySelector('c-cpq_-config-quote-evaluator').evaluateCriteria(
                        approval,
                        this.playbooks,
                        this.configType,
                        this.defaultCurrency,
                        this.existingQuoteData,
                        this.quoteProducts,
                        this.selectedPlaybookId,
                        this.contractInfo,
                        this.currencyMap,
                        this.contractCurrency,
                        this.oppCurrency
                    );

                    // Change in approval evaluation status
                    if (approvalEvaluation != approval.approvalInfo.prevEvaluation) {

                        // Add
                        if (approvalEvaluation === true) {
                            let approvalToAdd = JSON.parse(JSON.stringify(approval));
                            this.quoteApprovals.push(approvalToAdd);
                        }
                        // Remove
                        else if (approvalEvaluation === false) {
                            let updatedApprovals = this.quoteApprovals.filter(
                                addedApproval => addedApproval.approvalInfo.Id !== approval.approvalInfo.Id
                            );
                            this.quoteApprovals = updatedApprovals;
                        }
                    }

                    // Set lookback evaluation for next update
                    approval.approvalInfo.prevEvaluation = approvalEvaluation;
                }
            }, this);
        }
    }

    // Check and act on Rules
    evaluateRules(playbooks) {
        let changedRuleEvaluation = false;
        // Do not run in View mode
        if (!this.configType.includes('View')) {
            this.rules.forEach(function(rule) {
                // Ignore flagged rules
                if (rule.ruleInfo.doNotEvaluate !== true) {
                    // Rule of selected playbook
                    if (rule.ruleInfo.CPQ_Playbook__c === this.selectedPlaybookId) {
                        let ruleEvaluation = this.template.querySelector('c-cpq_-config-quote-evaluator').evaluateCriteria(
                            rule,
                            playbooks,
                            this.configType,
                            this.defaultCurrency,
                            this.existingQuoteData,
                            this.quoteProducts,
                            this.selectedPlaybookId,
                            this.contractInfo,
                            this.currencyMap,
                            this.contractCurrency,
                            this.oppCurrency
                        );

                        // Determine if rule should fire
                        if ((
                                rule.ruleInfo.Evaluate_When__c === 'Evaluation change' &&
                                ruleEvaluation != rule.ruleInfo.prevEvaluation
                            ) ||
                            (
                                rule.ruleInfo.Evaluate_When__c === 'When TRUE with evaluation change' &&
                                ruleEvaluation === true &&
                                rule.ruleInfo.prevEvaluation !== true
                            ) ||
                            (
                                rule.ruleInfo.Evaluate_When__c === 'Always when TRUE' &&
                                ruleEvaluation === true
                            ) ||
                            (
                                rule.ruleInfo.Evaluate_When__c === 'On first evaluation' &&
                                rule.ruleInfo.prevEvaluation === undefined
                            ) ||
                            (
                                rule.ruleInfo.Evaluate_When__c === 'On first TRUE evaluation' &&
                                rule.ruleInfo.hasHadTrueEvaluation === undefined &&
                                ruleEvaluation === true
                            ) ||
                            rule.ruleInfo.Evaluate_When__c === 'Always'
                        ) {

                            if (ruleEvaluation != rule.ruleInfo.prevEvaluation) {
                                changedRuleEvaluation = true;
                            }

                            // Flag rule to never evaluate again
                            if (rule.ruleInfo.Evaluate_When__c === 'On first TRUE evaluation') {
                                rule.ruleInfo.doNotEvaluate = true;
                            }

                            // Run each action
                            rule.actions.forEach(function(action) {

                                // System Value actions
                                if (action.actionInfo.Action_Type__c === 'Adjust system value') {
                                    if (action.actionInfo.System_Value__c === 'Quote Start Date' ||
                                        action.actionInfo.System_Value__c === 'Quote Term' ||
                                        action.actionInfo.System_Value__c === 'Quote End Date'
                                    ) {
                                        if (ruleEvaluation === true) {
                                            let newStartDate = this.quoteStartDate;
                                            let newEndDate = this.quoteEndDate;
                                            if (action.actionInfo.System_Value__c === 'Quote Term') {
                                                let newTermVal = action.actionInfo.Field_Value_Integer__c;
                                                if (action.actionInfo.Value_Source_Type__c === 'Dynamic') {
                                                    newTermVal = this.runCalculations(action.calculationItems, action.actionInfo.Calculation_Type__c, 'Integer', playbooks, action.actionInfo.Numeric_Math_Operator__c, rule.contributingRecordIDs);
                                                }
                                                if (this.existingQuoteData.Adjustment_Type__c === 'Amendment') {
                                                    newStartDate = new Date(this.quoteEndDate);
                                                    newStartDate.setMonth(new Date(this.quoteEndDate).getUTCMonth() - Number(newTermVal));
                                                    newStartDate.setDate(newStartDate.getUTCDate() + 1);
                                                    newStartDate = this.convertDate(newStartDate);
                                                } else {
                                                    newEndDate = new Date(this.quoteStartDate);
                                                    newEndDate.setMonth(new Date(this.quoteStartDate).getUTCMonth() + Number(newTermVal));
                                                    newEndDate.setDate(newEndDate.getUTCDate() - 1);
                                                    newEndDate = this.convertDate(newEndDate);
                                                }
                                            } else {
                                                let newDateVal = action.actionInfo.Field_Value_Date__c;
                                                if (action.actionInfo.Value_Source_Type__c === 'Dynamic') {
                                                    newDateVal = this.runCalculations(action.calculationItems, action.actionInfo.Calculation_Type__c, 'Date', playbooks, action.actionInfo.Numeric_Math_Operator__c, rule.contributingRecordIDs);
                                                }
                                                if (action.actionInfo.System_Value__c === 'Quote Start Date') {
                                                    newStartDate = newDateVal;
                                                    newEndDate = new Date(newDateVal);
                                                    newEndDate.setMonth(new Date(newDateVal).getUTCMonth() + this.quoteTerm);
                                                    newEndDate.setDate(newEndDate.getUTCDate() - 1);
                                                    newEndDate = this.convertDate(newEndDate);
                                                } else {
                                                    newEndDate = newDateVal;
                                                    newStartDate = new Date(newDateVal);
                                                    newStartDate.setMonth(new Date(newDateVal).getUTCMonth() - this.quoteTerm);
                                                    newStartDate.setDate(newStartDate.getUTCDate() + 1);
                                                    newStartDate = this.convertDate(newStartDate);
                                                }
                                            }
                                            console.log(newStartDate);
                                            console.log(newEndDate);
                                            this.quoteProducts.forEach(function(product) {

                                                if (product['Start_Date'] === this.quoteStartDate ||
                                                    new Date(product['Start_Date']) < new Date(newStartDate)
                                                ) {
                                                    product.prevValues['Start_Date'] = product['Start_Date'];
                                                    product['Start_Date'] = newStartDate;
                                                }
                                                if (product['End_Date'] === this.quoteEndDate ||
                                                    new Date(product['End_Date']) > new Date(newEndDate)
                                                ) {
                                                    product.prevValues['End_Date'] = product['End_Date'];
                                                    product['End_Date'] = newEndDate;
                                                }
                                            }, this);

                                        } else {
                                            this.quoteProducts.forEach(function(product) {
                                                if (product.prevValues.hasOwnProperty('Start_Date')) {
                                                    product['Start_Date'] = product.prevValues['Start_Date'];
                                                }
                                                if (product.prevValues.hasOwnProperty('End_Date')) {
                                                    product['End_Date'] = product.prevValues['End_Date'];
                                                }
                                            }, this);
                                        }
                                    }
                                    else if (
                                        action.actionInfo.System_Value__c === 'Quote Start Date Editable' ||
                                        action.actionInfo.System_Value__c === 'Quote Term Editable' ||
                                        action.actionInfo.System_Value__c === 'Quote End Date Editable' 
                                    ) {
                                        let newVal = action.actionInfo.Field_Value_Boolean__c;
                                        if (action.actionInfo.Value_Source_Type__c === 'Dynamic') {
                                            newVal = this.runCalculations(action.calculationItems, action.actionInfo.Calculation_Type__c, 'Boolean', playbooks, action.actionInfo.Numeric_Math_Operator__c, rule.contributingRecordIDs);
                                        }
                                        if (action.actionInfo.System_Value__c === 'Quote Start Date Editable') {
                                            playbooks.find(
                                                p => p.playbookInfo.Id === this.selectedPlaybookId
                                            ).playbookInfo.Start_Date_Editable__c = ruleEvaluation === true ? newVal : !newVal;
                                        } else if (action.actionInfo.System_Value__c === 'Quote Term Editable') {
                                            playbooks.find(
                                                p => p.playbookInfo.Id === this.selectedPlaybookId
                                            ).playbookInfo.Term_Editable__c = ruleEvaluation === true ? newVal : !newVal;
                                        } else if (action.actionInfo.System_Value__c === 'Quote End Date Editable') {
                                            playbooks.find(
                                                p => p.playbookInfo.Id === this.selectedPlaybookId
                                            ).playbookInfo.End_Date_Editable__c = ruleEvaluation === true ? newVal : !newVal;
                                        }
                                    }
                                }
                                // Playbook actions
                                else if (
                                    (
                                        action.actionInfo.Action_Type__c === 'Adjust question field' ||
                                        action.actionInfo.Action_Type__c === 'Adjust question group field'
                                    ) &&
                                    (
                                        action.actionInfo.CPQ_Playbook_Question__c !== undefined ||
                                        action.actionInfo.CPQ_Playbook_Question_Group__c !== undefined
                                    )
                                ) {
                                    playbooks.forEach(function(playbook) {
                                        // Matching Playbook
                                        if (playbook.playbookInfo.Id === this.selectedPlaybookId) {
                                            playbook.questionGroups.forEach(function(group) {
                                                // Matching Playbook
                                                if (group.groupInfo.CPQ_Playbook__c === this.selectedPlaybookId) {

                                                    // Question Group action
                                                    if (action.actionInfo.Action_Type__c === 'Adjust question group field') {

                                                        // Matching Question Group
                                                        if (group.groupInfo.Id === action.actionInfo.CPQ_Playbook_Question_Group__c) {

                                                            if (ruleEvaluation === true) {

                                                                group.groupInfo.prevValues[action.actionInfo.Question_Group_Adjustment_Field__c] = group.groupInfo[action.actionInfo.Question_Group_Adjustment_Field__c];

                                                                // Static Source
                                                                if (action.actionInfo.Value_Source_Type__c === 'Static') {
                                                                    
                                                                    // Set new static value
                                                                    if (action.actionInfo.Question_Group_Adjustment_Field__c === 'IsHidden__c') {
                                                                        group.groupInfo[action.actionInfo.Question_Group_Adjustment_Field__c] = action.actionInfo.Field_Value_Boolean__c;
                                                                    }
                                                                }
                                                                // Dynamic Source
                                                                else if (action.actionInfo.Value_Source_Type__c === 'Dynamic') {

                                                                    let fieldType;
                                                                    if (action.actionInfo.Question_Group_Adjustment_Field__c === 'IsHidden__c') {
                                                                        fieldType = 'Boolean';
                                                                    }
                                                                    group.groupInfo[action.actionInfo.Question_Group_Adjustment_Field__c] = this.runCalculations(action.calculationItems, action.actionInfo.Calculation_Type__c, fieldType, playbooks, action.actionInfo.Numeric_Math_Operator__c, rule.contributingRecordIDs);
                                                                }
                                                            } else {
                                                                if (group.groupInfo.prevValues.hasOwnProperty(action.actionInfo.Question_Group_Adjustment_Field__c)) {
                                                                    group.groupInfo[action.actionInfo.Question_Group_Adjustment_Field__c] = group.groupInfo.prevValues[action.actionInfo.Question_Group_Adjustment_Field__c];
                                                                }
                                                            }
                                                        }
                                                    }
                                                    // Question action
                                                    else if (action.actionInfo.Action_Type__c === 'Adjust question field') {
                                                        // Matching Group
                                                        if (group.groupInfo.Id === action.actionInfo.CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c) {
                                                            group.questions.forEach(function(question) {
                                                                // Matching Question
                                                                if (question.questionInfo.Id === action.actionInfo.CPQ_Playbook_Question__c) { 

                                                                    // Execute action
                                                                    if (action.actionInfo.Action_Type__c === 'Adjust question field') {

                                                                        if (ruleEvaluation === true) {

                                                                            let currentValue = question.questionInfo[action.actionInfo.Question_Adjustment_Field__c];
            
                                                                            // Static Source
                                                                            if (action.actionInfo.Value_Source_Type__c === 'Static') {
                                                                                
                                                                                // Set new static value
                                                                                if (
                                                                                    (
                                                                                        question.questionInfo.Answer_Type__c === 'Boolean' &&
                                                                                        action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                                    ) ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'IsHidden__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'IsRequired__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'IsReadOnly__c'
                                                                                ) {
                                                                                    question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = action.actionInfo.Field_Value_Boolean__c;
                                                                                }
                                                                                else if (question.questionInfo.Answer_Type__c === 'Currency' &&
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                                ) {
                                                                                    question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = this.convertCurrency(action.actionInfo.Field_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                                                                                }
                                                                                else if (question.questionInfo.Answer_Type__c === 'Date' &&
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                                ) {
                                                                                    question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = action.actionInfo.Field_Value_Date__c;
                                                                                }
                                                                                else if (
                                                                                    (
                                                                                        question.questionInfo.Answer_Type__c === 'Decimal' &&
                                                                                        action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                                    ) ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Minimum_Value__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Maximum_Value__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Maximum_Record_Selections__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Step_Value__c'
                                                                                ) {
                                                                                    question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = action.actionInfo.Field_Value_Decimal__c;
                                                                                }
                                                                                else if (question.questionInfo.Answer_Type__c === 'Integer' &&
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                                ) {
                                                                                    question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = action.actionInfo.Field_Value_Integer__c;
                                                                                }
                                                                                else if (
                                                                                    (
                                                                                        action.actionInfo.Question_Adjustment_Field__c === 'answer' &&
                                                                                        (
                                                                                            question.questionInfo.Answer_Type__c === 'Picklist' ||
                                                                                            question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                                                                                            question.questionInfo.Answer_Type__c === 'Text' ||
                                                                                            question.questionInfo.Answer_Type__c === 'Text Area'
                                                                                        )
                                                                                    ) ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Picklist_Answers__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Quote_Save_Field__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Query_String__c'
                                                                                ) {
                                                                                    question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = action.actionInfo.Field_Value_Text__c;
                                                                                }
                                                                            }
                                                                            // Dynamic Source
                                                                            else if (action.actionInfo.Value_Source_Type__c === 'Dynamic') {

                                                                                let fieldType;
                                                                                if (
                                                                                    (
                                                                                        question.questionInfo.Answer_Type__c === 'Boolean' &&
                                                                                        action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                                    ) ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'IsHidden__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'IsRequired__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'IsReadOnly__c'
                                                                                ) {
                                                                                    fieldType = 'Boolean';
                                                                                }
                                                                                else if (question.questionInfo.Answer_Type__c === 'Currency' &&
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                                ) {
                                                                                    fieldType = 'Currency';
                                                                                }
                                                                                else if (question.questionInfo.Answer_Type__c === 'Date' &&
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                                ) {
                                                                                    fieldType = 'Date';
                                                                                }
                                                                                else if (
                                                                                    (
                                                                                        question.questionInfo.Answer_Type__c === 'Decimal' &&
                                                                                        action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                                    ) ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Minimum_Value__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Maximum_Value__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Step_Value__c'
                                                                                ) {
                                                                                    fieldType = 'Decimal';
                                                                                }
                                                                                else if (question.questionInfo.Answer_Type__c === 'Integer' &&
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                                ) {
                                                                                    fieldType = 'Integer';
                                                                                }
                                                                                else if (
                                                                                    (
                                                                                        action.actionInfo.Question_Adjustment_Field__c === 'answer' &&
                                                                                        (
                                                                                            question.questionInfo.Answer_Type__c === 'Picklist' ||
                                                                                            question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                                                                                            question.questionInfo.Answer_Type__c === 'Text' ||
                                                                                            question.questionInfo.Answer_Type__c === 'Text Area'
                                                                                        )
                                                                                    ) ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Picklist_Answers__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Quote_Save_Field__c' ||
                                                                                    action.actionInfo.Question_Adjustment_Field__c === 'Query_String__c'
                                                                                ) {
                                                                                    fieldType = 'Text';
                                                                                }
                                                                                question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = this.runCalculations(action.calculationItems, action.actionInfo.Calculation_Type__c, fieldType, playbooks, action.actionInfo.Numeric_Math_Operator__c, rule.contributingRecordIDs);
                                                                            }

                                                                            // Only store previous value if different from 
                                                                            if (question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] !== currentValue) {
                                                                                question.questionInfo.prevValues[action.actionInfo.Question_Adjustment_Field__c] = currentValue;
                                                                            }

                                                                        } else {
                                                                            if (question.questionInfo.prevValues.hasOwnProperty(action.actionInfo.Question_Adjustment_Field__c)) {
                                                                                question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = question.questionInfo.prevValues[action.actionInfo.Question_Adjustment_Field__c];
                                                                            }
                                                                            // Set to Default Value if no previous value found
                                                                            else if (action.actionInfo.Question_Adjustment_Field__c === 'answer') {
                                                                                // Boolean
                                                                                if (question.questionInfo.Default_Value_Boolean__c !== undefined &&
                                                                                    question.questionInfo.Answer_Type__c === 'Boolean'  
                                                                                ) {
                                                                                    question.questionInfo.answer = question.questionInfo.Default_Value_Boolean__c;
                                                                                }
                                                                                // Currency
                                                                                else if (question.questionInfo.Default_Value_Currency__c !== undefined &&
                                                                                    question.questionInfo.Answer_Type__c === 'Currency'  
                                                                                ) {
                                                                                    question.questionInfo.answer = this.convertCurrency(question.questionInfo.Default_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                                                                                }
                                                                                // Date
                                                                                else if (question.questionInfo.Default_Value_Date__c !== undefined &&
                                                                                    question.questionInfo.Answer_Type__c === 'Date'  
                                                                                ) {
                                                                                    question.questionInfo.answer = question.questionInfo.Default_Value_Date__c;
                                                                                }
                                                                                // Decimal
                                                                                else if (question.questionInfo.Default_Value_Decimal__c !== undefined &&
                                                                                    question.questionInfo.Answer_Type__c === 'Decimal'  
                                                                                ) {
                                                                                    question.questionInfo.answer = question.questionInfo.Default_Value_Decimal__c;
                                                                                }
                                                                                // Integer
                                                                                else if (question.questionInfo.Default_Value_Integer__c !== undefined &&
                                                                                    question.questionInfo.Answer_Type__c === 'Integer'  
                                                                                ) {
                                                                                    question.questionInfo.answer = question.questionInfo.Default_Value_Integer__c;
                                                                                }
                                                                                // Text
                                                                                else if (question.questionInfo.Default_Value_Text__c !== undefined &&
                                                                                    (
                                                                                        question.questionInfo.Answer_Type__c === 'Picklist' ||
                                                                                        question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                                                                                        question.questionInfo.Answer_Type__c === 'Text' ||
                                                                                        question.questionInfo.Answer_Type__c === 'Text Area'
                                                                                    )
                                                                                ) {
                                                                                    question.questionInfo.answer = question.questionInfo.Default_Value_Text__c;
                                                                                }
                                                                            }
                                                                        }
                                                                        if (action.actionInfo.Question_Adjustment_Field__c === 'Picklist_Answers__c' &&
                                                                            !question.questionInfo.Picklist_Answers__c.includes(question.questionInfo.answer)
                                                                        ) {
                                                                            question.questionInfo.answer = '';
                                                                        }
                                                                        question.questionInfo.actionSet = question.questionInfo.actionSet === undefined ? 1 : (question.questionInfo.actionSet + 1);
                                                                        if (action.actionInfo.Question_Adjustment_Field__c === 'Query_String__c') {
                                                                            question.questionInfo.querySet = question.questionInfo.querySet === undefined ? 1 : (question.questionInfo.querySet + 1);
                                                                        }
                                                                    }
                                                                }
                                                            }, this);
                                                        }
                                                    }
                                                }
                                            }, this);
                                        }
                                    }, this);
                                }
                                // Product actions
                                else if (
                                    (
                                        action.actionInfo.Action_Type__c === 'Add product' ||
                                        action.actionInfo.Action_Type__c === 'Adjust product field' ||
                                        action.actionInfo.Action_Type__c === 'Adjust product field editability'
                                    ) &&
                                    action.actionInfo.Product__c !== undefined
                                ) {
                                    // Find associated product
                                    if (this.selectedPricebook !== undefined &&
                                        this.selectedPricebook.entries !== undefined    
                                    ) {
                                        this.selectedPricebook.entries.forEach(function(entry) {
                                            // Matching product
                                            if (entry.Product2Id === action.actionInfo.Product__c) {
                                                if (action.actionInfo.Action_Type__c === 'Add product') {
                                                    if (ruleEvaluation === true) {
                                                        // Only add if not already added by this rule (only relevant for initial action on edit)
                                                        if (this.quoteProducts.filter(
                                                                product => product.addedByAction === action.actionInfo.Id
                                                            ).length === 0
                                                        ) {
                                                            this.addProduct(JSON.parse(JSON.stringify(entry)), action.actionInfo.Id);
                                                        }
                                                    } else {
                                                        // Remove product
                                                        let updatedProducts = JSON.parse(JSON.stringify(this.quoteProducts));
                                                        updatedProducts = updatedProducts.filter(
                                                            product => product.addedByAction !== action.actionInfo.Id
                                                        );
                                                        this.rekeyProducts(updatedProducts);
                                                    }
                                                }
                                                else if (action.actionInfo.Action_Type__c === 'Adjust product field' ||
                                                    action.actionInfo.Action_Type__c === 'Adjust product field editability'
                                                ) {
                                                    // Manually Addible (pricebook entry level)
                                                    if (action.actionInfo.Product_Adjustment_Field__c === 'Manually_Addible') {
                                                        if (ruleEvaluation === true) {
                                                            entry.Manually_Addible = action.actionInfo.Field_Value_Boolean__c;
                                                        } else {
                                                            entry.Manually_Addible = !action.actionInfo.Field_Value_Boolean__c;
                                                        }
                                                        if (entry.Manually_Addible === false) {
                                                            // Remove manually added product
                                                            let updatedProducts = JSON.parse(JSON.stringify(this.quoteProducts));
                                                            updatedProducts = updatedProducts.filter(
                                                                product => !(product.addedByAction === undefined && product.Product2Id === entry.Product2Id && product.playbookId === this.selectedPlaybookId)
                                                            );
                                                            // Re-Key products
                                                            this.rekeyProducts(updatedProducts);
                                                        }
                                                    }
                                                    // All others (quote product level)
                                                    else {
                                                        this.quoteProducts.forEach(function(product) {
                                                            if (product.Product2Id === action.actionInfo.Product__c &&
                                                                product.playbookId === this.selectedPlaybookId &&
                                                                (
                                                                    (// Targeting specific rule action or not targeting anything
                                                                        action.actionInfo.Target_Manual_Addition_Only__c !== true &&
                                                                        (
                                                                            action.actionInfo.Product_Adjustment_Target_Rule_Action__c === undefined ||
                                                                            product.addedByAction === action.actionInfo.Product_Adjustment_Target_Rule_Action__c
                                                                        )
                                                                    ) ||
                                                                    (// Manually added target
                                                                        action.actionInfo.Target_Manual_Addition_Only__c === true &&
                                                                        product.addedByAction === undefined
                                                                    )
                                                                )
                                                            ) {
                                                                if (action.actionInfo.Action_Type__c === 'Adjust product field') {
                                                                    if (ruleEvaluation === true) {

                                                                        product.prevValues[action.actionInfo.Product_Adjustment_Field__c] = product[action.actionInfo.Product_Adjustment_Field__c];
                                                                        product.qliFields.push(action.actionInfo.Product_Adjustment_Field__c);

                                                                        // Static Source
                                                                        if (action.actionInfo.Value_Source_Type__c === 'Static') {
                                                                            
                                                                            // Set new static value
                                                                            if (action.actionInfo.Product_Adjustment_Field_Type__c === 'Boolean') {
                                                                                product[action.actionInfo.Product_Adjustment_Field__c] = action.actionInfo.Field_Value_Boolean__c;
                                                                            }
                                                                            else if (action.actionInfo.Product_Adjustment_Field_Type__c === 'Currency') {
                                                                                product[action.actionInfo.Product_Adjustment_Field__c] = this.convertCurrency(action.actionInfo.Field_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                                                                            }
                                                                            else if (action.actionInfo.Product_Adjustment_Field_Type__c === 'Date') {
                                                                                product[action.actionInfo.Product_Adjustment_Field__c] = action.actionInfo.Field_Value_Date__c;
                                                                            }
                                                                            else if (action.actionInfo.Product_Adjustment_Field_Type__c === 'Decimal') {
                                                                                product[action.actionInfo.Product_Adjustment_Field__c] = action.actionInfo.Field_Value_Decimal__c;
                                                                            }
                                                                            else if (action.actionInfo.Product_Adjustment_Field_Type__c === 'Text') {
                                                                                product[action.actionInfo.Product_Adjustment_Field__c] = action.actionInfo.Field_Value_Text__c;
                                                                            }
                                                                        }
                                                                        // Dynamic Source
                                                                        else if (action.actionInfo.Value_Source_Type__c === 'Dynamic') {
                                                                            product[action.actionInfo.Product_Adjustment_Field__c] = this.runCalculations(action.calculationItems, action.actionInfo.Calculation_Type__c, action.actionInfo.Product_Adjustment_Field_Type__c, playbooks, action.actionInfo.Numeric_Math_Operator__c, rule.contributingRecordIDs);
                                                                        }
                                                                    } else {
                                                                        if (product.prevValues.hasOwnProperty(action.actionInfo.Product_Adjustment_Field__c)) {
                                                                            product[action.actionInfo.Product_Adjustment_Field__c] = product.prevValues[action.actionInfo.Product_Adjustment_Field__c];
                                                                        }
                                                                    }

                                                                    // Reset Discount
                                                                    if (action.actionInfo.Product_Adjustment_Field__c === 'Unit_Price' ||
                                                                        action.actionInfo.Product_Adjustment_Field__c === 'List_Price'
                                                                    ) {
                                                                        if (product.List_Price !== 0) {
                                                                            product.Discount = 1 - (product.Unit_Price / product.List_Price);
                                                                        } else {
                                                                            product.Discount = 0;
                                                                        }
                                                                    }

                                                                    // Reset Unit Price
                                                                    else if (action.actionInfo.Product_Adjustment_Field__c === 'Discount') {
                                                                        product.Unit_Price = (1 - product.Discount) * product.List_Price;
                                                                    }

                                                                    // Reset prices
                                                                    product.Total_Price = product.Quantity * product.Unit_Price;
                                                                    product.Sub_Total_Price = product.Quantity * product.List_Price;

                                                                    // Evaluate Pricing
                                                                    this.evalProductPricing(product);
                                                                }
                                                                else if (action.actionInfo.Action_Type__c === 'Adjust product field editability') {
                                                                    if (
                                                                        (
                                                                            ruleEvaluation === true &&
                                                                            action.actionInfo.Field_Value_Boolean__c === true
                                                                        ) ||
                                                                        (
                                                                            ruleEvaluation === false &&
                                                                            action.actionInfo.Field_Value_Boolean__c === false
                                                                        )
                                                                    ) {
                                                                        if (!product.Adjustable_Product_Columns__c.includes(action.actionInfo.Product_Adjustment_Field__c)) {
                                                                            product.Adjustable_Product_Columns__c.push(action.actionInfo.Product_Adjustment_Field__c);
                                                                        }
                                                                    } else {
                                                                        product.Adjustable_Product_Columns__c = product.Adjustable_Product_Columns__c.filter(
                                                                            col => col !== action.actionInfo.Product_Adjustment_Field__c
                                                                        );
                                                                    }
                                                                }
                                                            }
                                                        }, this);
                                                    }
                                                }
                                            }
                                        }, this);
                                    }
                                }
                            }, this);
                        }

                        // Set lookback evaluation for next update
                        rule.ruleInfo.prevEvaluation = ruleEvaluation;

                        // Set hasHadTrueEvaluation
                        if (ruleEvaluation === true) {
                            rule.ruleInfo.hasHadTrueEvaluation = true;
                        }

                        // Set doNotEvaluate after first evaluation
                        if (rule.ruleInfo.Evaluate_When__c === 'On first evaluation') {
                            rule.ruleInfo.doNotEvaluate = true;
                        }
                    }
                }
            }, this);
        }

        return {
            playbooks: playbooks,
            changedRuleEvaluation: changedRuleEvaluation
        };
    }

    // Name Change
    nameChange(event) {
        this.quoteName = event.detail.value;
    }

    // Playbook picklist change event
    playbookChange(event) {
        this.selectedPlaybookId = event.detail.value;
        let selectedPlaybook = this.playbooks.find(p => p.playbookInfo.Id === this.selectedPlaybookId);
        this.selectedPricebook = JSON.parse(JSON.stringify(
            this.pricebooks.find(pricebook => pricebook.pricebookInfo.Id === selectedPlaybook.playbookInfo.Pricebook__c)
        ));
        this.productColumns = selectedPlaybook.productColumns;
        this.entitlementColumns = selectedPlaybook.entitlementColumns;
        if (this.selectedPricebook !== undefined &&
            this.selectedPricebook.entries !== undefined    
        ) {
            this.selectedPricebook.entries.forEach(function(pbe) {
                pbe.Manually_Addible = pbe.Manually_Addible__c;
            }, this);
        }

        // Reset approvals
        this.quoteApprovals = [];

        // Set Quote Dates
        this.updateQuoteDates(this.playbooks);

        // Run rules
        let updatedPlaybooks = this.runRules(this.playbooks);
        this.playbooks = updatedPlaybooks;

        // Evaluate approvals
        this.evaluateApprovals();

    }

    // Calculate calculation value
    runCalculations(calculationItems, calcType, answerType, playbooks, mathOp, contributingRecordIDs) {

        let calcValue;

        // Set default value
        if (answerType === 'Boolean') {
            calcValue = false;
        }
        else if (answerType === 'Currency' ||
            answerType === 'Decimal' ||
            answerType === 'Integer' ||
            answerType === 'Date'
        ) {
            calcValue = undefined;
        }
        else {
            calcValue = '';
        }
        calculationItems.forEach(function(item) {
            if (item.itemInfo.Calculation_Source__c === 'Question' &&
                item.itemInfo.CPQ_Playbook_Question__c !== undefined
            ) {

                playbooks.forEach(function(playbook) {
                    // Matching Playbook
                    if (playbook.playbookInfo.Id === this.selectedPlaybookId) {
                        playbook.questionGroups.forEach(function(group) {
                            // Matching Group
                            if (group.groupInfo.Id === item.itemInfo.CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c) {
                                group.questions.forEach(function(question) {
                                    // Matching Question
                                    if (question.questionInfo.Id === item.itemInfo.CPQ_Playbook_Question__c) { 
                                        // Record Lookup
                                        if (question.questionInfo.Answer_Type__c === 'Record Lookup') {
                                            question.questionInfo.selectedRecords?.forEach(function(record) {
                                                if (item.itemInfo.Record_Lookup_Behavior__c === 'All Records' ||
                                                    (
                                                        item.itemInfo.Record_Lookup_Behavior__c === 'Contributing Records Only' &&
                                                        contributingRecordIDs.includes(record.Id)
                                                    )
                                                ) {
                                                    calcValue = this.getCalcValue(calcType, calcValue, record[item.itemInfo.Record_Lookup_Field__c], answerType, item.itemInfo.Record_Lookup_Field_Type__c);
                                                }
                                            }, this);
                                        } else {
                                            calcValue = this.getCalcValue(calcType, calcValue, question.questionInfo.answer, answerType, question.questionInfo.Answer_Type__c);
                                        }
                                    }
                                }, this);
                            }
                        }, this);
                    }
                }, this);
            } else if (item.itemInfo.Calculation_Source__c === 'Product' &&
                item.itemInfo.Product__c !== undefined &&
                item.itemInfo.Product_Calculation_Field__c !== undefined &&
                item.itemInfo.Product_Is_Entitlement__c !== true
            ) {
                // Find associated product
                this.quoteProducts.forEach(function(product) {
                    if (product.Product2Id === item.itemInfo.Product__c &&
                        product.playbookId === this.selectedPlaybookId &&
                        (
                            item.itemInfo.Product_Calculation_Target_Rule_Action__c === undefined ||
                            product.addedByAction === item.itemInfo.Product_Calculation_Target_Rule_Action__c
                        )
                    ) {
                        let productValue;
                        // CPQ Product level
                        if (item.itemInfo.Product_Calculation_Field__c.split('.').length === 1) {
                            productValue = product[item.itemInfo.Product_Calculation_Field__c];
                        }
                        // Product2 or PricebookEntry level
                        else if (item.itemInfo.Product_Calculation_Field__c.split('.').length > 1) {
                            let obj = item.itemInfo.Product_Calculation_Field__c.split('.')[0];
                            let field = item.itemInfo.Product_Calculation_Field__c.split('.')[1];
                            // Product2
                            if (obj === 'Product2') {
                                productValue = product.Product2[field];
                            }
                            // PricebookEntry
                            else if (obj === 'PricebookEntry') {
                                productValue = product[field];
                            }
                        }

                        calcValue = this.getCalcValue(calcType, calcValue, productValue, answerType, item.itemInfo.Product_Calculation_Field_Type__c);
                    }
                }, this);
            } else if (item.itemInfo.Calculation_Source__c === 'Product' &&
                item.itemInfo.Product__c !== undefined &&
                item.itemInfo.Entitlement_Calculation_Field__c !== undefined &&
                item.itemInfo.Product_Is_Entitlement__c === true
            ) {
                // Find associated entitlement
                this.contractInfo.Contract_Entitlements__r.forEach(function(ent) {
                    if (ent.Product__c === item.itemInfo.Product__c &&
                        (
                            item.itemInfo.Product_Calculation_Target_Rule_Action__c === undefined ||
                            ent.CPQ_Playbook_Rule_Action__c === item.itemInfo.Product_Calculation_Target_Rule_Action__c
                        )
                    ) {
                        let entValue;
                        // Entitlement level
                        if (item.itemInfo.Entitlement_Calculation_Field__c.split('.').length === 1) {
                            entValue = ent[item.itemInfo.Entitlement_Calculation_Field__c];
                            if (item.itemInfo.Product_Calculation_Field_Type__c === 'Currency') {
                                entValue = this.convertCurrency(entValue, this.contractCurrency, this.oppCurrency);
                            }
                        }
                        // Product__c level
                        else if (item.itemInfo.Entitlement_Calculation_Field__c.split('.').length > 1) {
                            let obj = item.itemInfo.Entitlement_Calculation_Field__c.split('.')[0];
                            let field = item.itemInfo.Entitlement_Calculation_Field__c.split('.')[1];
                            // Product2
                            if (obj === 'Product__r') {
                                entValue = ent.Product__r[field];
                            }
                        }

                        calcValue = this.getCalcValue(calcType, calcValue, entValue, answerType, item.itemInfo.Product_Calculation_Field_Type__c);
                    }
                }, this);
            }
            else if (item.itemInfo.Calculation_Source__c === 'Current Date') {
                calcValue = this.getCalcValue(calcType, calcValue, this.convertDate(new Date()), answerType, 'Date');
            }
            else if (item.itemInfo.Calculation_Source__c === 'Static Value') {
                let staticValue;
                if (item.itemInfo.Static_Value_Type__c === 'Boolean') {
                    staticValue = item.itemInfo.Static_Value_Boolean__c;
                }
                else if (item.itemInfo.Static_Value_Type__c === 'Currency') {
                    staticValue = this.convertCurrency(item.itemInfo.Static_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                }
                else if (item.itemInfo.Static_Value_Type__c === 'Date') {
                    staticValue = item.itemInfo.Static_Value_Date__c;
                }
                else if (item.itemInfo.Static_Value_Type__c === 'Decimal') {
                    staticValue = item.itemInfo.Static_Value_Decimal__c;
                }
                else if (item.itemInfo.Static_Value_Type__c === 'Integer') {
                    staticValue = item.itemInfo.Static_Value_Integer__c;
                }
                else if (item.itemInfo.Static_Value_Type__c === 'Text') {
                    staticValue = item.itemInfo.Static_Value_Text__c;
                }
                calcValue = this.getCalcValue(calcType, calcValue, staticValue, answerType, item.itemInfo.Static_Value_Type__c);
            }
        }, this);

        // Format
        if (calcValue !== undefined) {
            if (answerType === 'Date') {
                let calcDate = new Date(calcValue);
                // UTC used since date entered in is based on UTC, not user's time zone
                let year = calcDate.getUTCFullYear().toString();
                let month = (calcDate.getUTCMonth() + 1).toString();
                if ((calcDate.getUTCMonth() + 1) < 10) {
                    month = '0' + month;
                }
                let day = calcDate.getUTCDate().toString();
                if (calcDate.getUTCDate() < 10) {
                    day = '0' + day;
                }
                calcValue = year + '-' + month + '-' + day;
            }
            else if (answerType === 'Currency' ||
                answerType === 'Decimal' ||
                answerType === 'Integer'
            ) {
                calcValue = Number(calcValue);

                if (mathOp !== undefined) {

                    // Floor
                    if (mathOp === 'Floor') {
                        calcValue = Math.floor(calcValue);
                    }
                    // Ceiling
                    else if (mathOp === 'Ceiling') {
                        calcValue = Math.ceil(calcValue);
                    }
                    // Truncate
                    else if (mathOp === 'Truncate') {
                        calcValue = Math.trunc(calcValue);
                    }
                    // Round
                    else if (mathOp === 'Round') {
                        calcValue = Math.round(calcValue);
                    }
                    // Absolute Value
                    else if (mathOp === 'Absolute Value') {
                        calcValue = Math.abs(calcValue);
                    }
                }
            }
            else {
                calcValue = String(calcValue);
            }
        }

        return calcValue;
    }

    getCalcValue(calcType, calcValue, itemValue, answerType, itemType) {
        if (calcType === 'Add') {
            if (itemValue !== undefined) {

                let newItemVal = itemValue;
                // Date
                if (itemType === 'Date') {
                    let dateVal = new Date(itemValue);
                    newItemVal = dateVal.getTime();
                }

                // First value
                if (calcValue === undefined ||
                    calcValue === '' ||
                    calcValue === null
                ) {
                    calcValue = newItemVal;
                } else {
                    calcValue += newItemVal;
                }
            }
        }
        else if (calcType === 'Subtract') {
            if (itemValue !== undefined) {

                let newItemVal = itemValue;
                // Date
                if (itemType === 'Date') {
                    let dateVal = new Date(itemValue);
                    newItemVal = dateVal.getTime();
                }

                // First value
                if (calcValue === undefined ||
                    calcValue === '' ||
                    calcValue === null
                ) {
                    calcValue = newItemVal;
                } else {
                    calcValue -= newItemVal;
                }
            }
        }
        else if (calcType === 'Multiply') {
            if (itemValue !== undefined) {

                let newItemVal = itemValue;
                // Date
                if (itemType === 'Date') {
                    let dateVal = new Date(itemValue);
                    newItemVal = dateVal.getTime();
                }

                // First value
                if (calcValue === undefined ||
                    calcValue === '' ||
                    calcValue === null
                ) {
                    calcValue = newItemVal;
                } else {
                    calcValue *= newItemVal;
                }
            }
        }
        else if (calcType === 'Divide') {
            if (itemValue !== undefined) {

                let newItemVal = itemValue;
                // Date
                if (itemType === 'Date') {
                    let dateVal = new Date(itemValue);
                    newItemVal = dateVal.getTime();
                }

                // First value
                if (calcValue === undefined ||
                    calcValue === '' ||
                    calcValue === null
                ) {
                    calcValue = newItemVal;
                } else {
                    calcValue /= newItemVal;
                }
            }
        }
        else if (calcType === 'Max') {
            if (itemValue !== undefined) {

                if (answerType === 'Date' &&
                    (
                        calcValue === undefined ||
                        new Date(itemValue) > new Date(calcValue)
                    )
                ) {
                    calcValue = itemValue;
                }
                else if (itemValue > calcValue ||
                    calcValue === undefined    
                ) {
                    calcValue = itemValue;
                }
            }
        }
        else if (calcType === 'Min') {
            if (itemValue !== undefined) {

                if (answerType === 'Date' &&
                    (
                        calcValue === undefined ||
                        new Date(itemValue) < new Date(calcValue)
                    )
                ) {
                    calcValue = itemValue;
                }
                else if (itemValue < calcValue ||
                    calcValue === undefined    
                ) {
                    calcValue = itemValue;
                }
            }
        }

        return calcValue;
    }

    // Handle rules recursion -- MAX 2 times
    runRules(playbooks) {

        // Run initial rules pass
        let result = this.evaluateRules(playbooks);

        // If a rule changed evaluation, run rules again to see if actions cause others to change evaluation
        if (result.changedRuleEvaluation === true) {
            result = this.evaluateRules(result.playbooks);
        }

        this.updateQuoteDates(result.playbooks);

        return result.playbooks;
    }

    // Remove Product event
    removeProduct(event) {
        let productToRemove = event.detail;
        let updatedProducts = this.quoteProducts.filter(
            product => product.key !== productToRemove.key
        );
        this.rekeyProducts(updatedProducts);
        // Evaluate approvals
        this.evaluateApprovals();

    }

    rekeyProducts(updatedProducts) {
        this.quoteProductKeyHelper += 1;
        updatedProducts.forEach(function(product) {
            product.key = updatedProducts.indexOf(product).toString() + '.' + this.quoteProductKeyHelper.toString()
        }, this);
        this.quoteProducts = updatedProducts;
    }

    // Save event received
    save(event) {
        const saveEvent = new CustomEvent(
            'save', {
                detail: event.detail
            });
        this.dispatchEvent(saveEvent);
    }

    // Add Prodct to quote
    addProduct(entry, actionId) {
        let prd = entry;

        // Product Name
        prd.Product_Name = entry.Product2.Name;
        
        // Quantity
        if (entry.Quantity__c !== undefined) {
            prd.Quantity = entry.Quantity__c;
        } else {
            prd.Quantity = 1;
        }

        // List Price
        prd.List_Price = this.convertCurrency(entry.UnitPrice, this.defaultCurrency, this.oppCurrency);

        // Unit Price
        prd.Unit_Price = prd.List_Price;

        // Total Price
        prd.Total_Price = prd.Unit_Price * prd.Quantity;

        // Discount
        prd.Discount = 0;

        // Prices
        prd.Total_Price = prd.Unit_Price * prd.Quantity;
        prd.Sub_Total_Price = prd.List_Price * prd.Quantity;

        // Dates
        prd.Start_Date = this.quoteStartDate;
        prd.End_Date = this.quoteEndDate;

        // Default Permissions
        prd.Adjustable_Product_Columns__c = entry.Adjustable_Product_Columns__c !== undefined ? entry.Adjustable_Product_Columns__c.split(';') : [];
        prd.Removable = entry.Removable__c;
        prd.Pricing_Set_Identifier = entry.Pricing_Set_Identifier__c;

        // Previous values obj
        prd.prevValues = {};

        // QLI Stamp Fields
        prd.qliFields = [];

        // Added by action
        prd.addedByAction = actionId; 

        // Key
        prd.key = this.quoteProducts.length.toString() + '.' + this.quoteProductKeyHelper.toString();

        // Playbook
        prd.playbookId = this.selectedPlaybookId;

        // Evaluate Pricing
        this.evalProductPricing(prd);

        let updatedProducts = JSON.parse(JSON.stringify(this.quoteProducts));
        updatedProducts.push(prd);

        this.quoteProducts = updatedProducts;
    }

    // Add Products event
    addProducts(event) {

        let productsToAdd = JSON.parse(event.detail);
        productsToAdd.forEach(function(entry) {
            this.addProduct(entry, undefined);
        }, this);

        // Run rules
        let updatedPlaybooks = this.runRules(this.playbooks);
        this.playbooks = updatedPlaybooks;

        // Evaluate approvals
        this.evaluateApprovals();
    }

    // Update Product event
    updateProduct(event) {
        let updatedProducts = JSON.parse(JSON.stringify(this.quoteProducts));
        let productToUpdate = updatedProducts.find(product => product.key === event.detail.key);
        productToUpdate[event.detail.attribute] = event.detail.newValue;

        // Reset Unit Price
        if (event.detail.attribute === 'Discount') {
            productToUpdate.Unit_Price = (1 - productToUpdate.Discount) * productToUpdate.List_Price;
        }
        else if (event.detail.attribute === 'Total_Price') {
            productToUpdate.Unit_Price = productToUpdate.Total_Price / productToUpdate.Quantity;
        } else if (event.detail.attribute === 'Sub_Total_Price') {
            productToUpdate.List_Price = productToUpdate.Sub_Total_Price / productToUpdate.Quantity;
        }

        // Reset Discount
        if (productToUpdate.List_Price !== 0) {
            productToUpdate.Discount = 1 - (productToUpdate.Unit_Price / productToUpdate.List_Price);
        } else {
            productToUpdate.Discount = 0;
        }

        // Reset total prices
        productToUpdate.Total_Price = productToUpdate.Quantity * productToUpdate.Unit_Price;
        productToUpdate.Sub_Total_Price = productToUpdate.Quantity * productToUpdate.List_Price;

        // Evaluate Pricing
        this.evalProductPricing(productToUpdate);

        this.quoteProducts = updatedProducts;

        this.updateQuoteDates(this.playbooks);

        // Run rules
        let updatedPlaybooks = this.runRules(this.playbooks);
        this.playbooks = updatedPlaybooks;

        // Evaluate approvals
        this.evaluateApprovals();
    }

    // Evaluate Product Pricing
    evalProductPricing(product) {
        if (product.Pricing_Set_Identifier !== undefined) {
            this.selectedPricebook.pricingSets?.forEach(function (pricingSet) {
                if (product.Pricing_Set_Identifier === pricingSet.Identifier__c) {
                    let newList = 0;
                    let numThresholdsMet = 0;
                    pricingSet.CPQ_Pricing_Thresholds__r?.forEach(function(pricingThreshold) {
                        if (
                            (
                                pricingThreshold.Lower_Bound__c === undefined ||
                                product[pricingSet.Tiering_Field__c] >= pricingThreshold.Lower_Bound__c
                            ) &&
                            (
                                pricingThreshold.Upper_Bound__c === undefined ||
                                product[pricingSet.Tiering_Field__c] <= pricingThreshold.Upper_Bound__c ||
                                (
                                    pricingSet.Pricing_Type__c === 'Cumulative' &&
                                    product[pricingSet.Tiering_Field__c] > pricingThreshold.Upper_Bound__c
                                )
                            ) &&
                            (
                                pricingSet.Pricing_Type__c === 'Cumulative' ||
                                numThresholdsMet === 0
                            )
                        ) {
                            if (pricingSet.Pricing_Type__c === 'Cumulative') {
                                let lowerBound = pricingThreshold.Lower_Bound__c === undefined ? 0 : pricingThreshold.Lower_Bound__c;
                                let upperBound = pricingThreshold.Upper_Bound__c === undefined ? product[pricingSet.Tiering_Field__c] : (pricingThreshold.Upper_Bound__c >= product[pricingSet.Tiering_Field__c] ? product[pricingSet.Tiering_Field__c] : pricingThreshold.Upper_Bound__c);
                                newList += (upperBound - lowerBound) * pricingThreshold.Unit_Price__c;
                            } else {
                                newList += product[pricingSet.Tiering_Field__c] * pricingThreshold.Unit_Price__c;
                            }
                            numThresholdsMet += 1;
                        }
                    }, this);
                    if (pricingSet.Tiering_Field__c === 'Quantity') {
                        product.Sub_Total_Price = newList;
                        product.List_Price = newList / product.Quantity;
                    } else {
                        product.List_Price = newList;
                        product.Sub_Total_Price = newList * product.Quantity;
                    }
                    product.Unit_Price = (1 - product.Discount) * product.List_Price;
                    product.Total_Price = product.Unit_Price * product.Quantity;
                }
            }, this);
        }
    }

    datesUpdated(event) {
        // Update products
        this.rekeyProducts(event.detail.updatedProducts);
        this.updateQuoteDates(this.playbooks);

        // Run Rules
        this.runRules(this.playbooks);

        // Evaluate approvals
        this.evaluateApprovals();
    }

    // Update Quote Start/End Dates
    updateQuoteDates(playbooks) {
        // Update Quote Dates
        let quoteEnd;
        let quoteStart;
        let quoteTerm = 12;
        this.quoteProducts.filter(product => product.playbookId === this.selectedPlaybookId).forEach(function(product) {
            if (new Date(product.End_Date) > new Date(quoteEnd) ||
                quoteEnd === undefined
            ) {
                quoteEnd = product.End_Date;
            }
            if (new Date(product.Start_Date) < new Date(quoteStart) ||
                quoteStart === undefined
            ) {
                quoteStart = product.Start_Date;
            }
        }, this);
        if (quoteStart !== undefined) {
            this.quoteStartDate = quoteStart;
        } else {
            this.quoteStartDate = this.convertDate(new Date());
        }
        if (quoteEnd !== undefined) {
            this.quoteEndDate = quoteEnd;
        } else {
            if (this.existingQuoteData.Adjustment_Type__c === 'Amendment') {
                this.quoteEndDate = this.existingQuoteData.Contract_End_Date__c;
            }
            else {
                if (this.selectedPlaybookId !== undefined &&
                    playbooks.length > 0
                ) {
                    quoteTerm = playbooks.find(playbook => playbook.playbookInfo.Id === this.selectedPlaybookId).playbookInfo.Default_Term_in_Months__c;
                }
                let monthsFuture = new Date();
                if (quoteTerm > 0) {
                    monthsFuture.setMonth(new Date().getMonth() + quoteTerm);
                    monthsFuture.setDate(monthsFuture.getDate() - 1);
                }
                this.quoteEndDate = this.convertDate(monthsFuture);
            }
        }
        quoteTerm = ((new Date(this.quoteEndDate)).getFullYear() - (new Date(this.quoteStartDate)).getFullYear()) * 12;
        quoteTerm -= (new Date(this.quoteStartDate)).getMonth();
        quoteTerm += (new Date(this.quoteEndDate)).getMonth();
        this.quoteTerm = quoteTerm;
    }

    convertCurrency(value, fromISO, toISO) {
        let rate = 1;
        if (this.currencyMap[toISO] !== undefined &&
            this.currencyMap[fromISO] !== undefined
        ) {
            rate = this.currencyMap[toISO] / this.currencyMap[fromISO]
        }
        return value * rate;
    }

    convertDate(dateValue) {
        let year = dateValue.getFullYear().toString();
        let month = (dateValue.getMonth() + 1).toString();
        if ((dateValue.getMonth() + 1) < 10) {
            month = '0' + month;
        }
        let day = dateValue.getDate().toString();
        if (dateValue.getDate() < 10) {
            day = '0' + day;
        }
        return year + '-' + month + '-' + day;
    }

    configTypeUpdate(event) {
        this.configType = event.detail;
    }
}