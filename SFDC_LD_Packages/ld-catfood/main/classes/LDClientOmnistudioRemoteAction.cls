// Example of how LaunchDarkly can be used in Omnistudio via an Apex Remote Action
// Becuase Omnistudio is a paid add-on, it can only be included in the package if Omnistudio exists in the SFDC org

global class LDClientOmnistudioRemoteAction implements System.Callable, omnistudio.VlocityOpenInterface2 {

    public Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outputMap, Map<String,Object> optionsMap) {
        if (methodName.equalsIgnoreCase('getVariation')) {
            LDClient client = new LDClient();
            LDUser user = new LDUser.Builder(System.UserInfo.getUserId())
                .setName(System.UserInfo.getName())
                .build();
            if (optionsMap.containsKey('variationType')) {
                switch on ((String) optionsMap.get('variationType')).toLowerCase() {
                    when 'boolean' {
                        outputMap.put('boolVariation', client.boolVariation(user, (String) optionsMap.get('flagKey'), optionsMap.containsKey('defaultBoolVariation') ? Boolean.valueOf((String) optionsMap.get('defaultBoolVariation')) : false));
                    }
                    when 'integer' {
                        outputMap.put('intVariation', client.intVariation(user, (String) optionsMap.get('flagKey'), optionsMap.containsKey('defaultIntVariation') ? Integer.valueOf((String) optionsMap.get('defaultIntVariation')) : null));
                    }
                    when 'double' {
                        outputMap.put('doubleVariation', client.doubleVariation(user, (String) optionsMap.get('flagKey'), optionsMap.containsKey('defaultDoubleVariation') ? Double.valueOf((String) optionsMap.get('defaultDoubleVariation')) : null));
                    }
                    when 'string' {
                        outputMap.put('stringVariation', client.stringVariation(user, (String) optionsMap.get('flagKey'), optionsMap.containsKey('defaultStringVariation') ? (String) optionsMap.get('stringVariation') : null));
                    }
                    when else {
                    }
                }
            }
        }
        
        return true;
    }

    public Object call(String action, Map<String, Object> args) {
        return invokeMethod(action, (Map<String, Object>) args.get('input'), (Map<String, Object>) args.get('output'), (Map<String, Object>) args.get('options'));
    }
}