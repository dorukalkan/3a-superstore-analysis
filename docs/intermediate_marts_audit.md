# Intermediate & Marts Audit Raporu

Audit tarihi: 2026-05-21

Son tekrar kontrol: 2026-05-21, main branch'ten gelen son değişiklikler
sonrası yeniden bakıldı.

Kapsam:

- `superstore/models/intermediate`
- `superstore/models/marts`

Kontrollerde kullanılan hedef BigQuery dataset:
`superstore-analysis-496710.dbt_doruk`

## Özet

Mevcut revenue mart akışı genel olarak doğru duruyor:

- `int_order_revenue` order başına tek satır tutuyor.
- `int_branch_dim`, branch coverage satırlarını branch başına tek satıra indiriyor.
- `fct_daily_branch_revenue`, order grain'den daily branch grain'e aggregate ediyor.
- Order header revenue ile line revenue arasındaki reconciliation şu an temiz.

Ana problemler eski order-detail enriched intermediate modellerinde. Bazıları
doğrudan `stg_branch` ile join ediyor. `stg_branch` branch grain'de değil;
branch coverage grain'de. Bu yüzden order-detail satırları çoğalıyor. Bu
modeller downstream'de kullanılırsa revenue, order count, item count ve basket
metrikleri şişebilir.

Main'den gelen son değişikliklerde bazı yeni alanlar eklenmiş:

- `int_orderdetail_order_enriched` içine order tarih/grain yardımcı alanları ve
  line share metrikleri eklenmiş.
- `int_orderdetail_order_branch_enriched` içine branch window metrikleri
  eklenmiş.
- `int_orderdetail_order_customer_enriched` içine customer window metrikleri
  eklenmiş.
- `stg_raw_customers.birth_date` artık `DATE` olarak cast ediliyor; bu olumlu
  bir değişiklik.

Ancak ana riskler kapanmamış. Branch/product enriched modellerde satır
çoğaltma ve product modelindeki `safe_total_basket` problemi hala devam ediyor.

## Çalıştırılan Kontroller

```bash
uv run dbt ls --project-dir superstore --resource-type model --output path
```

```bash
uv run dbt compile --project-dir superstore --select models/intermediate models/marts
```

```bash
uv run dbt test --project-dir superstore --select models/intermediate models/marts
```

```bash
uv run dbt build --project-dir superstore --select models/intermediate models/marts
```

Ek olarak `dbt show --inline` ile row count, branch grain, orphan kayıtlar ve
revenue reconciliation toplamları kontrol edildi.

## Mevcut Runtime Sonuçları

| Kontrol | Sonuç |
| --- | --- |
| `dbt compile --select models/intermediate models/marts` | Geçti |
| `dbt test --select models/intermediate models/marts` | 17 passed, 0 failed |
| İlk `dbt build --select models/intermediate models/marts` | 23 passed, 1 failed |
| `dbt build --select +int_orderdetail_order_product_enriched +int_orderdetail_order_customer_enriched` | 46 passed, 0 failed |
| Parent staging modeller yenilendikten sonra `dbt build --select models/intermediate models/marts` | 24 passed, 0 failed |

İlk full intermediate/marts build bu kez `int_orderdetail_order_customer_enriched`
üzerinde hata verdi. Sebep SQL'in kendisi değil, target schema içinde eski
`stg_raw_customers` tablosunun durmasıydı: model SQL'inde `birth_date` artık
`DATE`, fakat mevcut target tablo hala `STRING` olduğu için `date_diff()` hata
verdi. Parent staging modellerle birlikte build edilince `stg_raw_customers`
yenilendi ve aynı intermediate/marts build geçti.

Bu şunu gösteriyor: `models/intermediate models/marts` seçimi tek başına stale
staging objelerini düzeltmeyebilir. Temiz ve güvenilir build için ya parent
seçimi kullanılmalı ya da önce staging build edilmelidir.

## Diagnostic Metrikler

