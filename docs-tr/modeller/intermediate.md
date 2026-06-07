---
icon: lucide/package-open
title: Intermediate Modeller
description: dbt intermediate modelleri dokümantasyonu
---

# Intermediate dbt Modelleri

Intermediate katmanı, temizlenmiş staging tablolarını yeniden kullanılabilir analitik yapı taşlarına dönüştürür. Projede notebooklar, Power BI dashboardları ve final mart modelleri arasında paylaşılması gereken mantık burada tanımlanır: gelir mutabakatı, TÜFE düzeltme katsayıları, ürün fiyatlaması, müşteri zenginleştirmesi ve güvenli şube join'leri.

Bu katmanın amacı yeniden kullanımdır. Aynı metriği birden fazla dashboard içinde tekrar hesaplamak yerine, proje metriği dbt'de bir kez tanımlar ve martları bu tanımın üzerine kurar.

## Temel İş Mantığı

| Alan | Model | Grain | Ana rol |
| --- | --- | --- | --- |
| Gelir | `int_order_revenue` | Sipariş başına bir satır | Sipariş başlıklarını satır toplamları, satılan adet, satır kalemi sayısı, ay/yıl/çeyrek anahtarları ve gelir mutabakatı alanlarıyla birleştirir. |
| Gelir | `int_branch_dim` | Şube başına bir satır | Şube kapsama satırlarını bölge, şehir, şube ilçesi ve kapsanan ilçe sayısı içeren güvenli bir şube boyutuna indirger. |
| Enflasyon | `int_cpi_monthly` | TÜFE ayı başına bir satır | TÜFE aylık ve yıllık değişim oranlarını, Ocak 2021 baz TÜFE'sini, enflasyon düzeltme katsayısını ve Ocak 2021 = 100 TÜFE endeksini hesaplar. |
| Ürün fiyatlaması | `int_order_line_pricing` | Fiyatlı sipariş kalemi başına bir satır | Pozitif fiyat/adet satırlarını filtreler; efektif ödenen birim fiyatı, reel ödenen birim fiyatı ve kaynak-fiyat/ödenen-fiyat farkını hesaplar. |
| Ürün fiyatlaması | `int_item_month_pricing` | Ürün/ay başına bir satır | Satır fiyatlamasını ürün-ay seviyesinde fiyat medyanları, reel fiyat medyanları, satılan adet ve satır sayısı olarak agregeler. |
| Zenginleştirme | `int_orderdetail_order_enriched` | Sipariş kalemi başına bir satır | Sipariş detaylarına sipariş tarihi, müşteri, şube, dönem alanları, sipariş adedi, ürün sayısı ve satır gelir payı ekler. |
| Zenginleştirme | `int_orderdetail_order_customer_enriched` | Sipariş kalemi başına bir satır | Müşteri profil alanlarıyla birlikte müşteri yaşı, yaşam boyu gelir, recency, tenure, aktif aylar ve sipariş sırası metriklerini ekler. |
| Zenginleştirme | `int_orderdetail_order_product_enriched` | Sipariş kalemi başına bir satır | Bölgesel ve kategori analizi için ürün kategori hiyerarşisini ve şube coğrafyasını ekler. |

`int_orderdetail_order_branch_enriched` da şube zenginleştirilmiş bir satır kalemi yardımcısı olarak mevcuttur. Rolü bölge/kategori yoluyla kısmen çakıştığı için public martlar genellikle daha hedefli şube boyutuna ve ürünle zenginleştirilmiş modellere dayanır.

## Bu Katman Neden Önemli?

- Gelir tanımları Power BI veya notebooklara ulaşmadan önce merkezileştirilir.
- TÜFE matematiği dashboard içinde hesaplanmak yerine tekrar üretilebilir ve test edilebilir hale gelir.
- Şube kapsama satırları, sipariş seviyesindeki fact'lere bağlanmadan önce güvenli bir şube boyutuna indirgenir.
- Ürün fiyatı mantığı kaynak birim fiyat ile gerçekleşen ödenen birim fiyatı ayırır; bu enflasyon hikayesini doğrulamak için önemlidir.
- Müşteri, ürün ve şube zenginleştirme modelleri farklı analiz sayfalarının aynı analitik tabanı yeniden kullanmasını sağlar.

## Doğrulama Kapsamı

Özel dbt testleri, sessiz hataların analizi maddi olarak değiştirebileceği model grafiği noktalarına odaklanır:

- TÜFE baz ay, kümülatif endeks, aylık değişim ve yıllık değişim matematiği.
- Efektif ödenen birim fiyat hesaplamaları ve pozitif fiyat filtreleri.
- Ürün-ay fiyatlama grain'i.
- Sipariş başlıkları, satır toplamları ve TÜFE'ye göre düzeltilmiş metrikler arasında aylık gelir mutabakatı.

Bu kontroller, temel matematik mart katmanına ulaşmadan önce doğrulandığı için downstream dashboardların daha güvenilir olmasını sağlar.
