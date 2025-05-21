-- Подизмерения

INSERT INTO public.d_day(day_name)
SELECT DISTINCT TO_CHAR(sale_date, 'FMDay')
FROM staging.mock_data
ON CONFLICT (day_name) DO NOTHING;

INSERT INTO public.d_month(month_name)
SELECT DISTINCT TO_CHAR(sale_date, 'FMMONTH')
FROM staging.mock_data
ON CONFLICT (month_name) DO NOTHING;

INSERT INTO public.d_category(category_name)
SELECT DISTINCT product_category
FROM staging.mock_data
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO public.d_brand(brand_name)
SELECT DISTINCT product_brand
FROM staging.mock_data
ON CONFLICT (brand_name) DO NOTHING;

INSERT INTO public.d_age_group(age_group)
SELECT DISTINCT
  CASE
    WHEN customer_age < 18 THEN '0–17'
    WHEN customer_age < 36 THEN '18–35'
    WHEN customer_age < 61 THEN '36–60'
    ELSE '61+'
  END
FROM staging.mock_data
ON CONFLICT (age_group) DO NOTHING;

INSERT INTO public.d_region(region_name)
SELECT DISTINCT customer_country
FROM staging.mock_data
ON CONFLICT (region_name) DO NOTHING;

INSERT INTO public.d_pet_type(pet_type)
SELECT DISTINCT customer_pet_type
FROM staging.mock_data
ON CONFLICT (pet_type) DO NOTHING;

INSERT INTO public.d_pet_breed(pet_breed)
SELECT DISTINCT customer_pet_breed
FROM staging.mock_data
ON CONFLICT (pet_breed) DO NOTHING;

INSERT INTO public.d_color(color)
SELECT DISTINCT product_color
FROM staging.mock_data
ON CONFLICT (color) DO NOTHING;

INSERT INTO public.d_size(size)
SELECT DISTINCT product_size
FROM staging.mock_data
ON CONFLICT (size) DO NOTHING;

INSERT INTO public.d_material(material)
SELECT DISTINCT product_material
FROM staging.mock_data
ON CONFLICT (material) DO NOTHING;

INSERT INTO public.d_weight_range(weight_range)
SELECT DISTINCT floor(product_weight / 5) * 5 || '–' || (floor(product_weight / 5) * 5 + 5)
FROM staging.mock_data
ON CONFLICT (weight_range) DO NOTHING;

INSERT INTO public.d_product_name(product_name)
SELECT DISTINCT product_name
FROM staging.mock_data
ON CONFLICT (product_name) DO NOTHING;

INSERT INTO public.d_store_state(state)
SELECT DISTINCT store_state
FROM staging.mock_data
ON CONFLICT (state) DO NOTHING;

INSERT INTO public.d_store_country(country)
SELECT DISTINCT store_country
FROM staging.mock_data
ON CONFLICT (country) DO NOTHING;

INSERT INTO public.d_seller_country(country)
SELECT DISTINCT seller_country
FROM staging.mock_data
ON CONFLICT (country) DO NOTHING;

INSERT INTO public.d_supplier_country(country)
SELECT DISTINCT supplier_country
FROM staging.mock_data
ON CONFLICT (country) DO NOTHING;

INSERT INTO public.d_rating_group(rating_group)
SELECT DISTINCT floor(product_rating)::INT || '–' || (floor(product_rating)::INT + 1)
FROM staging.mock_data
ON CONFLICT (rating_group) DO NOTHING;

INSERT INTO public.d_pet_category(pet_category)
SELECT DISTINCT pet_category
FROM staging.mock_data
WHERE pet_category IS NOT NULL
ON CONFLICT (pet_category) DO NOTHING;


-- Измерения

INSERT INTO public.d_time(full_date, day_id, month_id, year)
SELECT DISTINCT
  sale_date,
  d.day_id,
  m.month_id,
  EXTRACT(YEAR FROM sale_date)::SMALLINT
FROM staging.mock_data s
JOIN public.d_day d ON TO_CHAR(s.sale_date, 'FMDay') = d.day_name
JOIN public.d_month m ON TO_CHAR(s.sale_date, 'FMMONTH') = m.month_name
ON CONFLICT (full_date) DO NOTHING;

INSERT INTO public.d_customer(sale_customer_id, first_name, last_name, age, email, age_group_id, region_id, postal_code)
SELECT DISTINCT
  s.sale_customer_id,
  s.customer_first_name,
  s.customer_last_name,
  s.customer_age::SMALLINT,
  s.customer_email,
  ag.age_group_id,
  r.region_id,
  s.customer_postal_code
FROM staging.mock_data s
JOIN public.d_age_group ag ON
  CASE
    WHEN s.customer_age < 18 THEN '0–17'
    WHEN s.customer_age < 36 THEN '18–35'
    WHEN s.customer_age < 61 THEN '36–60'
    ELSE '61+'
  END = ag.age_group