| Metrik | Değer |
| --- | ---: |
| `stg_branch` satır sayısı | 957 |
| `stg_branch` içindeki distinct `branch_id` | 161 |
| Birden fazla `stg_branch` satırı olan branch sayısı | 156 |
| `stg_branch` içinde branch başına max satır | 19 |
| Tutarsız `region/city/branch_town` olan branch sayısı | 0 |
| `stg_order_details` satır sayısı | 51,185,032 |
| `int_orderdetail_order_enriched` satır sayısı | 51,185,032 |
| `int_orderdetail_order_branch_enriched` satır sayısı | 409,139,014 |
| `int_orderdetail_order_customer_enriched` satır sayısı | 51,185,032 |
| `int_orderdetail_order_product_enriched` satır sayısı | 409,139,014 |
| `int_orderdetail_order_branch_enriched` duplicate `order_detail_id` sayısı | 50,561,257 |
| `int_orderdetail_order_product_enriched` duplicate `order_detail_id` sayısı | 50,561,257 |
| `int_orderdetail_order_customer_enriched` duplicate `order_detail_id` sayısı | 0 |
| `int_orderdetail_order_enriched` duplicate `order_detail_id` sayısı | 0 |
| `int_order_revenue` satır sayısı | 10,235,193 |
| Line'ı olmayan order sayısı | 0 |
| Order header'ı olmayan order-detail line sayısı | 0 |
| Branch dimension'da karşılığı olmayan order sayısı | 0 |
| Revenue reconciliation issue olan order sayısı | 0 |
| Revenue reconciliation absolute difference | 0 |
| `fct_daily_branch_revenue` vs `int_order_revenue` order count farkı | 0 |
| `fct_daily_branch_revenue` vs `int_order_revenue` revenue farkı | 0 |

## Bulgular

### 1. Kritik: Branch Join Order-Detail Satırlarını Çoğaltıyor

Etkilenen dosya:

- `superstore/models/intermediate/int_orderdetail_order_branch_enriched.sql`

Model `int_orderdetail_order_enriched` ile `stg_branch`'i doğrudan join ediyor:

```sql
left join branches
    on sales_orders.branch_id = branches.branch_id
```

`stg_branch` branch başına tek satır değil. Branch coverage grain'de; yani bir
branch birden fazla covered town'a sahip olabiliyor. Bu join satır çoğaltıyor.

Gözlenen etki:

| Model | Satır sayısı |
| --- | ---: |
| `stg_order_details` | 51,185,032 |
| `int_orderdetail_order_enriched` | 51,185,032 |
| `int_orderdetail_order_branch_enriched` | 409,139,014 |

Ayrıca `int_orderdetail_order_branch_enriched` içinde 50,561,257 adet
`order_detail_id` birden fazla kez geliyor. Bu modelin order-detail grain claim
etmesi artık güvenilir değil.

Bu modelden yapılacak herhangi bir downstream aggregation, metrikleri branch
başına düşen ortalama coverage satırı kadar fazla gösterebilir.

Önerilen fix:

- İstenen grain branch başına tek satırsa order fact modellerini `stg_branch`
  yerine `int_branch_dim` ile join edin.
- `stg_branch` ile direkt join sadece gerçekten branch-town coverage analizi
  yapılacaksa kullanılmalı.

### 2. Kritik: Product-Enriched Modelde `safe_total_basket` Güvenli Değil

Etkilenen dosya:

- `superstore/models/intermediate/int_orderdetail_order_product_enriched.sql`

Model şu alanı üretiyor:

```sql
o.total_basket as safe_total_basket
```

Bu, order header revenue değerini her order line'a tekrar yazıyor. Model aynı
zamanda doğrudan `stg_branch` ile join ettiği için bu tekrar eden basket değeri
branch coverage satırlarıyla bir kez daha çoğalıyor.

Gözlenen etki:

| Model | Satır sayısı | `safe_total_basket` toplamı | Canonical order revenue'ya göre fark |
| --- | ---: | ---: | ---: |
| `int_orderdetail_order_enriched` | 51,185,032 | 13,105,667,503.38 | 0.00 |
| `int_orderdetail_order_customer_enriched` | 51,185,032 | 13,105,667,503.38 | 0.00 |
| `int_orderdetail_order_branch_enriched` | 409,139,014 | 104,783,784,909.23 | 91,678,117,405.85 |
| `int_orderdetail_order_product_enriched` | 409,139,014 | 663,523,186,554.21 | 650,417,519,050.83 |

