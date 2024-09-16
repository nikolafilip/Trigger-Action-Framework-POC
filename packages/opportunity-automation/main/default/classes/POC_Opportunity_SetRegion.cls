public class POC_Opportunity_SetRegion implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
    public void beforeInsert(List<Opportunity> newList) {
        setRegion(newList);
    }

    public void beforeUpdate(List<Opportunity> newList, List<Opportunity> oldList) {
        setRegion(newList);
    }

    private void setRegion(List<Opportunity> newList) {
        Map<Id, Account> accountMap = POC_Opportunity_Queries.getInstance().beforeAccountMap;
        for (Opportunity opp : newList) {
            if (accountMap.containsKey(opp.AccountId)) {
                String billingState = accountMap.get(opp.AccountId).BillingState;
                if (billingState != null) {
                    if (billingState.startsWith(POC_Opportunity_Service.STATE_CA)) {
                        opp.Region__c = POC_Opportunity_Service.REGION_WEST;
                    } else if (billingState.startsWith(POC_Opportunity_Service.STATE_NY)) {
                        opp.Region__c = POC_Opportunity_Service.REGION_EAST;
                    } else {
                        opp.Region__c = POC_Opportunity_Service.REGION_CENTRAL;
                    }
                }
            }
        }
    }
}