JOIN public.d_region r ON s.customer_country = r.region_name
ON CONFLICT (sale_customer_id) DO NOTHING;

INSERT INTO public.d_pet(pet_type_id, pet_breed_id, pet_name)
SELECT DISTINCT
  pt.pet_type_id,
  pb.pet_breed_id,
  s.customer_pet_name
FROM staging.mock_data s
JOIN public.d_pet_type pt ON s.customer_pet_type = pt.pet_type
JOIN public.d_pet_breed pb ON s.customer_pet_breed = pb.pet_breed
ON CONFLICT DO NOTHING;

INSERT INTO public.d_seller(sale_seller_id, first_name, last_name, email, country_id, postal_code)
SELECT DISTINCT
  s.sale_seller_id,
  s.seller_first_name,
  s.seller_last_name,
  s.seller_email,
  sc.seller_country_id,
  s.seller_postal_code
FROM staging.mock_data s
JOIN public.d_seller_country sc ON s.seller_country = sc.country
ON CONFLICT (sale_seller_id) DO NOTHING;

INSERT INTO public.d_supplier(supplier_name, contact, email, phone, address, city, country_id)
SELECT DISTINCT
  s.supplier_name,
  s.supplier_contact,
  s.supplier_email,
  s.supplier_phone,
  s.supplier_address,
  s.supplier_city,
  sc.supplier_country_id
FROM staging.mock_data s
JOIN public.d_supplier_country sc ON s.supplier_country = sc.country
ON CONFLICT (supplier_name) DO NOTHING;

INSERT INTO public.d_store(store_name, location, city, state_id, country_id, phone, email)
SELECT DISTINCT
  s.store_name,
  s.store_location,
  s.store_city,
  ss.store_state_id,
  sc.store_country_id,
  s.store_phone,
  s.store_email
FROM staging.mock_data s
JOIN public.d_store_state ss ON s.store_state = ss.state
JOIN public.d_store_country sc ON s.store_country = sc.country
ON CONFLICT (store_name, location) DO NOTHING;

INSERT INTO public.d_product(
  sale_product_id, product_name_id, category_id, brand_id,
  color_id, size_id, material_id, weight, price,
  description, rating, reviews, release_date, expiry_date,
  rating_group_id, weight_range_id, pet_category_id)
SELECT DISTINCT
  s.sale_product_id,
  pn.product_name_id,
  c.category_id,
  b.brand_id,
  clr.color_id,
  sz.size_id,
  m.material_id,
  s.product_weight::NUMERIC,
  s.product_price::NUMERIC,
  s.product_description,
  s.product_rating::NUMERIC,
  s.product_reviews::INTEGER,
  s.product_release_date,
  s.product_expiry_date,
  rg.rating_group_id,
  wr.weight_range_id,
  pc.pet_category_id
FROM staging.mock_data s
JOIN public.d_product_name pn ON s.product_name = pn.product_name
JOIN public.d_category c ON s.product_category = c.category_name
JOIN public.d_brand b ON s.product_brand = b.brand_name
JOIN public.d_color clr ON s.product_color = clr.color
JOIN public.d_size sz ON s.product_size = sz.size
JOIN public.d_material m ON s.product_material = m.material
JOIN public.d_rating_group rg ON floor(s.product_rating)::INT || '–' || (floor(s.product_rating)::INT + 1) = rg.rating_group
JOIN public.d_weight_range wr ON floor(s.product_weight / 5) * 5 || '–' || (floor(s.product_weight / 5) * 5 + 5) = wr.weight_range
JOIN public.d_pet_category pc ON s.pet_category = pc.pet_category
ON CONFLICT (sale_product_id) DO NOTHING;


-- Факты

INSERT INTO public.f_sale(
  sale_id, time_id, customer_key, pet_key,
  seller_key, supplier_key, store_key, product_key,
  quantity, total_price)
SELECT
  s.id,
  t.time_id,
  c.customer_key,
  p.pet_key,
  sel.seller_key,
  sup.supplier_key,
  st.store_key,
  pr.product_key,
  s.sale_quantity::INTEGER,
  s.sale_total_price::NUMERIC
FROM staging.mock_data s
JOIN public.d_time t ON s.sale_date = t.full_date
JOIN public.d_customer c ON s.sale_customer_id = c.sale_customer_id
JOIN public.d_pet p ON s.customer_pet_name = p.pet_name
JOIN public.d_seller sel ON s.sale_seller_id = sel.sale_seller_id
JOIN public.d_supplier sup ON s.supplier_name = sup.supplier_name
JOIN public.d_store st ON s.store_name = st.store_name AND s.store_location = st.location
JOIN public.d_product pr ON s.sale_product_id = pr.sale_product_id
ON CONFLICT (sale_id) DO NOTHING;