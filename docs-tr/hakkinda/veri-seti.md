---
icon: lucide/database
---

# Veri Seti

Bu proje, Kaggle kullanıcısı `cemeraan` tarafından yayımlanan [3A Superstore (Market Orders Data-CRM)](https://www.kaggle.com/datasets/cemeraan/3a-superstore) veri setini kullanır.

Veri seti büyük bir perakende market ortamını; sipariş, müşteri, şube ve ürün kategorisi verileriyle temsil eder. Hem işlem seviyesinde satış kayıtları hem de bu satışları müşteri, coğrafya, ürün ve zaman boyutlarıyla açıklamaya yarayan referans tabloları içerdiği için iş analitiği açısından güçlü bir yapı sunar.

## İçerik

Projede beş ana ham tablo kullanıldı:

| Tablo | Analizdeki rolü |
| --- | --- |
| `orders` | Sipariş tarihi, şube, müşteri ve toplam sepet değeri gibi sipariş başlığı bilgileri. |
| `order_details` | Ürün kimliği, adet, birim fiyat ve satır toplamı gibi sipariş kalemleri. |
| `customers` | CRM, elde tutma ve segmentasyon analizlerinde kullanılan müşteri özellikleri. |
| `branch` | Bölge, şehir, ilçe ve koordinatlar dahil mağaza ve coğrafi kapsama verisi. |
| `categories` | Marka ve çok seviyeli ürün kategori hiyerarşisi dahil ürün metadatası. |

BigQuery ve dbt akışımızda bu tablolar staging modellerinde temizlendi, intermediate modellerinde analitik olarak zenginleştirildi ve gelir, enflasyon, ürün fiyatlaması, şube performansı, müşteri analizi ve dashboard raporlaması için martlara dönüştürüldü.

## Nasıl Kullandık?

Veri seti birkaç iş sorusunu destekler:

- Gelir zaman içinde nasıl değişti?
- Nominal gelir artışı gerçek iş büyümesini mi yansıttı, yoksa ağırlıklı olarak enflasyondan mı kaynaklandı?
- Hangi bölgeler, şubeler ve kategoriler satışlara en çok katkı verdi?
- Ürün fiyatları analiz dönemi boyunca nasıl değişti?
- Hangi müşteri ve sepet örüntüleri CRM veya çapraz satış analizi için kullanılabilir?

Satış verisi yüksek enflasyon döneminde Türk lirası cinsinden olduğu için Kaggle veri setini TCMB EVDS aylık TÜFE verisiyle destekledik.[^evds] Böylece yalnızca cari fiyatlı satış toplamlarına bakmak yerine nominal geliri enflasyona göre düzeltilmiş reel gelirle karşılaştırabildik.

## Atıf

Veri seti kaynağı:

> Cem Erağan (`cemeraan`). [3A Superstore (Market Orders Data-CRM)](https://www.kaggle.com/datasets/cemeraan/3a-superstore). Kaggle.

Kaggle veri seti, bu projede kullanılan market işlem ve referans verilerinin kaynağıdır. Enflasyon düzeltmesinde kullanılan TÜFE verisi ayrı olarak `evds_cpi_monthly` dbt seed'i içinde ele alınır.

[^evds]: TCMB EVDS, Türkiye Cumhuriyet Merkez Bankası'nın Elektronik Veri Dağıtım Sistemi'dir. TÜFE dahil resmi ekonomik zaman serilerine erişim sağlar. API ve kullanım detayları için [EVDS portalına](https://evds3.tcmb.gov.tr) ve [EVDS dokümantasyonuna](https://evds3.tcmb.gov.tr/dokumanlar) bakılabilir.
