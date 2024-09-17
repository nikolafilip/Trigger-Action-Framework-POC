public class POC_Opportunity_Queries {
    private static POC_Opportunity_Queries instance;

    private POC_Opportunity_Queries() {}

    public static POC_Opportunity_Queries getInstance() {
        if (POC_Opportunity_Queries.instance == null) {
            POC_Opportunity_Queries.instance = new POC_Opportunity_Queries();
        }
        return POC_Opportunity_Queries.instance;
    }

    @TestVisible
    public Map<Id, Account> beforeAccountMap { get; private set; }

    public class Service implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
        public void beforeInsert(List<Opportunity> newList) {
            POC_Opportunity_Queries.getInstance().beforeAccountMap = getAccountMapFromOpportunities(
                newList
            );
        }
        public void beforeUpdate(List<Opportunity> newList, List<Opportunity> oldList) {
            POC_Opportunity_Queries.getInstance().beforeAccountMap = getAccountMapFromOpportunities(
                newList
            );
        }

        private Map<Id, Account> getAccountMapFromOpportunities(List<Opportunity> newList) {
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity myOpp : newList) {
                accountIds.add(myOpp.AccountId);
            }
            return new Map<Id, Account>([SELECT Id, BillingState FROM Account WHERE Id IN :accountIds]);
        }
    }
}