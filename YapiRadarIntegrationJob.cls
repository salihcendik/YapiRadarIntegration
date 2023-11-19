/**
 * @description       : 
 * Sync çalıştırmak için; YapiRadarIntegrationJob.callAPI('20210322'); (String date)
 * Asyn çalıştırmak için->
 * String sch = '0 33 * * * ?'; //schedule interval time
 * system.schedule('YapiRadarIntegrationJob', sch, new YapiRadarIntegrationJob()); 
 * @author            : salihcendik
 * @group             : 
 * @last modified on  : 23-10-2023
 * @last modified by  : salih.cendik
**/
public without sharing class YapiRadarIntegrationJob extends ECZ_YapiRadarIntegrationBase implements Schedulable
{
    public String lastUpdateDate;

    public YapiRadarIntegrationJob(){ 
        this.lastUpdateDate = String.valueof(Date.today()).remove('-');
    }

    public void execute(SchedulableContext sc)
    {
        callAPI(this.lastUpdateDate);
    }

    @future(callout=true)
    public static void callAPI(String lastUpdateDate) 
    {
        Logger.info('YapiRadarIntegrationJob is starting...');

        try {
            ProjectRequest projectReq = new ProjectRequest();
            projectReq.guncellemeTarihi = lastUpdateDate;
            String responseBody = sendRequest(projectReq);
            YapiRadarResponseParser parsedResponse = YapiRadarResponseParser.parse(responseBody);
            Integer parsedReponseValueSize = parsedResponse.value.size();
            Logger.info('response items size: '+parsedReponseValueSize + '-' + 'response body:'+responseBody);
            if (responseBody == null || parsedReponseValueSize == 0) return;

            List<Project__c> projects = createProjectRecords(parsedResponse.value);
            Logger.info('created projects size :::: '+projects.size());

            upsertProjects(projects);
        } catch (Exception e) {
            Logger.error(e.getLineNumber() + ' -> ' + e.getMessage());
        } finally {
            Logger.saveLog();
        }
    }
}
