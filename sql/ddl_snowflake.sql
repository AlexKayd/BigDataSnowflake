
-- Подизмерения

CREATE TABLE IF NOT EXISTS public.d_day(
  day_id SERIAL PRIMARY KEY,
  day_name VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_month(
  month_id SERIAL PRIMARY KEY,
  month_name VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_category(
  category_id SERIAL PRIMARY KEY,
  category_name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_brand(
  brand_id SERIAL PRIMARY KEY,
  brand_name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_age_group(
  age_group_id SERIAL PRIMARY KEY,
  age_group TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_region(
  region_id SERIAL PRIMARY KEY,
  region_name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_pet_type(
  pet_type_id SERIAL PRIMARY KEY,
  pet_type TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_pet_breed(
  pet_breed_id SERIAL PRIMARY KEY,
  pet_breed TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_color(
  color_id SERIAL PRIMARY KEY,
  color TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_size(
  size_id SERIAL PRIMARY KEY,
  size TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_material(
  material_id SERIAL PRIMARY KEY,
  material TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_weight_range(
  weight_range_id SERIAL PRIMARY KEY,
  weight_range TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_product_name(
  product_name_id SERIAL PRIMARY KEY,
  product_name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_store_state(
  store_state_id SERIAL PRIMARY KEY,
  state TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_store_country(
  store_country_id SERIAL PRIMARY KEY,
  country TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_seller_country(
  seller_country_id SERIAL PRIMARY KEY,
  country TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_supplier_country(
  supplier_country_id SERIAL PRIMARY KEY,
  country TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_rating_group(
  rating_group_id SERIAL PRIMARY KEY,
  rating_group TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_pet_category(
  pet_category_id SERIAL PRIMARY KEY,
  pet_category TEXT UNIQUE NOT NULL
);


-- Измерения

CREATE TABLE IF NOT EXISTS public.d_time(
  time_id SERIAL PRIMARY KEY,
  full_date DATE UNIQUE NOT NULL,
  day_id INT NOT NULL REFERENCES public.d_day(day_id),
  month_id INT NOT NULL REFERENCES public.d_month(month_id),
  year SMALLINT NOT NULL
);

CREATE TABLE IF NOT EXISTS public.d_customer(
  customer_key SERIAL PRIMARY KEY,
  sale_customer_id TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  age SMALLINT,
  email TEXT UNIQUE,
  age_group_id INT REFERENCES public.d_age_group(age_group_id),
  region_id INT REFERENCES public.d_region(region_id),
  postal_code TEXT
);

CREATE TABLE IF NOT EXISTS public.d_pet(
  pet_key SERIAL PRIMARY KEY,
  pet_type_id INT REFERENCES public.d_pet_type(pet_type_id),
  pet_breed_id INT REFERENCES public.d_pet_breed(pet_breed_id),
  pet_name TEXT
);

CREATE TABLE IF NOT EXISTS public.d_seller(
  seller_key SERIAL PRIMARY KEY,
  sale_seller_id TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  email TEXT UNIQUE,
  country_id INT REFERENCES public.d_seller_country(seller_country_id),
  postal_code TEXT
);

CREATE TABLE IF NOT EXISTS public.d_supplier(
  supplier_key SERIAL PRIMARY KEY,
  supplier_name TEXT UNIQUE NOT NULL,
  contact TEXT,
  email TEXT,
  phone TEXT,
  address TEXT,
  city TEXT,
  country_id INT REFERENCES public.d_supplier_country(supplier_country_id)
);

CREATE TABLE IF NOT EXISTS public.d_store(
  store_key SERIAL PRIMARY KEY,
  store_name TEXT NOT NULL,
  location TEXT,
  city TEXT,
  state_id INT REFERENCES public.d_store_state(store_state_id),
  country_id INT REFERENCES public.d_store_country(store_country_id),
  phone TEXT,
  email TEXT,
  UNIQUE(store_name, location)
);

CREATE TABLE IF NOT EXISTS public.d_product(
  product_key SERIAL PRIMARY KEY,
  sale_product_id TEXT UNIQUE NOT NULL,
  product_name_id INT REFERENCES public.d_product_name(product_name_id),
  category_id INT REFERENCES public.d_category(category_id),
  brand_id INT REFERENCES public.d_brand(brand_id),
  color_id INT REFERENCES public.d_color(color_id),
  size_id INT REFERENCES public.d_size(size_id),
  material_id INT REFERENCES public.d_material(material_id),
  weight NUMERIC,
  price NUMERIC,
  description TEXT,
  rating NUMERIC,
  reviews INTEGER,
  release_date DATE,
  expiry_date DATE,
  rating_group_id INT REFERENCES public.d_rating_group(rating_group_id),
  weight_range_id INT REFERENCES public.d_weight_range(weight_range_id),
  pet_category_id INT REFERENCES public.d_pet_category(pet_category_id)
);


-- Факты

CREATE TABLE IF NOT EXISTS public.f_sale(
  sale_key SERIAL PRIMARY KEY,
  sale_id TEXT UNIQUE NOT NULL,
  time_id INT NOT NULL REFERENCES public.d_time(time_id),
  customer_key INT NOT NULL REFERENCES public.d_customer(customer_key),
  pet_key INT REFERENCES public.d_pet(pet_key),
  seller_key INT NOT NULL REFERENCES public.d_seller(seller_key),
  supplier_key INT REFERENCES public.d_supplier(supplier_key),
  store_key INT REFERENCES public.d_store(store_key),
  product_key INT NOT NULL REFERENCES public.d_product(product_key),
  quantity INTEGER,
  total_price NUMERIC
);