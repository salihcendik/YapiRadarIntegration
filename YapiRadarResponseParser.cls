/**
 * @description       : 
 * @author            : salihcendik
 * @group             : 
 * @last modified on  : 05-10-2023
 * @last modified by  : salih.cendik
**/
public class YapiRadarResponseParser {
    public List<Value> value;

	public class Value {
		public Integer projeId;
		public String projeAdi;
		public String projeTuru;
		public String projeKategori;
		public String yr_kayittarih;
		public String yr_songuncelleme;
		public String muteahhitAdi;
		public String muteahhitYetkili;
		public String muteahhitYetkiliGorev;
		public String muteahhitTelefon;
		public String muteahhitMail;
		public String muteahhitAdres;
		public String muteahhitMahalle;
		public String muteahhitIlce;
		public String muteahhitSehir;
		public String yatirimciAdi;
		public String yatirimciYetkili;
		public String yatirimciYetkiliGorev;
		public String yatirimciTelefon;
		public String yatirimciMail;
		public String yatirimciAdres;
		public String yatirimciMahalle;
		public String yatirimciIlce;
		public String yatirimciSehir;
		public String asama;
		public String projeUlke;
		public String projeSehir;
		public String projeIlce;
		public String projeMahalle;
		public String projeCaddeSokak;
		public String projeYetkili;
		public String yetkiliGorev;
		public String yetkiliTelefon;
		public String yetkiliMail;
		public String daireSayisi;
		public String blokSayisi;
		public String projeBedeli;
		public String baslangicYilCeyrek;
		public String bitisYilCeyrek;
		public String mekanikProjeAdi;
		public String mekanikProjeYetkili;
		public String mekanikProjeYetkiliGorev;
		public String mekanikProjeTelefon;
		public String mekanikProjeMail;
		public String mekanikProjeAdres;
		public String mekanikProjeMahalle;
		public String mekanikProjeIlce;
		public String mekanikProjeSehir;
		public String projeIslemDurumu;
	}

	
	public static YapiRadarResponseParser parse(String json) {
		return (YapiRadarResponseParser) System.JSON.deserialize(json, YapiRadarResponseParser.class);
	}
}