import { LightningElement, api} from 'lwc';

export default class CPQ_ConfigQuoteEvaluator extends LightningElement {

    // Default Currency
    @api defaultCurrency;
    // Quote Info for existing quote being edited (Empty obj if new Quote)
    @api existingQuoteData;
    // Products added to Quote
    @api quoteProducts;
    // Id of Playbook currently selected
    @api selectedPlaybookId;
    // Contract Info for contract being replaced/renewed
    @api contractInfo;
    // Currency Conversion Map
    @api currencyMap = {};
    // Contract Currency
    @api contractCurrency;
    // Opportunity Currency
    @api oppCurrency;

    // Evaluate Criteria based on current configuration
    @api evaluateCriteria(
        obj,
        playbooks,
        configType,
        defaultCurrency,
        existingQuoteData,
        quoteProducts,
        selectedPlaybookId,
        contractInfo,
        currencyMap,
        contractCurrency,
        oppCurrency
    ) {

        let evaluation = true;

        // Set group Ns
        let groupEvalN = {
            requireds: true,
            exactN_needed: 0,
            exactN_passed: 0,
            atLeastN_needed: -1,
            atLeastN_passed: 0,
            atMostN_needed: 1,
            atMostN_passed: 0,
        };

        // Selected Record Contributors
        obj.contributingRecordIDs = [];

        obj.criteriaGroups.forEach(function(criteriaGroup) {
            // Assume true
            let groupEvaluation = true;

            // Update needed Ns
            if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of N required') {
                groupEvalN.exactN_needed = criteriaGroup.groupInfo.N__c;
            }
            else if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of at least N required') {
                groupEvalN.atLeastN_needed = criteriaGroup.groupInfo.N__c;
            }
            else if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of at most N required') {
                groupEvalN.atMostN_needed = criteriaGroup.groupInfo.N__c;
            }

            // Set criteria Ns
            let criterionEvalN = {
                requireds: true,
                exactN_needed: 0,
                exactN_passed: 0,
                atLeastN_needed: -1,
                atLeastN_passed: 0,
                atMostN_needed: 1,
                atMostN_passed: 0,
            };

