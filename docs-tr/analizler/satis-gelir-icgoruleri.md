---
icon: lucide/shopping-cart
title: Satış ve Gelir İçgörüleri
description: Satış ve gelir analizi
author: Ebubekir Tilbaç
---

# Satış ve Gelir İçgörüleri

!!! note "Özet"

    Satış aktivitesi yıl içinde düz bir çizgi izlemiyor. Sipariş hacmi ilk yarıda görece stabilken yaz sonrasında sert biçimde düşüyor.

    Gelir ana tarihsel dönem boyunca güçlü bir yukarı trend gösteriyor; ancak son görünür düşüş dikkatli yorumlanmalı çünkü bu, kesin bir iş çöküşünden ziyade eksik veya daha az güvenilir dönem kapsamını yansıtıyor olabilir.

    Şehir tahmini, büyük metropol pazarlarının ana gelir tabanı olmaya devam ettiğini gösteriyor. Bu yüzden bölgesel planlama, yüksek katkılı şehirleri korurken daha zayıf pazarları incelemeye odaklanmalıdır.

![Power BI Dashboard](../assets/Sales_Revenue_Insights.png)

Dashboard, tarihsel satış örüntülerini şehir seviyesinde gelir tahminiyle birleştirir. Gelirin nerede yoğunlaştığını, sipariş aktivitesinin zaman içinde nasıl değiştiğini ve gelecekteki satış planlamasında hangi şehirlerin önemli kalmasının beklendiğini yanıtlamaya yardımcı olur.

## İş Sorusu

Bu analiz pratik bir planlama sorusuna odaklanır:

> Satışlar ve gelir zaman içinde nasıl hareket ediyor, gelecekteki geliri hangi şehirlerin sürüklemesi bekleniyor?

Yanıt için aylık sipariş davranışı, dönem bazında gelir trendi ve tahmin edilen şehir seviyesinde gelir payları incelendi.

## Kanıtlar Ne Gösteriyor?

<div class="grid cards" markdown>

-   :lucide-calendar-days:{ .lg .middle } __Siparişler yazdan sonra zayıflıyor__

    ---

    Aylık sipariş hacmi yılın başında 1.0M seviyesine yakınken Ağustos sonrasında sert biçimde düşüyor.

-   :lucide-trending-up:{ .lg .middle } __Gelir ana dönemde büyüyor__

    ---

    Gelir 2021'de yaklaşık **0.79 milyar** seviyesinden sonraki dönemde **1.5 milyar** üzerindeki zirvelere çıkıyor.

-   :lucide-map-pin:{ .lg .middle } __Şehir geliri yoğunlaşmış durumda__

    ---

    İstanbul en büyük tahmini payı taşıyor; Ankara ve İzmir de önemli katkıcılar olarak kalıyor.

-   :lucide-line-chart:{ .lg .middle } __Tahminler planlamayı destekliyor__

    ---

    Prophet tahmini, bölgesel planlama ve kaynak dağılımı için şehir gelir karmasına yön gösteren bir bakış sağlar.

</div>

## Yöntem

Tarihsel trend analizi, temizlenmiş şube coğrafyasına bağlanan sipariş seviyesinde gelire dayanır. SQL mantığı yıl, ay, hafta içi/hafta sonu, sezon, şube bölgesi, şube şehri, toplam sipariş, toplam gelir ve ortalama sepet değeri gibi zaman ve lokasyon alanlarını üretir.

Tahmin çalışması şube tahmini notebook'unu kullanır. En yüksek gelirli şehirleri seçer, modellemeden önce eksik dönemleri çıkarır, her şehir için Prophet modeli kurar, Türkiye tatillerini dahil eder ve tahmin edilen şehir gelirini dashboard kullanımı için BigQuery'ye geri yazar.

??? info "Analiz girdileri"

    - `queries/time_trends.sql`: ay, sezon, hafta içi/hafta sonu, bölge, şehir, sipariş sayısı, gelir ve ortalama sepet değeri içeren zaman trendi veri setini oluşturur.
    - `notebooks/branch_forecast_and_recommendation_system.ipynb`: en yüksek gelirli şehirler için şehir seviyesinde Prophet tahminleri kurar ve BigQuery için tahmin çıktısını hazırlar.
    - `prophet_branch_forecasts`: tahmini şehir geliri görünümlerinde kullanılan tahmin çıktı tablosu.

Tahmin garanti bir öngörü değil, planlama desteği olarak okunmalıdır. Bölgesel planlama için yön gösterici şekilde faydalıdır; ancak daha fazla doğrulama ve dış talep sürücüsüyle güçlenebilir.

## Sonucun Arkasındaki Kanıtlar

### Sipariş hacmi sezonluk

Aylık sipariş grafiği, sipariş hacminin yılın ilk yarısında görece stabil kaldığını gösterir. Ardından Ağustos sonrasında sert düşer; Eylül-Kasım civarında en düşük seviyelere iner ve Aralık'a doğru tekrar dengelenir.

Bu operasyonel olarak önemlidir. Yılın ilerleyen dönemlerinde sipariş talebi zayıflıyorsa stok, personel ve kampanya planlaması her ay aynı talep seviyesini varsaymamalıdır.

### Gelir ana tarihsel dönemde arttı

Gelir trendi 2021'den sonraki dönemlere doğru güçlü büyüme gösterir; gelir yaklaşık 0.79 milyardan 1.5 milyar üzerindeki zirvelere çıkar.

Son nokta sert düşer. Dönem tamlığı kontrol edilmeden bu nokta fazla yorumlanmamalıdır; çünkü kısmi veri en güncel dönemi işletmenin gerçekte olduğundan daha zayıf gösterebilir.

### Büyük şehirler gelir tabanı olarak kalıyor

Tahmini şehir geliri görünümü, İstanbul'un en büyük tahmini paya sahip olduğunu gösterir. Ankara ve İzmir de önemli kalırken Antalya, Bursa, Konya, Şanlıurfa ve Adana kalan karmaya katkı verir.

Bu, bölgesel planlamanın büyük şehirleri ana gelir tabanı olarak görmesi gerektiğini; ancak daha küçük pazarların pay kazanıp kaybetmediğinin de izlenmesi gerektiğini gösterir.

## İş Etkileri

!!! tip "Planlama çıkarımı"

    İşletme satış operasyonlarını yalnızca yıllık toplamlardan planlamamalıdır. Aylık talep örüntüleri ve şehir seviyesinde yoğunlaşma; stok, personel, kampanya zamanlaması ve bölgesel yatırım için önemlidir.

Satış hikayesinin iki tarafı var: ana tarihsel dönemde gelir büyümesi güçlü görünüyor, fakat sipariş hacmi sezonluk zayıflama gösteriyor ve tahmin birkaç şehirde yoğunlaşıyor. Bu birleşim hem talep planlaması hem de bölgesel risk takibi gerektirir.

## Önerilen Aksiyonlar

- Sipariş hacminin yaz sonrasında neden düştüğünü ve bunun sezonluk, promosyonel, operasyonel veya veri kaynaklı olup olmadığını incelemek.
- Stok ve iş gücü planlamasını düz aylık varsayım yerine düşük talep aylarıyla uyumlu hale getirmek.
- İstanbul, Ankara ve İzmir'de kampanya ve hizmet kalitesini önceliklendirmek.
- İşletmenin az sayıda pazara fazla bağımlı hale gelmemesi için küçük şehirlerde büyüme fırsatlarını izlemek.
- Tahmini kampanya dönemleri, tatiller, yerel etkinlikler, enflasyon ve holdout dönem doğrulaması gibi ek sürücülerle geliştirmek.
