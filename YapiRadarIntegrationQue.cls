/**
 * @description       : 
 *YapiRadarIntegrationQue yapiRadarIntegration = new YapiRadarIntegrationQue();
 *Id jobId = System.enqueueJob(yapiRadarIntegration);
 * @author            : salihcendik
 * @group             : 
 * @last modified on  : 23-10-2023
 * @last modified by  : salih.cendik
**/
public without sharing class YapiRadarIntegrationQue extends YapiRadarIntegrationBase implements Queueable, Database.AllowsCallouts
{
    @testVisible
    private static Boolean doChainJob = true;
    public Integer page = 1;

    public void execute(QueueableContext context) 
    {    
        Logger.info('YapiRadarIntegrationQue is starting...');

        try {
            ProjectRequest projectReq = new ProjectRequest();
            projectReq.page = this.page;
            String responseBody = sendRequest(projectReq);
            YapiRadarResponseParser parsedResponse = YapiRadarResponseParser.parse(responseBody);
            Integer parsedReponseValueSize = parsedResponse.value.size();
            Logger.info('response items size: '+parsedReponseValueSize + '-' + 'response body:'+responseBody);
            if (responseBody == null || parsedReponseValueSize == 0) return;

            List<Project__c> projects = createProjectRecords(parsedResponse.value);
            Logger.info('created projects size: '+projects.size());

            upsertProjects(projects);
        
            //Recursive Queue Job
            this.page++; Logger.info('page :::: '+page);
            if (doChainJob){
                YapiRadarIntegrationQue yapiRadarIntegration = new YapiRadarIntegrationQue();
                yapiRadarIntegration.page = page;
                Id jobId = System.enqueueJob(yapiRadarIntegration);
            }
        } catch (Exception e) {
            Logger.error(e.getLineNumber() + ' -> ' + e.getMessage());
        } finally {
            Logger.saveLog();
        } 
    }
}