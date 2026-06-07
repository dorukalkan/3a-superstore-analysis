---
icon: lucide/arrows-up-from-line
title: Staging Modelleri
description: dbt staging modelleri dokümantasyonu
---

# Staging dbt Modelleri

Staging katmanı, ham verinin ilk modellenmiş halidir. Bu katmanın görevi kaynak tabloları daha öngörülebilir hale getirmektir: kolon adları standartlaştırılır, tip dönüşümleri yapılır, Türkçe ondalık virgül içeren para alanları parse edilir ve orijinal kaynak grain'i sonraki modelleme adımları için korunur.

Bu modeller bilinçli olarak basit tutulur. Tek başlarına iş sorularını yanıtlamazlar; intermediate ve mart katmanları için temiz girdiler oluştururlar.

## Katmanın Sorumlulukları

- Ham kaynak alanlarını analitik kullanıma daha uygun adlarla yeniden adlandırmak.
- Sipariş, müşteri, şube, ürün, tarih, para ve koordinat alanlarını doğru tiplere dönüştürmek.
- Çok erken agregasyon yapmak yerine ham iş grain'ini korumak.
- TCMB EVDS TÜFE seed'ini aylık grain'de stage etmek.
- Kimlikler, zorunlu alanlar, benzersizlik ve TÜFE geçerliliği için temel dbt testleri eklemek.

## Model Özeti

| Model | Grain | Ana rol |
| --- | --- | --- |
| `stg_orders` | Sipariş başlığı başına bir satır | Sipariş kimliklerini, şube/müşteri kimliklerini, sipariş tarihlerini, müşteri adını ve nominal sepet değerini standartlaştırır. |
| `stg_order_details` | Sipariş kalemi başına bir satır | Ürün kimliklerini, adetleri, kaynak birim fiyatları ve ödenen satır toplamlarını standartlaştırır. |
| `stg_branch` | Şube/ilçe kapsama satırı başına bir satır | Şube coğrafyasını, şube ilçelerini, kapsanan ilçeleri ve enlem/boylam değerlerini temizler. |
| `stg_raw_customers` | Müşteri başına bir satır | Noktalı virgülle ayrılmış ham müşteri kayıtlarını profil ve adres alanlarına ayrıştırır. |
| `stg_raw_categories` | Ürün kalemi başına bir satır | Ürün kategori hiyerarşisini, markayı, ürün kodunu ve ürün adını açığa çıkarır. |
| `stg_cpi_monthly` | TÜFE ayı başına bir satır | dbt seed'inden gelen aylık TCMB EVDS TÜFE endeksi değerlerini stage eder. |

## Önemli Grain Notları

`stg_orders` ve `stg_order_details` ayrı kalır çünkü farklı olguları temsil ederler: sipariş başlıkları ve sipariş kalemleri. Bu sayede sepet seviyesinde gelir ile ürün satırı seviyesinde davranış, erken bir tanıma zorlanmadan kullanılabilir.

`stg_branch` bir kapsama tablosudur, şube başına tek satırlı bir boyut değildir. Bir şube farklı kapsanan ilçeler için birden fazla kez görünebilir. Bu yüzden downstream şube fact modelleri güvenli bir şube join'i gerektiğinde `int_branch_dim` modelini kullanır.

`stg_cpi_monthly` tasarım gereği aylıktır. Sonraki gelir ve ürün fiyatlama modelleri, nominal değerleri Ocak 2021 Türk lirasına dönüştürebilmek için TÜFE'ye ay anahtarları üzerinden bağlanır.

## Downstream Kullanım

| Analiz yolu | Staging girdileri |
| --- | --- |
| Gelir ve enflasyon analizi | `stg_orders`, `stg_order_details`, `stg_cpi_monthly` |
| Ürün fiyatı ve kategori analizi | `stg_order_details`, `stg_orders`, `stg_raw_categories`, `stg_cpi_monthly` |
| Müşteri sağlığı, büyüme ve elde tutma analizi | `stg_orders`, `stg_order_details`, `stg_raw_customers` |
| Bölgesel gelir ve şube analizi | `stg_orders`, `stg_order_details`, `stg_branch`, `stg_raw_categories` |

## Doğrulama Odağı

Staging testleri, temel kimliklerin ve zorunlu alanların dolu olduğunu, beklenen benzersiz kaynak varlıklarının benzersiz kaldığını ve TÜFE değerlerinin enflasyona göre düzeltilmiş metriklerde kullanılmadan önce geçerli olduğunu kontrol eder.
