---
icon: lucide/map-pin
title: Bölge ve Kategori Performansı
description: Gelir ve kategori performansı analizi
author: Eda Bilgin
---

# Bölgesel Gelir ve Kategori Performansı

!!! note "Özet"

    Gelir bölgeler arasında eşit dağılmıyor. Marmara yaklaşık **3.82 milyar TRY** üreterek en güçlü bölge konumunda.

    Kategori karması da yoğunlaşma gösteriyor. En üst kategori dashboard'da gelirin **%26.18**'ini sağlayan **EV** kategorisi.

    İşletme yüksek performanslı bölgeleri korurken, bölgesel kategori farklarını daha yerel kampanya, stok ve büyüme aksiyonları planlamak için kullanmalıdır.

![Bölgesel Gelir Görünümü](../assets/Regional_Revenue_Overview.png)

Dashboard gelirin Türkiye genelinde nerede üretildiğini ve bu geliri hangi ürün kategorilerinin sürüklediğini gösterir. Bölge seviyesinde gelir, kategori katkısı, ortalama sepet değeri ve en üst kategori sıralamasını birleştirir.

## İş Sorusu

Bu analiz bir bölgesel planlama sorusuna odaklanır:

> Gelir nerede yoğunlaşıyor ve hangi kategoriler bölgesel performansı sürüklüyor?

Yanıt için şube bölgeleri, şube şehirleri, ürün kategorileri, toplam gelir, toplam adet, sipariş aktivitesi ve ortalama sepet değeri karşılaştırıldı.

## Kanıtlar Ne Gösteriyor?

<div class="grid cards" markdown>

-   :lucide-map-pinned:{ .lg .middle } __En güçlü bölge__

    ---

    Marmara yaklaşık **3.82 milyar TRY** gelirle lider bölgedir.

-   :lucide-layers:{ .lg .middle } __Kategori genişliği__

    ---

    Dashboard toplam **21** kategoriyi takip eder.

-   :lucide-medal:{ .lg .middle } __En üst kategori__

    ---

    `EV`, gelirin **%26.18**'ini sağlayarak en üst kategoridir.

-   :lucide-shopping-cart:{ .lg .middle } __Ortalama sepet değeri__

    ---

    Ortalama sepet değeri **302.08** seviyesindedir.

</div>

## Yöntem

Bölgesel analiz; sipariş, şube ve ürün kategori bilgileriyle zenginleştirilmiş sipariş satırları üzerine kuruludur. Bu, dashboard'un satış metriklerini hem coğrafyaya hem de kategori hiyerarşisine bağlamasını sağlar.

Ana mart geliri şube bölgesi, şube şehri, üst seviye kategori ve ikinci seviye kategoriye göre agregeler. Toplam sipariş, benzersiz ürün, toplam adet, toplam gelir ve ortalama sepet değeri hesaplar.

??? info "Kullanılan dbt modelleri"

    - `int_orderdetail_order_product_enriched`: sipariş detaylarını siparişler, müşteri/sipariş bağlamı, şube coğrafyası ve ürün kategorileriyle birleştirir.
    - `mart_category_region_distribution`: siparişler, ürünler, adet, gelir ve ortalama sepet değeri için bölgesel ve kategori metriklerini agregeler.
    - `fct_daily_branch_revenue`: sipariş sayısı, müşteri sayısı, gelir, satılan adet ve ortalama sipariş değeriyle şube/tarih gelir analizini destekler.

## Sonucun Arkasındaki Kanıtlar

### Marmara en güçlü gelir bölgesi

Bölgesel treemap Marmara'yı en büyük gelir bloğu olarak gösterir. Onu İç Anadolu, Ege, Akdeniz, Güneydoğu Anadolu, Karadeniz ve Doğu Anadolu gibi diğer ana bölgeler izler.

Bu yoğunlaşma önemlidir çünkü bölgesel performans dengeli değildir. İşletme Marmara'yı çekirdek gelir pazarı olarak ele almalı; diğer bölgelerde büyüme veya kapsama boşlukları olup olmadığını da incelemelidir.

### Kategori katkısı bölgeye göre değişiyor

Bölge/kategori stacked grafiği ana kategorilerin bölgeler arasında nasıl katkı verdiğini gösterir. EV, OYUNCAK, KOZMETIK, GIDA ve BEBEK görünür katkıcılardır; fakat karışımları her bölgede aynı değildir.

Bu, bölgesel planlamanın her yerde tek bir ulusal kategori stratejisi kullanmaması gerektiğini gösterir. Kategori talebi coğrafyaya göre değişebilir; bu nedenle kampanyalar ve stok planı mümkün olduğunca yerel olarak ayarlanmalıdır.

### Küçük bir kategori grubu gelirin büyük bölümünü sürüklüyor

Kategori katkısı ve en üst kategori grafikleri EV, OYUNCAK, KOZMETIK ve GIDA'nın en önemli görünür katkıcılar arasında olduğunu gösterir.

EV gelirin %26.18'i ile en üst kategoridir. Bu onu merchandising ve bulunurluk açısından önemli kılar; fakat işletme sınırlı sayıda kategoriye fazla dayanırsa bağımlılık riski de yaratır.

## İş Etkileri

!!! tip "Bölgesel planlama çıkarımı"

    En güçlü bölgeler ve kategoriler korunmalı; fakat büyüme planlaması kategori talebinin yeterince gelişmediği bölgesel boşlukları da aramalıdır.

Bölgesel gelir yoğunlaşması işletmenin nerede güçlü olduğunu gösterdiği için faydalıdır. Aynı zamanda planlama riskine işaret eder: birkaç bölge ve kategori gelirin çok büyük bölümünü taşıyorsa, yerel bir kesinti veya kategori zayıflığı genel performansı etkileyebilir.

## Önerilen Aksiyonlar

- Marmara ve diğer yüksek gelirli bölgelerde stok bulunurluğu ve kampanya yürütmesini önceliklendirmek.
- Her yerde aynı kategori karmasını uygulamak yerine bölgeye özel kategori kampanyaları kurmak.
- Daha zayıf bölgelerde talep, dağıtım, şube kapsaması veya ürün çeşitliliği boşluklarını incelemek.
- Daha yüksek değerli bölgesel fırsatları bulmak için ortalama sepet değerini bölge ve kategori bazında izlemek.
- En üst kategorileri merchandising, promosyon planlaması ve kategori seviyesinde gelir takibi için kullanmak.
