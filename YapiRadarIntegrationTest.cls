/**
 * @author            : salihcendik
 * @last modified on  : 30-10-2023
 * @last modified by  : salih.cendik
**/
@IsTest
public class YapiRadarIntegrationTest {
    private static final String jsonBody = '{"value":[{"projeId":52,"projeAdi":"Merkez Mahallesi Konut Projesi","projeTuru":"Özel Sektör","projeKategori":"Konut /","projeIslemDurumu": "Proje İptal","yr_kayittarih":"02.07.2018","yr_songuncelleme":"22.03.2021","muteahhitAdi":"Ergüney Turizm San.Tic.Ltd.Şti.","muteahhitYetkili":"Cüneyt Ergüney","muteahhitYetkiliGorev":"Firma Sahibi","muteahhitTelefon":"+905322816483","muteahhitMail":"info@erguney.com.tr","muteahhitAdres":"Çavuşbaşı Cad. 19/A","muteahhitMahalle":"Merkez","muteahhitIlce":"Çekmeköy","muteahhitSehir":"İstanbul - Anadolu","yatirimciAdi":"","yatirimciYetkili":null,"yatirimciYetkiliGorev":null,"yatirimciTelefon":null,"yatirimciMail":"","yatirimciAdres":"","yatirimciMahalle":null,"yatirimciIlce":null,"yatirimciSehir":null,"asama":"Proje","projeUlke":"Türkiye","projeSehir":"İstanbul - Anadolu","projeIlce":"Çekmeköy","projeMahalle":null,"projeCaddeSokak":"Ataman Sok.","projeYetkili":"Cüneyt Ergüney","yetkiliGorev":"Firma Sahibi","yetkiliTelefon":"","yetkiliMail":"-","daireSayisi":"24","blokSayisi":"0","projeBedeli":"350000","baslangicYilCeyrek":"20211","bitisYilCeyrek":"20221","mekanikProjeAdi":"","mekanikProjeYetkili":null,"mekanikProjeYetkiliGorev":null,"mekanikProjeTelefon":null,"mekanikProjeMail":"","mekanikProjeAdres":"","mekanikProjeMahalle":null,"mekanikProjeIlce":null,"mekanikProjeSehir":null}]}';

    @testSetup
    private static void testSetup() {
        Definition2__c state = new Definition2__c(
            RecordTypeId =  Schema.sObjectType.Definition2__c.getRecordTypeInfosByDeveloperName().get('State').getRecordTypeId(),
            Name = 'İstanbul',
            Country__c = 'TR',
            Publicgroup__c = 'Toplu_Is',
            SAPCode__c = 'TR34',
            SAP_Number__c = '34',
            Status__c = 'Active');
        insert state;
        
        Definition2__c district = new Definition2__c(
            RecordTypeId =  Schema.sObjectType.Definition2__c.getRecordTypeInfosByDeveloperName().get('District').getRecordTypeId(),
            Name = 'İstanbul - Çekmeköy',
            Country__c = 'TR',
            Publicgroup__c = 'Toplu_Is',
            SAPCode__c = '34-214',
            SAP_Number__c = '342-14',
            State__c = state.Id,
            Status__c = 'Active');
        insert district;
    }

    @IsTest
    static void yapiRadarIntegrationJobTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockUtil(jsonBody, 200));
        new YapiRadarIntegrationJob().execute(null);
        Test.stopTest();
        Assert.areEqual(1, [SELECT Id FROM Project__c].size(), 'Project size must be 1');
    }
    
    @IsTest
    static void yapiRadarIntegrationQueTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockUtil(jsonBody, 200));
        System.enqueueJob(new YapiRadarIntegrationQue());
        Test.stopTest();
        Assert.areEqual(1, [SELECT Id FROM Project__c].size(), 'Project size must be 1');
    }
}