            // Evaluate each criterion
            criteriaGroup.criteria.forEach(function(criterion) {
                // Assume false, if no question found it remains false
                let criterionEvaluation = false;

                // Update needed Ns
                if (criterion.criterionInfo.Evaluation_Logic__c === 'One of N required') {
                    criterionEvalN.exactN_needed = criterion.criterionInfo.N__c;
                }
                else if (criterion.criterionInfo.Evaluation_Logic__c === 'One of at least N required') {
                    criterionEvalN.atLeastN_needed = criterion.criterionInfo.N__c;
                }
                else if (criterion.criterionInfo.Evaluation_Logic__c === 'One of at most N required') {
                    criterionEvalN.atMostN_needed = criterion.criterionInfo.N__c;
                }

                // Find System source that Criterion references
                if (criterion.criterionInfo.Criterion_Source__c === 'System Value' &&
                    criterion.criterionInfo.System_Value_Source__c !== undefined
                ) {
                    // Is Edit
                    if (criterion.criterionInfo.System_Value_Source__c === 'Is Edit') {
                        criterionEvaluation = ((configType === 'Edit') === criterion.criterionInfo.Comparison_Value_Boolean__c);
                    }
                    // No Contract
                    else if (criterion.criterionInfo.System_Value_Source__c === 'No Contract') {
                        criterionEvaluation = ((existingQuoteData.Adjustment_of_Contract__c === undefined) === criterion.criterionInfo.Comparison_Value_Boolean__c);
                    }
                    // Is Contract Amendment
                    else if (criterion.criterionInfo.System_Value_Source__c === 'Is Contract Amendment') {
                        criterionEvaluation = ((existingQuoteData.Adjustment_Type__c === 'Amendment') === criterion.criterionInfo.Comparison_Value_Boolean__c);
                    }
                    // Is Contract Replacement
                    else if (criterion.criterionInfo.System_Value_Source__c === 'Is Contract Replacement') {
                        criterionEvaluation = ((existingQuoteData.Adjustment_Type__c === 'Replacement') === criterion.criterionInfo.Comparison_Value_Boolean__c);
                    }
                    // Is Contract Renewal
                    else if (criterion.criterionInfo.System_Value_Source__c === 'Is Contract Renewal') {
                        criterionEvaluation = ((existingQuoteData.Adjustment_Type__c === 'Renewal') === criterion.criterionInfo.Comparison_Value_Boolean__c);
                    }
                }
                // Find Question that Criterion references
                else if (criterion.criterionInfo.Criterion_Source__c === 'Question' &&
                    criterion.criterionInfo.CPQ_Playbook_Question__c !== undefined
                ) {
                    playbooks.forEach(function(playbook) {
                        // Matching Playbook
                        if (playbook.playbookInfo.Id === selectedPlaybookId) {
                            playbook.questionGroups.forEach(function(group) {
                                // Matching Group
                                if (group.groupInfo.Id === criterion.criterionInfo.CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c) {
                                    group.questions.forEach(function(q) {
                                        // Matching Question
                                        if (q.questionInfo.Id === criterion.criterionInfo.CPQ_Playbook_Question__c) {

                                            // Current answer
                                            let sourceValues = [];
                                            if (q.questionInfo.Answer_Type__c === 'Record Lookup') {
                                                q.questionInfo.selectedRecords?.forEach(function(record) {
                                                    sourceValues.push(record[criterion.criterionInfo.Record_Lookup_Field__c]);
                                                }, this);
                                            } else {
                                                if (q.questionInfo.Answer_Type__c === 'Date' &&
                                                    q.questionInfo.answer
                                                ) {
                                                    sourceValues.push(new Date(q.questionInfo.answer));
                                                } else {
                                                    sourceValues.push(q.questionInfo.answer);
                                                }
                                            }

                                            // Comparison value
                                            let comparisonValue;
                                            if (q.questionInfo.Answer_Type__c === 'Boolean' ||
                                                (
                                                    q.questionInfo.Answer_Type__c === 'Record Lookup' &&
                                                    criterion.criterionInfo.Record_Lookup_Field_Type__c === 'Boolean'
                                                )
                                            ) {
                                                comparisonValue = criterion.criterionInfo.Comparison_Value_Boolean__c;
                                            }
                                            else if (q.questionInfo.Answer_Type__c === 'Currency' ||
                                                (
                                                    q.questionInfo.Answer_Type__c === 'Record Lookup' &&
                                                    criterion.criterionInfo.Record_Lookup_Field_Type__c === 'Currency'
                                                )
                                            ) {
                                                comparisonValue = this.convertCurrency(criterion.criterionInfo.Comparison_Value_Currency__c, defaultCurrency, oppCurrency, currencyMap);
                                            }
                                            else if (q.questionInfo.Answer_Type__c === 'Date' ||
                                                (
                                                    q.questionInfo.Answer_Type__c === 'Record Lookup' &&
                                                    criterion.criterionInfo.Record_Lookup_Field_Type__c === 'Date'
                                                )
                                            ) {
                                                if (criterion.criterionInfo.Comparison_Value_Date__c) {
                                                    comparisonValue = new Date(criterion.criterionInfo.Comparison_Value_Date__c);
                                                }
                                            }
                                            else if (q.questionInfo.Answer_Type__c === 'Decimal' ||
                                                (
                                                    q.questionInfo.Answer_Type__c === 'Record Lookup' &&
                                                    criterion.criterionInfo.Record_Lookup_Field_Type__c === 'Decimal'
                                                )
                                            ) {
                                                comparisonValue = criterion.criterionInfo.Comparison_Value_Decimal__c;
                                            }
                                            else if (q.questionInfo.Answer_Type__c === 'Integer') {
                                                comparisonValue = criterion.criterionInfo.Comparison_Value_Integer__c;
                                            }
                                            else if (q.questionInfo.Answer_Type__c === 'Picklist' ||
                                                q.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                                                q.questionInfo.Answer_Type__c === 'Text' ||
                                                q.questionInfo.Answer_Type__c === 'Text Area' ||
                                                (
                                                    q.questionInfo.Answer_Type__c === 'Record Lookup' &&
                                                    criterion.criterionInfo.Record_Lookup_Field_Type__c === 'Text'
                                                )
                                            ) {
                                                comparisonValue = criterion.criterionInfo.Comparison_Value_Text__c;
                                            }

                                            // Comparison
                                            let criterionValueEvaluations = [];
                                            sourceValues.forEach(function(val) {
                                                if (criterion.criterionInfo.Comparison_Operator__c === 'Equals') {
                                                    criterionValueEvaluations.push(val === comparisonValue);
                                                }
                                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not equal') {
                                                    criterionValueEvaluations.push(val !== comparisonValue);
                                                }
                                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than') {
                                                    criterionValueEvaluations.push(val > comparisonValue);
                                                }
                                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than or equal') {
                                                    criterionValueEvaluations.push(val >= comparisonValue);
                                                }
                                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than') {
                                                    criterionValueEvaluations.push(val < comparisonValue);
                                                }
                                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than or equal') {
                                                    criterionValueEvaluations.push(val <= comparisonValue);
                                                }
                                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Contains') {
                                                    if (val !== undefined) {
                                                        criterionValueEvaluations.push(val.includes(comparisonValue));
                                                    } else {
                                                        criterionValueEvaluations.push(false);
                                                    }
                                                }
                                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not contain') {
                                                    if (val !== undefined) {
                                                        criterionValueEvaluations.push(!val.includes(comparisonValue));
                                                    } else {
                                                        criterionValueEvaluations.push(true);
                                                    }
                                                }
                                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Is empty') {
                                                    criterionValueEvaluations.push(val === '' || val === undefined || val === null);
                                                }
                                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Is not empty') {
                                                    criterionValueEvaluations.push(!(val === '' || val === undefined || val === null));
                                                }
                                            }, this);

                                            criterionEvaluation = criterionValueEvaluations.includes(true);

                                            // Update Contributing Record IDs
                                            if (q.questionInfo.Answer_Type__c === 'Record Lookup') {
                                                for (let index = 0; index < criterionValueEvaluations.length; index++) {
                                                    if (criterionValueEvaluations[index] === true) {
                                                        obj.contributingRecordIDs.push(q.questionInfo.selectedRecords[index].Id);
                                                    }
                                                }
                                            }
                                        }
                                    }, this);
                                }
                            }, this);
                        }
                    }, this);
                }
                // Find Product that Criterion references
                else if (criterion.criterionInfo.Criterion_Source__c === 'Product' &&
                    criterion.criterionInfo.Product__c !== undefined
                ) {

                    // Entitlement
                    if (criterion.criterionInfo.Product_Is_Entitlement__c === true) {
                        contractInfo.Contract_Entitlements__r.forEach(function(ent) {
                            // Matching product
                            if (ent.Product__c === criterion.criterionInfo.Product__c &&
                                (
                                    (
                                        criterion.criterionInfo.Target_Manual_Addition_Only__c !== true &&
                                        (
                                            criterion.criterionInfo.Product_Criterion_Target_Rule_Action__c === undefined ||
                                            ent.Playbook_Rule_Action__c === criterion.criterionInfo.Product_Criterion_Target_Rule_Action__c
                                        )
                                    ) ||
                                    (
                                        criterion.criterionInfo.Target_Manual_Addition_Only__c === true &&
                                        ent.Playbook_Rule_Action__c === undefined
                                    )
                                )
                            ) {

                                // Current value
                                let value;
                                if (criterion.criterionInfo.Product_Field_Type__c === 'Date' &&
                                    ent[criterion.criterionInfo.Product_Field__c]
                                ) {
                                    value = new Date(ent[criterion.criterionInfo.Product_Field__c]);
                                } else {
                                    value = ent[criterion.criterionInfo.Product_Field__c];
                                }

                                // Comparison value
                                let comparisonValue;
                                if (criterion.criterionInfo.Product_Field_Type__c === 'Boolean') {
                                    comparisonValue = criterion.criterionInfo.Comparison_Value_Boolean__c;
                                }
                                else if (criterion.criterionInfo.Product_Field_Type__c === 'Currency') {
                                    value = this.convertCurrency(value, contractCurrency, oppCurrency, currencyMap);
                                    comparisonValue = this.convertCurrency(criterion.criterionInfo.Comparison_Value_Currency__c, defaultCurrency, oppCurrency, currencyMap);
                                }
                                else if (criterion.criterionInfo.Product_Field_Type__c === 'Date') {
                                    if (criterion.criterionInfo.Comparison_Value_Date__c) {
                                        comparisonValue = new Date(criterion.criterionInfo.Comparison_Value_Date__c);
                                    }
                                }
                                else if (criterion.criterionInfo.Product_Field_Type__c === 'Decimal') {
                                    comparisonValue = criterion.criterionInfo.Comparison_Value_Decimal__c;
                                }
                                else if (criterion.criterionInfo.Product_Field_Type__c === 'Text') {
                                    comparisonValue = criterion.criterionInfo.Comparison_Value_Text__c;
                                }

                                // Comparison
                                if (criterion.criterionInfo.Comparison_Operator__c === 'Equals') {
                                    criterionEvaluation = (value === comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not equal') {
                                    criterionEvaluation = (value !== comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than') {
                                    criterionEvaluation = (value > comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than or equal') {
                                    criterionEvaluation = (value >= comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than') {
                                    criterionEvaluation = (value < comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than or equal') {
                                    criterionEvaluation = (value <= comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Contains') {
                                    if (value !== undefined) {
                                        criterionEvaluation = (value.includes(comparisonValue));
                                    } else {
                                        criterionEvaluation = false;
                                    }
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not contain') {
                                    if (value !== undefined) {
                                        criterionEvaluation = (!value.includes(comparisonValue));
                                    } else {
                                        criterionEvaluation = false;
                                    }
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Is empty') {
                                    criterionEvaluation = (answer === '' || answer === undefined || answer === null);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Is not empty') {
                                    criterionEvaluation = !(answer === '' || answer === undefined || answer === null);
                                }
                            }
                        }, this);
                    }

                    // Quote Product
                    else {
                        quoteProducts.forEach(function(product) {
                            // Matching product
                            if (product.Product2Id === criterion.criterionInfo.Product__c &&
                                product.playbookId === selectedPlaybookId &&
                                (
                                    (
                                        criterion.criterionInfo.Target_Manual_Addition_Only__c !== true &&
                                        (
                                            criterion.criterionInfo.Product_Criterion_Target_Rule_Action__c === undefined ||
                                            product.addedByAction === criterion.criterionInfo.Product_Criterion_Target_Rule_Action__c
                                        )
                                    ) ||
                                    (
                                        criterion.criterionInfo.Target_Manual_Addition_Only__c === true &&
                                        product.addedByAction === undefined
                                    )
                                )
                            ) {

                                // Current value
                                let value;
                                if (criterion.criterionInfo.Product_Field_Type__c === 'Date' &&
                                    product[criterion.criterionInfo.Product_Field__c]
                                ) {
                                    value = new Date(product[criterion.criterionInfo.Product_Field__c]);
                                } else {
                                    value = product[criterion.criterionInfo.Product_Field__c];
                                }

                                // Comparison value
                                let comparisonValue;
                                if (criterion.criterionInfo.Product_Field_Type__c === 'Boolean') {
                                    comparisonValue = criterion.criterionInfo.Comparison_Value_Boolean__c;
                                }
                                else if (criterion.criterionInfo.Product_Field_Type__c === 'Currency') {
                                    comparisonValue = this.convertCurrency(criterion.criterionInfo.Comparison_Value_Currency__c, defaultCurrency, oppCurrency, currencyMap);
                                }
                                else if (criterion.criterionInfo.Product_Field_Type__c === 'Date') {
                                    if (criterion.criterionInfo.Comparison_Value_Date__c) {
                                        comparisonValue = new Date(criterion.criterionInfo.Comparison_Value_Date__c);
                                    }
                                }
                                else if (criterion.criterionInfo.Product_Field_Type__c === 'Decimal') {
                                    comparisonValue = criterion.criterionInfo.Comparison_Value_Decimal__c;
                                }
                                else if (criterion.criterionInfo.Product_Field_Type__c === 'Text') {
                                    comparisonValue = criterion.criterionInfo.Comparison_Value_Text__c;
                                }

                                // Comparison
                                if (criterion.criterionInfo.Comparison_Operator__c === 'Equals') {
                                    criterionEvaluation = (value === comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not equal') {
                                    criterionEvaluation = (value !== comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than') {
                                    criterionEvaluation = (value > comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than or equal') {
                                    criterionEvaluation = (value >= comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than') {
                                    criterionEvaluation = (value < comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than or equal') {
                                    criterionEvaluation = (value <= comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Contains') {
                                    if (value !== undefined) {
                                        criterionEvaluation = (value.includes(comparisonValue));
                                    } else {
                                        criterionEvaluation = false;
                                    }
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not contain') {
                                    if (value !== undefined) {
                                        criterionEvaluation = (!value.includes(comparisonValue));
                                    } else {
                                        criterionEvaluation = false;
                                    }
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Is empty') {
                                    criterionEvaluation = (answer === '' || answer === undefined || answer === null);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Is not empty') {
                                    criterionEvaluation = !(answer === '' || answer === undefined || answer === null);
                                }
                            }
                        }, this);
                    }
                }

                // Update needed Ns
                if (criterionEvaluation === true) {
                    if (criterion.criterionInfo.Evaluation_Logic__c === 'One of N required') {
                        criterionEvalN.exactN_passed += 1;
                    }
                    else if (criterion.criterionInfo.Evaluation_Logic__c === 'One of at least N required') {
                        criterionEvalN.atLeastN_passed += 1;
                    }
                    else if (criterion.criterionInfo.Evaluation_Logic__c === 'One of at most N required') {
                        criterionEvalN.atMostN_passed += 1;
                    }
                } else {
                    // Criterion required, but did not pass
                    if (criterion.criterionInfo.Evaluation_Logic__c === 'Required') {
                        criterionEvalN.requireds = false;
                    }
                }
            }, this);

            // Check group evaluation status
            // At least 1 required criterion did not pass
            if (criterionEvalN.requireds === false) {
                groupEvaluation = false;
            }
            // Mismatch of N required 
            else if (criterionEvalN.exactN_needed !== criterionEvalN.exactN_passed) {
                groupEvaluation = false;
            }
            // Mismatch of at least N required 
            else if (criterionEvalN.atLeastN_needed > criterionEvalN.atLeastN_passed) {
                groupEvaluation = false;
            }
            // Mismatch of at most N required 
            else if (criterionEvalN.atMostN_needed < criterionEvalN.atMostN_passed) {
                groupEvaluation = false;
            }

            // Update needed Ns
            if (groupEvaluation === true) {
                if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of N required') {
                    groupEvalN.exactN_passed += 1;
                }
                else if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of at least N required') {
                    groupEvalN.atLeastN_passed += 1;
                }
                else if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of at most N required') {
                    groupEvalN.atMostN_passed += 1;
                }
            } else {
                // Criterion required, but did not pass
                if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'Required') {
                    groupEvalN.requireds = false;
                }
            }
        }, this);

        // Check evaluation status
        // At least 1 required group did not pass
        if (groupEvalN.requireds === false) {
            evaluation = false;
        }
        // Mismatch of N required 
        else if (groupEvalN.exactN_needed !== groupEvalN.exactN_passed) {
            evaluation = false;
        }
        // Mismatch of at least N required 
        else if (groupEvalN.atLeastN_needed > groupEvalN.atLeastN_passed) {
            evaluation = false;
        }
        // Mismatch of at most N required 
        else if (groupEvalN.atMostN_needed < groupEvalN.atMostN_passed) {
            evaluation = false;
        }

        return evaluation;
    }

    convertCurrency(value, fromISO, toISO, currencyMap) {
        let rate = 1;
        if (currencyMap[toISO] !== undefined &&
            currencyMap[fromISO] !== undefined
        ) {
            rate = currencyMap[toISO] / currencyMap[fromISO]
        }
        return value * rate;
    }

}