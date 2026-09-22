import pandas as pd
from sqlalchemy import create_engine
# df = pd.read_csv("Online Retail.csv")
# # print(df.head())
# # print(df.info())
# # print(df.describe(include="all"))
# # print(df.isnull().sum())
# # print(df[df["Description"].isnull()])
# # Sütun adındaki özel karakteri temizleme
# df.columns = df.columns.str.replace("ï»¿", "")
# # 2. Description sütunundaki eksik değerleri silme (doğrudan df üzerinde)
# df.dropna(subset=["Description"], inplace=True)
# #CustomerID null olan satırları "Bilinmeyen Müşteri / Misafir Müşteri" olarak temsil etmek için -1 yazma
# df["CustomerID"] = df["CustomerID"].fillna(-1).astype(int)
# # print(df.isnull().sum())
# df = df[(df["Quantity"] > 0) & (df["UnitPrice"] > 0)]
# # TotalAmount sütununu hesaplayıp ekleme
# df["TotalAmount"] = df["Quantity"] * df["UnitPrice"]
# # Tarih sütununu datetime formatına çevirme
# df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])
# # 4. Genel Özeti Görme
# print(df.info())
# print("\nSatır Sayısı:", len(df))
# print("\nÖrnek Veri:\n", df.head())

# # Temizlenmiş veriyi yeni bir CSV dosyası olarak kaydet
# df.to_csv("cleaned_online_retail.csv", index=False)
# print("Temiz veri 'cleaned_online_retail.csv' adıyla başarıyla kaydedildi!")




import pandas as pd
from sqlalchemy import create_engine

# 1. Temizlenmiş CSV dosyasını okuma
df = pd.read_csv('cleaned_online_retail.csv')
# 2. MySQL Bağlantı Bilgileri (Kendi MySQL şifrenizi girin)
user = 'root'
password = 'mrttrk537275'  # MySQL şifreniz
host = 'localhost'
port = '3306'
db_name = 'retail_db'

# 3. Bağlantı motoru oluşturma
engine = create_engine(f"mysql+pymysql://{user}:{password}@{host}:{port}/{db_name}")

# 4. Veriyi MySQL'e aktarma (chunksize ile parça parça aktararak kilitlenmeyi önler)
df.to_sql(name='online_retail', con=engine, if_exists='replace', index=False, chunksize=10000)

print("Tebrikler! 'cleaned_online_retail.csv' dosyası MySQL'e başarıyla yüklendi.")