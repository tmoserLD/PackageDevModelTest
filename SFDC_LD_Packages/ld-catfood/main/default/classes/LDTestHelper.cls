public class LDTestHelper {

    public static Map<String, Boolean> flagEvalMap = new Map<String, Boolean>();

    public static void setFlagEval(String flagKey, Boolean evalValue) {
        flagEvalMap.put(flagKey, evalValue);
    }

    public static Boolean getFlagEval(String flagKey) {
        return flagEvalMap.containsKey(flagKey) ? flagEvalMap.get(flagKey) : false;
    }
}