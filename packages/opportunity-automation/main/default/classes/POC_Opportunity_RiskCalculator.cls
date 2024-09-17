public class POC_Opportunity_RiskCalculator implements TriggerAction.DmlFinalizer {
    private static List<Opportunity> toProcess = new List<Opportunity>();
    private List<Opportunity> currentlyProcessing;

    // Method to register Opportunities that need risk score recalculation
    public static void registerOpportunities(List<Opportunity> opportunities) {
        toProcess.addAll(opportunities);
    }

    public static List<Opportunity> getRegisteredOpportunities() {
        return new List<Opportunity>(toProcess);
    }

    // DML Finalizer logic: Enqueue the job to recalculate risk score
    public void execute(FinalizerHandler.Context context) {
        if (!toProcess.isEmpty()) {
            this.currentlyProcessing = toProcess;

            List<Id> opportunityIds = new List<Id>();
            for (Opportunity opp : toProcess) {
                opportunityIds.add(opp.Id);
            }
            System.enqueueJob(new POC_Opportunity_RiskCalculator_Queueable(opportunityIds));
            toProcess.clear();
        }
    }
}