`int_orderdetail_order_product_enriched` içinde de 50,561,257 adet
`order_detail_id` duplicate durumda. Yani problem sadece revenue toplamında
değil, model grain'inde de var.

Önerilen fix:

- `int_orderdetail_order_enriched.safe_total_basket` tekrar kullanılmalı. Bu
  alan order basket değerini order başına sadece ilk line'a yazıyor.
- Alternatif olarak order-level basket alanları product/order-detail grain
  modellerinden kaldırılabilir ve revenue mart'lar sadece `int_order_revenue`
  kullanmaya zorlanabilir.
- Branch attribute gerekiyorsa direct `stg_branch` join yerine `int_branch_dim`
  kullanılmalı.

### 3. Orta: `int_branch_dim` İçinde `any_value` Kullanılıyor

Etkilenen dosya:

- `superstore/models/intermediate/int_branch_dim.sql`

Model branch satırlarını şu şekilde tekilleştiriyor:

```sql
any_value(region) as region,
any_value(city) as city,
any_value(branch_town) as branch_town
```

Mevcut datada her `branch_id` içinde `region/city/branch_town` tutarlı
görünüyor, bu yüzden output pratikte stabil. Yine de logic zayıf; ileride
source data tutarsızlaşırsa model bunu sessizce maskeleyebilir.

Önerilen fix:

- Bir `branch_id` için birden fazla distinct `region/city/branch_town`
  kombinasyonu varsa fail eden data test ekleyin.
- Bu consistency test eklendikten sonra `any_value` yerine `min()` gibi
  deterministic aggregation düşünülebilir.

### 4. Orta: Order Details İçinde Monetary Alanlar `FLOAT64`

Etkilenen dosya:

- `superstore/models/staging/stg_order_details.sql`

`unit_price` ve `total_price` `FLOAT64` olarak parse ediliyor. Downstream'de
`int_order_revenue` line revenue'yu sonradan round edip `NUMERIC`'e cast ediyor,
ama floating-point representation staging'de zaten devreye girmiş oluyor.

Önerilen fix:

- Monetary alanları staging'de `NUMERIC` olarak parse edin:

```sql
safe_cast(replace(UNITPRICE, ',', '.') as numeric) as unit_price,
safe_cast(replace(TOTALPRICE, ',', '.') as numeric) as total_price
```

### 5. Orta: Revenue Reconciliation Hesaplanıyor Ama Enforce Edilmiyor

Etkilenen dosya:

- `superstore/models/intermediate/int_order_revenue.sql`

Model şu alanları hesaplıyor:

- `revenue_reconciliation_diff`
- `has_revenue_reconciliation_issue`

Mevcut diagnostic sonuçlarda reconciliation issue yok. Ancak bu durum değişirse
build'i fail ettiren bir dbt test şu an yok.

Önerilen fix:

- `has_revenue_reconciliation_issue = true` olduğunda fail eden singular test
  veya accepted condition tarzı bir test ekleyin.
- Küçük rounding tolerance exception'ları beklenir hale gelirse issue count
  ayrıca audit metriği olarak tutulabilir.

### 6. Orta: Enriched Intermediate Modellerde Grain Koruma Testleri Eksik

Etkilenen dosyalar:

- `superstore/models/intermediate/int_orderdetail_order_enriched.sql`
- `superstore/models/intermediate/int_orderdetail_order_branch_enriched.sql`
- `superstore/models/intermediate/int_orderdetail_order_customer_enriched.sql`
- `superstore/models/intermediate/int_orderdetail_order_product_enriched.sql`

Mevcut YAML testleri ağırlıklı olarak yeni revenue modellerine odaklanıyor.
Enriched order-detail modellerinde declare edilen grain'i koruyan testler yok.

Önerilen fix:

