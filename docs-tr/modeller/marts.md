---
icon: lucide/package-search
title: Analitik Martlar
description: dbt mart modelleri dokümantasyonu
---

# Analize Hazır dbt Martları

Mart katmanı, Power BI dashboardları, notebooklar ve proje yazısı tarafından kullanılan final tabloları içerir. Bu modeller iş soruları etrafında şekillenir: aylık gelir performansı, enflasyona göre düzeltilmiş metrikler, ürün fiyat değişimleri, bölgesel katkı, kategori dağılımı, müşteri sağlığı ve elde tutma.

Intermediate katmanıyla karşılaştırıldığında martlar dashboard sözleşmelerine daha yakındır. Analiz sayfalarıyla uyumlu stabil grain'ler, adlandırılmış metrikler ve filtrelenmiş dönem pencereleri sunarlar.

## Gelir ve Enflasyon Martları

| Model | Grain | Ana rol |
| --- | --- | --- |
| `fct_monthly_revenue` | Satış ayı başına bir satır | Aylık nominal gelir, Ocak 2021 TRY cinsinden reel gelir, TÜFE metrikleri, sipariş sayısı, müşteri sayısı, satılan adet, ortalama sipariş değeri ve Ocak 2021 gelir endeksleri. |
| `mart_revenue_trend_monthly` | Ocak 2021-Haziran 2023 arasında ay başına bir satır | Nominal gelir, reel gelir ve TÜFE endeksi çizgileri için sade dashboard trend tablosu. |
| `mart_revenue_story_kpis` | KPI metriği başına bir satır | Gelir, TÜFE, siparişler, adetler ve müşteriler için Ocak 2021 ile Haziran 2023'ü karşılaştırır. |

Bu martlar [Gelir Performansı ve Enflasyon Analizi](../analizler/gelir-performansi-enflasyon.md) sayfasını destekler. Merkezi karşılaştırmayı açık hale getirirler: nominal gelir yükselirken reel gelir, hacim ve satın alma gücüne göre düzeltilmiş metrikler daha zayıf bir iş hikayesi anlatabilir.

## Ürün Fiyat Martları

| Model | Grain | Ana rol |
| --- | --- | --- |
| `mart_product_price_trend_monthly` | Ay başına bir satır | Portföy seviyesinde ödenen fiyat medyanları, reel fiyat medyanları, kaynak fiyat tanıları ve Ocak 2021 fiyat endeksleri. |
| `mart_product_price_story_kpis` | Bir satır | Ocak 2021 ile Haziran 2023 ürün fiyat hareketini ve uygun ürün kapsamını karşılaştıran dönem KPI tablosu. |
| `mart_product_category_price_trend_monthly` | Kategori/ay başına bir satır | Ocak 2021'den beri efektif ödenen fiyat artışına göre kategori seviyesinde fiyat trendi ve sıralama. |
| `mart_product_category_price_increase_bar` | Üst seviye kategori başına bir satır | Ocak 2021'den beri kategori fiyat artışları için Haziran 2023 bar-chart martı. |

Bu martlar nominal gelir artışının gerçek hacim büyümesiyle mi, yoksa gerçekleşen fiyatların yükselmesiyle mi desteklendiğini doğrular. Ayrıca kategori sayfalarına yalnızca ham gelir toplamlarına dayanmak yerine yeniden kullanılabilir bir fiyat değişimi görünümü sağlarlar.

## Şube ve Bölgesel Martlar

| Model | Grain | Ana rol |
| --- | --- | --- |
| `fct_daily_branch_revenue` | Şube/tarih başına bir satır | Günlük şube geliri, sipariş sayısı, müşteri sayısı, satılan adet, ortalama sipariş değeri, bölge, şehir ve şube ilçesi. |
| `mart_category_region_distribution` | Bölge/şehir/kategori kombinasyonu başına bir satır | Siparişler, benzersiz ürünler, adet, gelir ve ortalama sepet değeri için bölgesel ve kategori katkısı metrikleri. |

Bu tablolar bölgesel gelir analizini ve kategori dağılımı görünümlerini destekler. Coğrafi ve kategori raporlamasını iş açısından okunabilir bir grain'de tutarken sipariş kalemi verisine kadar izlenebilirliği korurlar.

## Müşteri Martları

| Model | Grain | Ana rol |
| --- | --- | --- |
| `mart_customer_360` | Müşteri başına bir satır | Müşteri yaşam boyu geliri, toplam sipariş, tenure, recency, aktif aylar, ortalama sipariş değeri, ortalama sepet adedi, tekrar eden/yüksek değerli müşteri bayrakları, değer segmenti ve yaşam döngüsü aşaması. |
| `mart_customer_rfm` | Müşteri başına bir satır | RFM quintile skorları, birleşik RFM skoru, toplam skor ve Champions, Loyal Customers, At Risk, Potential Loyalist gibi segment etiketleri. |

Bu martlar müşteri sağlığı, elde tutma ve büyüme analizlerini destekler. İşlem geçmişini elde tutma önceliklendirmesi, müşteri değer segmentasyonu ve churn riski yorumlamasında kullanılabilecek müşteri seviyesinde sinyallere dönüştürürler.

## Dashboard ve Analiz Eşlemesi

| Analiz alanı | Birincil martlar |
| --- | --- |
| Enflasyona göre düzeltilmiş gelir | `fct_monthly_revenue`, `mart_revenue_trend_monthly`, `mart_revenue_story_kpis`, ürün fiyat martları |
| Satış ve gelir içgörüleri | `fct_monthly_revenue`, `fct_daily_branch_revenue` |
| Müşteri büyüme fırsatları | `mart_customer_360`, `mart_customer_rfm`, zenginleştirilmiş sipariş/ürün modelleri |
| Müşteri sağlığı ve elde tutma | `mart_customer_360`, `mart_customer_rfm` |
| Bölgesel gelir ve kategori performansı | `fct_daily_branch_revenue`, `mart_category_region_distribution` |
| Kategori trendleri ve fiyat hareketi | `mart_category_region_distribution`, `mart_product_category_price_trend_monthly`, `mart_product_category_price_increase_bar` |

## Testler ve Güven

Mart katmanı; gelir mutabakatı, reel gelir matematiği, TÜFE senaryo davranışı, baz endeks mantığı, dönem pencereleri, KPI hesaplaması, ürün fiyat grain'i ve kategori fiyat uygunluğu için özel testlerle korunur. Bu testler özellikle önemlidir çünkü mart tabloları dashboardların ve proje yazılarının tükettiği tanımları oluşturur.
