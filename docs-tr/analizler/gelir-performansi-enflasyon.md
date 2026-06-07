---
icon: lucide/turkish-lira
title: Gelir Performansı ve Enflasyon Analizi
description: Enflasyona göre düzeltilmiş reel gelir ve nominal gelir performansı
author: Doruk Alkan
---

# Gelir Performansı ve Enflasyon Analizi

!!! note "Özet"

    3A Superstore zaman içinde daha fazla Türk lirası tahsil etti, fakat reel satın alma gücü açısından daha az kazandı.

    Fiyatlar ve TÜFE keskin biçimde yükseldiği için nominal gelir daha güçlü görünüyordu. Enflasyon düzeltmesinden sonra iş hikayesi değişti: reel gelir zayıfladı; siparişler ve satılan adetler ise nominal artışı açıklayacak kadar büyüme göstermedi.

    Ana çıkarım: yüksek enflasyonlu bir pazarda nominal gelir tek başına yeterli değildir. Gelir; reel gelir, hacim ve fiyat etkisinden arındırılmış KPI'larla birlikte değerlendirilmelidir.

![Power BI Gelir Performansı Dashboard'u](../assets/revenue_dashboard.png)

Dashboard enflasyon hikayesini birkaç açıdan özetler: TÜFE trendi, nominal ve reel gelir, yıllık gelir karşılaştırması, müşteri/sipariş/adet değişimleri ve ürün seviyesinde fiyat artışları.

## İş Sorusu

Bu analiz tek bir ana soruya odaklanır:

> 3A Superstore'un geliri gerçekten büyüdü mü, yoksa nominal büyüme ağırlıklı olarak enflasyona bağlı fiyat artışlarını mı yansıttı?

Veri seti, Türkiye'deki bir market zincirini yüksek enflasyonlu bir dönem boyunca kapsar. Bu bağlamda yalnızca nominal gelire bakmak yanıltıcı olabilir. Bir işletme kasada tahsil edilen para miktarı arttığı için büyüyor gibi görünebilir; fakat bu gelirin reel satın alma gücü düşebilir.

Bu etkileri ayırmak için nominal geliri, enflasyona göre düzeltilmiş reel geliri, müşteri/sipariş/adet hacmini ve zaman içinde ürün fiyatı değişimlerini karşılaştırdım.

## Kanıtlar Ne Gösteriyor?

<div class="grid cards" markdown>

-   :lucide-trending-up:{ .lg .middle } __Nominal gelir yükseldi__

    ---

    Toplam nominal gelir analiz döneminde yaklaşık **13.11 milyar TL** seviyesine ulaştı.

-   :lucide-chart-no-axes-column-decreasing:{ .lg .middle } __Reel gelir zayıfladı__

    ---

    TÜFE düzeltmesinden sonra toplam reel gelir yaklaşık **7.87 milyar TL** oldu; bu daha zayıf bir satın alma gücü performansına işaret ediyor.

-   :lucide-shopping-basket:{ .lg .middle } __Büyümeyi hacim açıklamadı__

    ---

    Zaman içinde satılan ürün adedi ve sipariş sayısı yaklaşık **%3.6** geriledi. Müşteri tabanıysa anlamlı değişiklik göstermedi.

-   :lucide-tags:{ .lg .middle } __Fiyatlar keskin hareket etti__

    ---

    Ürün seviyesinde ödenen fiyatlar belirgin şekilde arttı; bütün ürün kategoride fiyat artışları **%100** seviyesinin üzerine çıktı.

</div>

## Yöntem

Analiz, TCMB EVDS[^evds] aylık TÜFE verisini kullanır ve dbt'de oluşturulan aylık gelir agregasyonlarına bağlar.

TÜFE serisi bir endekstir; bu yüzden orijinal 2003 bazı bu iş sorusu için doğrudan anlamlı değildir. Önemli olan TÜFE seviyeleri arasındaki orandır. Dashboard'da Ocak 2021 baz dönem olarak kullanıldı. Böylece analizin ilk ayında nominal ve reel gelir eşitlenir, ardından iki serinin zaman içinde nasıl ayrıştığı gösterilir.

```text
reel_gelir = nominal_gelir * TÜFE_baz_ay / TÜFE_cari_ay
```

Modellenen iş akışı şu yapıyı izler:

1. Ham sipariş ve sipariş detayı tablolarını temizleyip standartlaştırmak.
2. Sipariş seviyesindeki geliri aylık gelire agreglemek.
3. Aylık TÜFE metriklerini ve Ocak 2021 düzeltme katsayılarını hazırlamak.
4. Nominal geliri enflasyona göre düzeltilmiş reel gelire dönüştürmek.
5. Dashboard'a hazır gelir martları oluşturmak.
6. Gelir hikayesini hacim metrikleri ve ürün/kategori fiyat değişimleriyle doğrulamak.

??? info "Kullanılan dbt modelleri"

    - `fct_monthly_revenue`: aylık nominal gelir, reel gelir, TÜFE metrikleri, sipariş sayısı, müşteri sayısı, satılan adet ve Ocak 2021 gelir endeksleri.
    - `mart_revenue_trend_monthly`: nominal gelir, reel gelir ve TÜFE endeksi için dashboard trend tablosu.
    - `mart_revenue_story_kpis`: gelir, TÜFE, siparişler, adetler ve müşteriler için Ocak 2021-Haziran 2023 KPI karşılaştırması.
    - Ürün fiyat martları: nominal büyümenin fiyat kaynaklı olup olmadığını doğrulamak için kullanılan ödenen-fiyat trendi ve kategori fiyat hareketi tabloları.

## Sonucun Arkasındaki Kanıtlar

### Nominal gelir yükseldi, fakat reel gelir düştü

Analiz dönemi boyunca toplam nominal gelir yaklaşık 13.11 milyar TL oldu. Buna karşılık enflasyon düzeltmesinden sonra toplam reel gelir yaklaşık 7.87 milyar TL seviyesinde kaldı.

Bu, işletmenin nominal olarak daha fazla para tahsil ettiğini; fakat enflasyon hesaba katıldığında bu paranın anlamlı ölçüde daha düşük satın alma gücü temsil ettiğini gösterir.

Ana trend grafiği bunu net biçimde gösterir: nominal gelir yukarı yönlü ilerlerken, enflasyona göre düzeltilmiş gelir zaman içinde geriler. Başka bir deyişle gelir kağıt üzerinde büyür, ancak reel ekonomik değeri aşınır.

### Yüksek enflasyon geliri etkileyen önemli bir faktör olarak öne çıktı

TÜFE endeksi analiz dönemi boyunca çok sert yükseldi ve dashboard'un Ocak 2021 = 100 ölçeğinde yaklaşık 263 seviyesine ulaştı. Bu, genel fiyat seviyesinin veri setinin başlangıcına göre %160'tan fazla yükseldiği anlamına gelir.

Bu enflasyonist ortam, nominal gelirin performansı değerlendirmek için neden tek başına yeterli olmadığını açıklar. İşletme yalnızca cari fiyatlı satışları takip ederse, gelirdeki artışı gerçek iş büyümesi olarak yorumlayabilir.

### Müşteri ve sipariş hacmi gerçek iş büyümesini olumlu etkilemedi

Nominal gelir artışının gerçek iş genişlemesinden gelip gelmediğini kontrol etmek için müşteri sayısını, sipariş sayısını ve satılan adetleri karşılaştırdım.

Sonuç güçlü bir hacim büyümesiyle tutarlı değildi:

- Müşteri sayısı çoğunlukla aynı seyretti.
- Satılan adet ve sipariş sayısı yaklaşık %3.6 geriledi.

Bu, nominal gelir artışının esas olarak daha fazla müşteriden, daha fazla siparişten veya daha fazla ürün satışından kaynaklanmadığını gösterir. İşin hacim tarafı genel olarak stabil ya da biraz daha zayıftı.

### Ürün fiyatları enflasyon açıklamasını doğruladı

Ürün seviyesindeki analiz enflasyon hipotezini destekliyor. Binlerce ürün genelinde fiyatlar 3 yıllık dönem boyunca ciddi biçimde arttı.

Dashboard, ana ürün kategorilerinde ortalama fiyat artışlarının %100'ün üzerine çıktığını gösteriyor. Örneğin sıcak içecekler yaklaşık %121 ile en yüksek artışlardan birini gösterirken temizlik, meyve-sebze, bebek ürünleri ve süt ürünleri gibi kategorilerde de güçlü fiyat büyümesi görüldü.

Bu, zayıf hacim büyümesine rağmen nominal gelirin neden arttığını açıklar nitelikte: işletme ürünleri daha yüksek nominal fiyatlardan satıyordu; fakat bu yüksek fiyatlar daha güçlü reel gelire dönüşmedi. Bir diğer deyişle, enflasyon artışının gerisinde kaldı.

## İş Etkileri

!!! tip "Yönetim için çıkarımlar"

    3A Superstore'un gelir büyümesi büyük ölçüde hacim kaynaklı değil, enflasyon kaynaklıydı.

    Başka bir ifadeyle market zaman içinde daha fazla TL tahsil etti; fakat reel satın alma gücü açısından daha az kazandı.

    Yönetim yalnızca nominal geliri izlerse işletme gerçekte olduğundan daha sağlıklı görünebilir. Yüksek enflasyonlu bir pazarda reel gelir, reel ortalama sipariş değeri, hacim ve fiyat etkisinden arındırılmış KPI'lar iş performansına daha güvenilir bir bakış sağlar.

## Önerilen Aksiyonlar

Ana stratejik sonuç, gelir büyümesinin yalnızca önceki nominal satışlara göre değil, enflasyona karşı da değerlendirilmesi gerektiğidir.

Reel geliri korumak için işletmenin enflasyonun üzerinde büyüme üreten stratejilere ihtiyacı vardır:

- reel geliri ve reel ortalama sipariş değerini standart KPI olarak izlemek,
- nominal büyümeyi iş büyümesi olarak adlandırmadan önce TÜFE ile karşılaştırmak,
- müşteri retention'ını ve satın alma sıklığını iyileştirmek,
- hedefli promosyonlarla sepet değerini artırmak,
- ürün karmasını daha yüksek marjlı veya daha dayanıklı kategorilere doğru optimize etmek,
- daha zayıf bölgeleri ve şubeleri bölgesel dashboardlar üzerinden daha detaylı incelemek.

Yüksek enflasyonlu pazarlarda nominal gelir birincil başarı metriği olarak ele alınmamalıdır. Reel gelir, hacim ve fiyat etkisinden arındırılmış KPI'lar iş sağlığına daha güvenilir bir bakış sağlar.

[^evds]: TCMB EVDS, Türkiye Cumhuriyeti Merkez Bankası'nın Elektronik Veri Dağıtım Sistemi'dir. TÜFE dahil resmi ekonomik zaman serilerine erişim sağlar. API ve kullanım detayları için [EVDS portalına](https://evds3.tcmb.gov.tr) ve [EVDS dokümantasyonuna](https://evds3.tcmb.gov.tr/dokumanlar) bakılabilir.