- Order-detail grain claim eden her modelde `order_detail_id` için `unique` ve
  `not_null` testleri ekleyin.
- Row count eşitliği beklenen yerlerde row-count veya relationship-style audit
  testleri ekleyin.
- Her intermediate modelin grain bilgisini dokümantasyonda net yazın.

### 7. Orta: Yeni Window Metrikleri Yanlış Grain Üzerinde Hesaplanıyor

Etkilenen dosyalar:

- `superstore/models/intermediate/int_orderdetail_order_branch_enriched.sql`
- `superstore/models/intermediate/int_orderdetail_order_customer_enriched.sql`

Main'den gelen değişikliklerle branch ve customer enriched modellere yeni window
metrikleri eklenmiş. Bunlar faydalı olabilir, ama şu an bazıları yanlış grain
üzerinde hesaplanıyor.

Branch enriched modelde:

```sql
sum(total_price) over(partition by sales_orders.branch_id) as branch_total_revenue,
avg(safe_total_basket) over(partition by sales_orders.branch_id) as branch_avg_basket
```

Bu hesaplar `stg_branch` join'inden sonra çoğalmış rowset üzerinde çalışıyor.
Dolayısıyla branch total/average metrikleri coverage join'i yüzünden
şişebilir veya anlamsızlaşabilir.

Customer enriched modelde:

```sql
dense_rank() over(
    partition by customer_id
    order by order_date
) as customer_order_number
```

Bu order-detail grain'de çalışıyor. Aynı müşterinin aynı gün birden fazla
order'ı varsa veya bir order'ın birden fazla line'ı varsa order number yorumu
net değil. Benzer şekilde:

```sql
avg(order_total_quantity) over(partition by customer_id) as customer_avg_basket_quantity
```

`order_total_quantity` order seviyesinde bir değer, ama order-detail satırlarında
tekrar ediyor. Bu nedenle ortalama, order başına değil line ağırlıklı hesaplanır.

Önerilen fix:

- Customer lifecycle, order number, AOV, recency, tenure gibi metrikler önce
  order grain'de hesaplanmalı.
- Sonra gerekirse order-detail modellerine join edilmeli.
- Branch total/average metrikleri `int_order_revenue` veya
  `fct_daily_branch_revenue` gibi grain'i net revenue modellerinden gelmeli.

### 8. Düşük/Orta: Stale Staging Objeleri Build Hatası Üretebiliyor

Etkilenen dosya:

- `superstore/models/staging/stg_raw_customers.sql`

`stg_raw_customers.birth_date` artık `DATE` olarak cast ediliyor. Bu iyi bir
değişiklik. Ancak target schema içinde eski `stg_raw_customers` tablosu
duruyorsa `int_orderdetail_order_customer_enriched` hala `birth_date` alanını
`STRING` görebiliyor ve şu ifade patlıyor:

```sql
date_diff(current_date(), birth_date, year) as customer_age
```

Parent staging modellerle birlikte build edilince bu hata kayboldu.

Önerilen fix:

- CI veya lokal build akışında intermediate/marts build etmeden önce staging
  modellerin de güncel olduğundan emin olun.
- Geliştirme sırasında `+model_name` seçimi veya `dbt build --select staging
  models/intermediate models/marts` gibi daha güvenilir bir seçim kullanın.
- Staging model contract/test tarafında tip değişikliklerini yakalayacak
  kontroller düşünün.

## Öncelikli Checklist

### P0 - Metric Inflation Risklerini Düzelt

- [ ] `int_orderdetail_order_branch_enriched` modelini `stg_branch` yerine
      `int_branch_dim` ile join edecek şekilde güncelle.
- [ ] `int_orderdetail_order_product_enriched` modelinde direct `stg_branch`
      join kullanımını kaldır; sadece model bilerek branch-town coverage
      grain'de olacaksa bırak.
- [ ] `int_orderdetail_order_product_enriched.safe_total_basket` alanını düzelt;
      order header revenue her line'da tekrar etmemeli.
- [ ] `int_orderdetail_order_branch_enriched` içindeki `branch_total_revenue`
      ve `branch_avg_basket` hesaplarını çoğalmış rowset'ten çıkar; bu metrikler
      order veya mart grain'den gelmeli.
