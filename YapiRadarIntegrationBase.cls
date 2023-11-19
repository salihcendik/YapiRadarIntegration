/**
 * @author            : salih.cendik
 * @last modified on  : 27-10-2023
 * @last modified by  : salih.cendik
**/
public virtual class YapiRadarIntegrationBase {

    public static final String REC_TYPE_ID = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('LeadProject').getRecordTypeId();

    public static List<Project__c> createProjectRecords(List<YapiRadarResponseParser.Value> projectItems){
        List<Project__c> projects = new List<Project__c>();

        for (YapiRadarResponseParser.Value item : projectItems) {
            Project__c newProject = new Project__c();
            newProject.recordTypeId                = REC_TYPE_ID;
            newProject.Project_Source__c           = 'Yapıradar';
            newProject.Project_Status__c           = 'Lead';
            newProject.Name                        = (item.projeAdi).left(80);
            newProject.Project_Stage__c            = item.asama;
            newProject.yr_ProjeId__c               = String.valueOf(item.projeId);
            newProject.yr_ProjectCategory__c       = item.projeKategori;
            newProject.yr_kayittarih__c            = item.yr_kayittarih;
            newProject.yr_songuncelleme__c         = item.yr_songuncelleme;
            newProject.yr_MuteahhitAdi__c          = item.muteahhitAdi;
            newProject.yr_MuteahhitYetkili__c      = item.muteahhitYetkili;
            newProject.yr_muteahhitYetkiliGorev__c = item.muteahhitYetkiliGorev;
            newProject.yr_muteahhitTelefon__c      = item.muteahhitTelefon;
            newProject.yr_muteahhitMail__c         = item.muteahhitMail;
            newProject.yr_muteahhitAdres__c        = item.muteahhitAdres;
            newProject.yr_muteahhitMahalle__c      = item.muteahhitMahalle;
            newProject.yr_muteahhitIlce__c         = item.muteahhitIlce;
            newProject.yr_muteahhitSehir__c        = item.muteahhitSehir;
            newProject.yr_yatirimciAdi__c          = item.yatirimciAdi;
            newProject.yr_yatirimciYetkili__c      = item.yatirimciYetkili;
            newProject.yr_YatirimciYetkiliGorev__c = item.yatirimciYetkiliGorev;
            newProject.yr_YatirimciTelefon__c      = item.yatirimciTelefon;
            newProject.yr_yatirimciMail__c         = item.yatirimciMail;
            newProject.yr_YatirimciAdres__c        = item.yatirimciAdres;
            newProject.yr_ProjeUlke__c             = item.projeUlke;
            newProject.yr_ProjeSehir__c            = item.projeSehir;
            newProject.City__c                     = cropCity(item.projeSehir);
            newProject.yr_ProjeIlce__c             = item.projeIlce;
            newProject.yr_ProjeMahalle__c          = item.projeMahalle;
            newProject.yr_ProjeCaddeSokak__c       = item.projeCaddeSokak;
            newProject.yr_DaireSayisi__c           = item.daireSayisi;
            newProject.yr_BlokSayisi__c            = item.blokSayisi;
            newProject.yr_ProjeBedeli__c           = item.projeBedeli;
            newProject.yr_BaslangicYilCeyrek__c    = item.baslangicYilCeyrek;
            newProject.yr_BitisYilCeyrek__c        = item.bitisYilCeyrek;
            newProject.yr_ProjeIslemDurumu__c      = item.projeIslemDurumu;
            newProject.yr_ProjeYetkili__c          = item.projeYetkili;
            newProject.yr_YetkiliGorev__c          = item.yetkiliGorev;
            newProject.yr_YetkiliTelefon__c        = item.yetkiliTelefon;
            newProject.yr_YetkiliMail__c           = item.yetkiliMail;
            projects.add(newProject);
        }
        
        if (!projects.isEmpty()) {
            setLocationAndOwner(projects);
        }
        
        return projects;
    }

    public static void setLocationAndOwner(List<Project__c> projects) {
        Map<String, Definition2__c> districtMap = getDefinations(projects);
        if (districtMap.isEmpty()) return;
        for (Project__c project : projects) {
            Definition2__c def = districtMap.get(project.yr_ProjeIlce__c);
            project.District__c = def?.Id;
            project.State__c = def?.State__r.Id;
            project.Publicgroup__c = getPublicGroup(def);
        }
        assingOwner(projects);
    }

    public static String getPublicGroup(Definition2__c defination){
        String publicGroup;
        String publicGroupFromDistrict = defination?.Publicgroup__c;
        String publicGroupFromState = defination?.State__r?.Publicgroup__c;
        if (String.isNotBlank(publicGroupFromDistrict)){
            publicGroup = publicGroupFromDistrict;
        }else if(String.isNotBlank(publicGroupFromState)){
            publicGroup = publicGroupFromState;
        }else {
            publicGroup = 'Toplu_Is';
        }
        return publicGroup;
    }

    public static void assingOwner(List<Project__c> projects) {
        Set<String> publicGroups = new Set<String>();
        for (Project__c project : projects) {
            publicGroups.add(project.Publicgroup__c);
        }
        if (publicGroups.isEmpty()) return;

        Map<String, String> publicGroupToOwner = new Map<String, String>();
        for (User usr : [SELECT Id, Username FROM User WHERE Username IN :publicGroups]){
            publicGroupToOwner.put(usr.Username, usr.Id);
        }

        if (publicGroups.size() != publicGroupToOwner.size()) {
            List<Group> groups = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :publicGroups AND  DeveloperName NOT IN :publicGroupToOwner.keySet()];
            for (Group groupItem : groups) {
                publicGroupToOwner.put(groupItem.DeveloperName, groupItem.Id);
            }
        }
        for (Project__c project : projects) {
            if (publicGroupToOwner.containsKey(project.Publicgroup__c)) {
                project.OwnerId = publicGroupToOwner.get(project.Publicgroup__c);
            }
        }    
    }

    public static Map<String, Definition2__c> getDefinations(List<Project__c> projects){
        Set<String> likeDisricts = new Set<String>();
        for (Project__c project : projects) {
            likeDisricts.add('%' + project.yr_ProjeIlce__c + '%');
        }
        
        Map<String, Definition2__c> districtMap = new Map<String, Definition2__c>();
        if (likeDisricts.isEmpty()) return districtMap;

        List<Definition2__c> definations = [SELECT Id, Name, Publicgroup__c, State__r.Id, State__r.Publicgroup__c 
        FROM Definition2__c WHERE Name LIKE :likeDisricts AND RecordType.DeveloperName = 'District'];
        for (Definition2__c def : definations) {
            String defName = def.Name;
            if (defName.contains('-')) {
                defName = defName.substringAfter('-').trim();
            }
            districtMap.put(defName, def);
        }
        return districtMap;
    }

    public static String cropCity(String dataOfCity){
        //İstanbul - Anadolu ifadesinden "İstanbul" ayırmak için.
        if (dataOfCity == null || (dataOfCity!=null && !dataOfCity.contains('-'))) {
            return dataOfCity;
        }
        return dataOfCity.substringBefore('-').trim();
    }

    public static void upsertProjects(List<Project__c> projectsToUpsert){
        if(projectsToUpsert.isEmpty()) return;
        Schema.SObjectField projectId = Project__c.yr_ProjeId__c; 
        Database.UpsertResult[] results = database.upsert(projectsToUpsert, projectId, false);
        generateErrorLogs(projectsToUpsert, results);
    }

    public static void generateErrorLogs(List<Project__c> projectsToUpsert, List<Database.UpsertResult> results){
        List<String> errors = new List<String>();
        for (Integer i = 0; i < results.size(); i++) {
            if (!results.get(i).isSuccess()) {
                errors.add('Record which got error : ' + projectsToUpsert.get(i));
                for(Database.Error err : results.get(i).getErrors()) {
                errors.add(err.getStatusCode() + ': ' + err.getMessage() + ' Fields that affected this error: ' + err.getFields());
                }
                errors.add('-------------------------------');
            }
        }
        if(!errors.isEmpty()) {
            System.debug('Error count : ' + errors.size() / 3);
            System.debug(String.join(errors, '\n'));
        }
    }

    public static String sendRequest(ProjectRequest request){
        Logger.info('ECZ_YapiRadarIntegration is sending request...');
        String accessToken = getAccessToken();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getApiEndpoint(request)); 
        req.setMethod('POST'); 
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.SetHeader('Content-Type','application/json');   
        req.setBody(JSON.serialize(request));
        HttpResponse response = http.send(req);
        return response.getBody();
    }

    public static String getAccessToken() {
        Http tokenHttp = new Http();
        HttpRequest tokenReq = new HttpRequest();
        tokenReq.setEndpoint('callout:YAPIRADAR/api/Auth/login'); 
        tokenReq.setMethod('POST'); 
        tokenReq.SetHeader('Content-Type','application/json');   
        tokenReq.setBody(JSON.serialize(new Map<String, Object> {'eposta' => '{!$Credential.Username}', 'sifre' => '{!$Credential.Password}'}));
        HttpResponse tokenRes = tokenHttp.send(tokenReq);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(tokenRes.getBody());
        String accessToken = (String) results.get('token');
        return accessToken;
    }

    public static String getApiEndpoint(ProjectRequest request) {
        if (request.page != null) {
            return Definitions__mdt.getInstance('YapiRadar_AllListFilterByPage').API_Endpoint__c;
        }else{
            return Definitions__mdt.getInstance('YapiRadar_AllListFilter').API_Endpoint__c;
        }
    }

    public class ProjectRequest{
        public String guncellemeTarihi;
        public Integer page;
    }
}