@isTest
public class LDTestHelperTest {
    
	@isTest static void setFlagEvalSetTrue() {
    	LDTestHelper.setFlagEval('test-flag', true);
        System.assertEquals(true, LDTestHelper.getFlagEval('test-flag'));
    }
    
	@isTest static void getFlagEvalSetFalse() {
    	LDTestHelper.setFlagEval('test-flag', false);
        System.assertEquals(false, LDTestHelper.getFlagEval('test-flag'));
    }
    
	@isTest static void getFlagEvalNotSet() {
        System.assertEquals(false, LDTestHelper.getFlagEval('test-flag'));
    }
}