- [ ] Row-count diagnostic'leri tekrar çalıştır ve order-detail grain
      modellerinin, aksi açıkça dokümante edilmedikçe, 51,185,032 satırda
      kaldığını doğrula.

### P1 - Regression Önleyici Testler Ekle

- [ ] Order-detail grain intermediate modellerin her biri için
      `order_detail_id` üzerinde `unique` ve `not_null` testleri ekle.
- [ ] Her `branch_id` için tek `region/city/branch_town` kombinasyonu olduğunu
      kontrol eden branch consistency testi ekle.
- [ ] `has_revenue_reconciliation_issue = true` olduğunda fail eden revenue
      reconciliation testi ekle.
- [ ] `fct_daily_branch_revenue` aggregate revenue ve order count değerlerini
      `int_order_revenue` ile karşılaştıran test veya audit query ekle.
- [ ] Branch/product enriched modeller için duplicate `order_detail_id` testleri
      ekle; bu testler şu an fail etmeli ve fix sonrası pass etmeli.

### P2 - Data Type ve Model Contract'ları Güçlendir

- [ ] `stg_order_details.unit_price` ve `stg_order_details.total_price`
      alanlarını `FLOAT64` yerine `NUMERIC` yap.
- [x] `stg_raw_customers.birth_date` alanını `DATE` tipine çevir. Bu main'den
      gelen son değişikliklerle yapılmış görünüyor.
- [ ] `int_order_revenue` modelini tekrar build et ve type değişiminden sonra
      reconciliation'ın sıfır kaldığını doğrula.
- [ ] Branch consistency testleri eklendikten sonra `int_branch_dim` içindeki
      `any_value` kullanımını deterministic aggregation ile değiştir.
- [ ] Her intermediate ve mart model için YAML açıklamalarına model grain'ini
      ekle.
- [ ] Customer lifecycle/window metriklerini order-detail grain yerine order
      grain'de hesaplayacak şekilde yeniden modelle.

### P3 - Model Surface'ı Temizle

- [ ] Eski `int_orderdetail_order_*_enriched` modellerinin desteklenen semantic
      layer'ın parçası olup olmadığına karar ver.
- [ ] Destekleneceklerse bu modelleri `int_order_revenue` ve
      `fct_daily_branch_revenue` ile aynı test/dokümantasyon standardına getir.
- [ ] Desteklenmeyeceklerse, ileride yanlışlıkla mart'larda kullanılmalarını
      önlemek için disable et veya kaldır.
- [ ] Model değişikliklerinden sonra audit kontrollerini çalıştırmak için
      `docs/dbt_bq_commands.md` içine kısa bir komut bölümü ekle.
- [ ] Build akışında stale staging objesi kalmaması için önerilen komut
      sırasını netleştir.

## Fix Sonrası Önerilen Validation

P0 ve P1 tamamlandıktan sonra şunları çalıştırın:

Önce staging'i de yenilemek daha güvenilir:

```bash
uv run dbt build --project-dir superstore --select staging
```

```bash
uv run dbt build --project-dir superstore --select models/intermediate models/marts
```

```bash
uv run dbt test --project-dir superstore --select models/intermediate models/marts
```

Beklenen post-fix durumlar:

- `int_orderdetail_order_branch_enriched`, order-detail grain'de kalacaksa row
  count'u `stg_order_details` ile aynı olmalı.
- `int_orderdetail_order_product_enriched`, order-detail grain'de kalacaksa row
  count'u `stg_order_details` ile aynı olmalı.
- Branch/product enriched modellerde duplicate `order_detail_id` sayısı 0
  olmalı.
- Herhangi bir order-detail grain modelinden `safe_total_basket` toplandığında,
  canonical order revenue ile eşitlik sadece order başına first-line allocation
  pattern'i kullanılıyorsa beklenmeli.
- `fct_daily_branch_revenue` revenue ve order count değerleri
  `int_order_revenue` ile reconcile etmeye devam etmeli.
